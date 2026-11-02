# Feedback form — plan

Started 2026-11-02 on `claude/exciting-cray-qw6oon`. Not built yet.

**Goal:** a reader types a topic and a description inside the app, presses
Send, and an email lands in `wisdomproject.dev@gmail.com`. No mail app opens,
no account, no Firebase.

**How:** the app POSTs the form to a new, tiny Worker of our own,
`feedback.sammaditthi.net`. The Worker emails it through Cloudflare Email
Routing to the one address it is allowed to send to. Everything is free.

| | |
|---|---|
| the Worker it sits beside | [`research_server/README.md`](../../../research_server/README.md), [`scripts/research_server/README.md`](../../../scripts/research_server/README.md) |
| where the form lives | [`app-settings-dialog.md`](./app-settings-dialog.md) |
| the error-handling standard it follows | [`../refactor/generic-server-call-and-error-handling-standard.md`](../refactor/generic-server-call-and-error-handling-standard.md) |
| accounts and domains | [`../../done/ops/retire-personal-cloudflare-account.md`](../../done/ops/retire-personal-cloudflare-account.md) |

---

## What the user sees

- **Settings → General → About** gets a *Send feedback* row. It opens a small
  dialog (full screen below `ResponsiveUtils.mobileBreakpoint`, like the
  Settings dialog itself).
- Three fields:

  | Field | Required | Limit | Notes |
  |---|---|---|---|
  | Topic | yes | 120 characters | one line |
  | Description | yes | 4,000 characters | multi-line; counter shows near the limit |
  | Your email | no | 254 characters | hint: *Optional — if you'd like us to write back*. Light check only (`@` and a dot after it) |

- **Send** is disabled until topic and description have non-blank text. While
  sending it shows a spinner and the fields lock.
- **Sent:** the dialog body becomes a short thank-you with a Close button.
- **Failed:** an inline message with Retry. What the reader typed is kept;
  nothing is ever lost to a failed send.
- One line under the form says what is sent and where: the text, the email if
  given, and the app version, platform and language, by email to the Wisdom
  Project team. **Settings → Privacy** gets the same sentence beside the
  existing research note.
- English and Sinhala strings in `app_en.arb` / `app_si.arb`.

Phones cannot reach Settings yet (app-settings-dialog Decisions 4). The form
reaches phones when that entry point lands — see *Open questions*.

---

## Decisions

1. **Own Worker + Cloudflare Email Routing** (2026-11-02). Considered:

   | Option | Why not |
   |---|---|
   | Web3Forms / Formspree | a third party reads every message; free tier (about 250 or 50 a month) and its terms can change under us |
   | EmailJS (Flutter package) | another account and package; 200 requests a month free |
   | Resend / Brevo | need a secret key, so a Worker anyway — Cloudflare already sends for us |
   | SMTP from the app (`mailer` + Gmail app password) | the Gmail password ships in every install and can be extracted; no raw sockets on web |
   | Telegram / Discord webhook | same extractable secret, and not email |
   | Firebase | ruled out by the product owner |

   Sending from a Worker to a **verified address in our own account** is free
   on every plan and does not count toward the paid sending quota. Only sending
   to arbitrary recipients needs Workers Paid. The domain receives no mail
   today (confirmed 2026-11-02), so turning Email Routing on breaks nothing.

2. **Its own Worker, `wisdom-feedback`, not a route on `wisdom-research`**
   (2026-11-02). Research is pinned to a US region for Gemini, carries a
   Gemini key and has its own release rhythm; feedback should not go down
   when a research deploy does. A Worker costs nothing — the free plan allows
   100 per account. All Workers in the account share one free allowance of
   100,000 requests a day; feedback is a rounding error in it.

3. **The recipient is fixed in config, never in the request.** The binding
   names `destination_address`, so the endpoint can only ever email us. It
   cannot become a spam relay; the worst abuse is junk in our own inbox.

4. **No reply handling** (2026-11-02). No `Reply-To` header. If the reader
   left an email, it is in the message body and we write back from Gmail by
   hand.

5. **Abuse control is light, on purpose.**
   - Per-IP limit with the Workers **Rate Limiting binding**, keyed on
     `cf-connecting-ip`: 3 sends a minute. It is loose (counted per
     Cloudflare location), which is enough for an inbox.
   - Not a zone WAF rule: the free plan allows **one** rate-limiting rule and
     `/research` already uses it.
   - Size limits from the table above, checked in the Worker (the app's
     limits are a courtesy; the Worker's are the rule), plus a request body cap
     of 32 KB.
   - No captcha, no app token. Turnstile needs a webview in native apps; an
     app token can be extracted (see
     `../research/research-endpoint-security-before-testers.md`).
   - **Kill switch:** wisdom-feedback → Settings → Domains & Routes → disable
     the domain. The app then shows its "can't reach" message.

6. **App context goes with every message:** app version
   (`lib/core/version/app_version.gen.dart`), platform (`web`, or
   `defaultTargetPlatform.name`) and app language. It makes bug reports
   readable without a back-and-forth. Easy to drop if unwanted.

7. **Reuse the research transport, generalise its error mapper.**
   - The datasource uses `ApiClient` as is (`lib/data/datasources/api_client.dart`).
   - `mapResearchError` (`lib/data/repositories/research_error_mapper.dart`)
     is generic in all but name: timeout, offline, status and error-code
     handling. Rename it `mapApiError`, move it to `api_error_mapper.dart`, and
     use it from both repositories. Same for `canRetryType`, which lives in
     `widgets/research/research_error_messages.dart` but belongs in
     `widgets/common/`. This is the next step the refactor doc already plans.
   - Feedback keeps its own short user messages (offline, too many sends,
     something went wrong): research's mention the answer service.

---

## The Worker — `feedback_server/`

A sibling of `research_server/`, same toolchain (TypeScript, Hono for routing
and CORS, Wrangler 4). Cloudflare-only: the email binding has no Node
equivalent, so no `node.ts` entry.

### Contract

`POST https://feedback.sammaditthi.net/feedback`

```json
{
  "topic": "අකුරු වැරදියි",
  "message": "…",
  "email": "reader@example.com",
  "app": { "version": "1.1.0", "platform": "android", "language": "si" }
}
```

- `email` may be absent. Unknown fields are ignored.
- **200** `{"ok": true}` on success. Not 204: `ApiClient.postJson` treats
  anything but a 200 with a JSON object as an error.
- Errors use the research envelope `{"error": {code, message, retriable}}`
  so the shared mapper reads them unchanged:

  | Status | `code` | When |
  |---|---|---|
  | 400 | `bad_request` | missing or blank topic/description, over a limit, malformed email, body too large |
  | 429 | `rate_limited` | the per-IP limit tripped |
  | 502 | `server_error` | the email send threw |

- CORS: the same three origins as `RESEARCH_CORS_ORIGINS`, in a
  `FEEDBACK_CORS_ORIGINS` var. Native apps send no preflight.
- `GET /health` → `{"status":"ok"}`, for the deploy script's last check.

### The email

```
From:    Wisdom Project feedback <feedback@sammaditthi.net>
To:      wisdomproject.dev@gmail.com
Subject: [Feedback] අකුරු වැරදියි

<description, as typed>

—
Email: reader@example.com            (or: not given)
App:   1.1.0 · android · si
```

- Plain text, UTF-8.
- The topic goes into a header: **strip CR, LF and other control characters**
  before it does (header injection). Trim and cap it again server-side.

### Config sketch

```jsonc
"send_email": [
  { "name": "FEEDBACK_EMAIL", "destination_address": "wisdomproject.dev@gmail.com" }
],
"ratelimits": [
  { "name": "FEEDBACK_LIMITER", "namespace_id": "1001", "simple": { "limit": 3, "period": 60 } }
],
"workers_dev": false,
"preview_urls": false
```

The destination address is not a secret; it sits in the committed config.

### Scripts

Shaped like the research Worker's, so release and deploy treat it as one more
product:

- `scripts/feedback_server/deploy.sh` (`--prod` only; `--dev` explains and
  exits), `test.sh`, `README.md` (one-time setup, rollback).
- `scripts/deploy.sh`: add `feedback_server` to `PRODUCTS`, before `app/web`.
- `scripts/config/targets.env`: `FEEDBACK_BASE_URL=https://feedback.sammaditthi.net`.

---

## The app

Clean-architecture slices, mirroring research:

| Layer | File | What it holds |
|---|---|---|
| domain | `lib/domain/entities/feedback/feedback_submission.dart` | Freezed: `topic`, `message`, `email?`, `appVersion`, `platform`, `language` |
| domain | `lib/domain/repositories/feedback_repository.dart` | `Future<Either<Failure, Unit>> send(FeedbackSubmission)` |
| data | `lib/data/datasources/feedback_datasource.dart` + `feedback_remote_datasource.dart` | interface + `ApiClient.postJson('/feedback', …)`, 20-second timeout |
| data | `lib/data/repositories/feedback_repository_impl.dart` | catches `ApiException` → `mapApiError` |
| presentation | `lib/presentation/providers/feedback_provider.dart` | `feedbackBaseUrlProvider` (`--dart-define=FEEDBACK_BASE_URL`, default `http://localhost:8084`), datasource and repository providers, a send notifier: idle → sending → sent / failed |
| presentation | `lib/presentation/widgets/settings/feedback_dialog.dart` | the form |
| presentation | `general_settings_page.dart` | the *Send feedback* row in About; the Privacy sentence |

The notifier builds the `FeedbackSubmission`, filling in version, platform and
language, so the datasource stays plain JSON mapping.

`FEEDBACK_BASE_URL` is passed wherever `RESEARCH_BASE_URL` is today:
`scripts/app/web/deploy.sh`, `scripts/app/web/run_mac.sh`,
`scripts/app/android/run.sh`, `scripts/app/windows/run.bat`, and the native
release builds. Port 8084 joins the dev port map (8080 Flutter web, 8082
research, 8083 static-site preview).

---

## Build order

1. **Dashboard, by hand, ops account.**
   - `sammaditthi.net` → Email → Email Routing → enable. It adds the MX and
     SPF records.
   - Destination addresses → add `wisdomproject.dev@gmail.com` → click the
     link Cloudflare emails there.
   - Workers & Pages → Create → Worker → *Hello World*, named exactly
     `wisdom-feedback` (the deploy token is Editor and cannot create one).
   - wisdom-feedback → Settings → Domains & Routes → Custom domain
     `feedback.sammaditthi.net`, production only.
2. **Settle the to-verify list** below with the Cloudflare docs open.
3. **Worker and scripts.** Deploy, then smoke-test with `curl`: one English
   and one Sinhala topic, one with an email and one without, one over a limit,
   four in a row for the 429.
4. **Gmail:** filter `from:feedback@sammaditthi.net` → never send to spam,
   label *Feedback*.
5. **Error-mapper rename** (Decision 7), on its own commit.
6. **App feature**, then the `FEEDBACK_BASE_URL` wiring in the run and deploy
   scripts.

## To verify before building

Researched from a session that could not open `developers.cloudflare.com`;
these rest on search excerpts and third-party write-ups.

- **Which send API Workers Free supports for a verified destination.** The
  Email Routing docs build a raw MIME message (`EmailMessage` from
  `cloudflare:email` + the `mimetext` package). The newer Email Service docs
  (public beta since 2026-04-16) show a structured `send({ from, to, subject,
  text })`. Prefer the structured one if it works on the free plan — no
  dependency and no hand-built MIME.
- **Rate Limiting binding on Workers Free.** Third-party sources say yes, at
  no extra cost; the official page doesn't say. Fallback if not: an in-memory
  counter per isolate, which is weaker but still slows a single script.
- **Deploy token.** Whether a `send_email` binding needs an Email Routing
  permission on the prod token, beyond *Workers — Editor*.
- **Local runs.** Whether `wrangler dev` simulates `send_email` (logs instead
  of sending). If not, a `FEEDBACK_STUB=1` var that logs the email, like
  research's stub mode.
- **Sinhala subjects** arrive readable in Gmail (UTF-8 header encoding).

## Later

- **Static site:** a plain HTML `<form method="post">` to the same endpoint
  works with JavaScript off
  ([`static-site-constraints.md`](../../decisions/static-site-constraints.md)). Needs a
  form-encoded body, a redirect back to a thank-you page, and a honeypot field,
  since bots do fill HTML forms.
- **"Report a problem with this text"** from the reader menu, opening the same
  dialog with the sutta's node key filled in.
- **A global daily cap** (Durable Object or KV counter), only if many-IP abuse
  ever happens.
- **Topic as a dropdown** (bug, translation, suggestion, other) if free-text
  topics turn out hard to sort.

## Open questions

1. **Entry point:** a *Send feedback* row in About opening a dialog
   (recommended — two fields don't earn a tab), or a third Settings tab?
2. **Phones:** wait for the phone Settings entry
   (`../reader/phone-chrome-auto-hide.md`), or add a way in now?
3. **App context** (Decision 6): keep version, platform and language in every
   message?

## Tests

Not written with this plan; a separate test agent writes them. What they
need to cover: the Worker's validation table and header stripping; the
renamed mapper (existing research tests move with it); the send notifier's
states; the dialog keeping text after a failure.
