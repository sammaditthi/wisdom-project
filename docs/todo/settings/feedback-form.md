# Feedback form — plan

Started 2026-11-02. Not built yet.

**Goal:** a reader types a message in the app, presses Send, and it arrives as
an email in the dev Gmail. No mail app, no account, no Firebase.

**How:** the app POSTs the message to a small Worker of our own,
`feedback.sammaditthi.net`, which emails it through Cloudflare Email Routing.
Free.

| | |
|---|---|
| the Worker it sits beside | [`research_server/README.md`](../../../research_server/README.md), [`scripts/research_server/README.md`](../../../scripts/research_server/README.md) |
| where the form lives | [`app-settings-dialog.md`](./app-settings-dialog.md) |
| the error-handling standard it follows | [`../refactor/generic-server-call-and-error-handling-standard.md`](../refactor/generic-server-call-and-error-handling-standard.md) |
| accounts and domains | [`../../done/ops/retire-personal-cloudflare-account.md`](../../done/ops/retire-personal-cloudflare-account.md) |

---

## What the user sees

```
┌───────────────────────────────────────────────┐
│ Send feedback                               ✕ │
│ Report a bug, suggest an idea, or share       │
│ what's working well.                          │
│ ┌───────────────────────────────────────────┐ │
│ │ "Search found nothing for a word I know   │ │
│ │  is in the text."                         │ │
│ │                                           │ │
│ └───────────────────────────────────────────┘ │
│ Your message goes to the Sammaditthi team     │
│ with the app version, platform and language.  │
│                             [Cancel]  [Send]  │
└───────────────────────────────────────────────┘
```

- **Settings → General → About** gets a *Send feedback* row that opens it.
  Full screen below `ResponsiveUtils.mobileBreakpoint`, like Settings itself.
- One multi-line box, up to **2,000 characters**; a counter shows in the last
  200. The hint is an example message.
- **Send** is disabled until the box has non-blank text. While sending, a
  spinner shows and the box locks.
- **Sent:** the body becomes a short thank-you with Close.
- **Failed:** an inline message with Retry. The text is kept; a failed send
  never loses it.
- Cancel, ✕ and Esc close it and drop the text, with no "discard?" prompt.
- **Settings → Privacy** gets the same sentence beside the research note.
- English and Sinhala strings in `app_en.arb` / `app_si.arb`.

Phones cannot reach Settings yet (app-settings-dialog Decisions 4). The form
reaches phones with that entry point — see *Open questions*.

---

## Decisions

1. **Own Worker + Cloudflare Email Routing** (2026-11-02). Considered:

   | Option | Why not |
   |---|---|
   | Web3Forms / Formspree | a third party reads every message; small free tiers whose terms can change |
   | EmailJS (Flutter package) | another account and package; 200 requests a month free |
   | Resend / Brevo | need a secret key, so a Worker anyway — Cloudflare already sends for us |
   | SMTP from the app (`mailer` + Gmail app password) | the password ships in every install; no raw sockets on web |
   | Telegram / Discord webhook | same extractable secret, and not email |
   | Firebase | ruled out by the product owner |

   Cloudflare's limits page (checked 2026-11-03): "Sends to verified
   destination addresses are always free", on any plan, even with only Email
   Routing set up. The domain receives no mail today (confirmed 2026-11-02),
   so turning Email Routing on breaks nothing.

2. **Its own Worker, `wisdom-feedback`, not a route on `wisdom-research`.**
   Research is pinned to a US region, carries a Gemini key and has its own
   release rhythm; feedback should not go down when a research deploy does. A
   Worker costs nothing, and feedback is a rounding error in the account's
   free daily requests.

3. **The recipient is in neither the repo nor the request** (2026-11-03). The
   Gmail is the product owner's GitHub address too, so it never goes in a
   committed file. It is verified as a destination in the Cloudflare
   dashboard, and kept in `scripts/config/secrets.env` (gitignored) as
   `FEEDBACK_TO_ADDRESS`. The deploy uploads it as the Worker secret
   `FEEDBACK_TO`. The Worker always sends there and reads no address from the
   request, so it can't be used to email anyone else.

4. **One field, no reply** (2026-11-03). The product owner wants the simplest
   form first: no topic, no email field, no `Reply-To`. The email field is in
   *Later*.

5. **Abuse control is light, on purpose.**
   - Per-IP limit with the Workers **Rate Limiting binding**, keyed on
     `cf-connecting-ip`: 3 sends a minute, on the POST only. The web app's
     CORS preflight is answered before it, so it doesn't use up a send.
   - Not a zone WAF rule: the free plan allows **one** rate-limiting rule and
     `/research` already uses it.
   - The Worker's size limits are a **backstop above the app's**, never equal
     to them. `maxLength` in the app counts letters as the reader sees them;
     JavaScript counts UTF-16 code units, and one Sinhala letter can be
     several. So: 8,000 code units for the message, 32 KB for the body.
     Anything the app lets through must pass, or the reader gets a Retry that
     can never work.
   - No captcha, no app token. Turnstile needs a webview in native apps; an
     app token can be extracted (see
     `../research/research-endpoint-security-before-testers.md`).
   - **Kill switch:** wisdom-feedback → Settings → Domains & Routes → disable
     the domain. The app then shows its "couldn't reach us" message.

6. **App context goes with every message:** `AppVersion.display`
   (`lib/core/version/app_version.gen.dart`), platform (`web`, or
   `defaultTargetPlatform.name`) and app language. The dialog says so. It
   makes bug reports readable without a back-and-forth.

7. **Reuse the research transport; share its error mapper.**
   - The datasource uses `ApiClient` as is (`lib/data/datasources/api_client.dart`).
   - Rename `mapResearchError` (`lib/data/repositories/research_error_mapper.dart`)
     to `mapApiException`, the name the refactor doc gives the shared mapper,
     in `api_exception_mapper.dart`. Its English fallback copy names Research
     (rate limited, busy, not authorised); make it neutral when it moves.
     Research's real copy is in the ARB files and doesn't change.
   - Move `canRetryType` from `widgets/research/research_error_messages.dart`
     to `widgets/common/`.
   - Feedback has its own three messages: couldn't reach us (offline and
     timeout), too many sends, something went wrong.

---

## The Worker — `feedback_server/`

A sibling of `research_server/`: TypeScript, Hono for routing and CORS.
Cloudflare-only (the email binding has no Node equivalent), so no `node.ts`.
Scripts use the one wrangler in research_server's lockfile (`$WRANGLER`,
`scripts/lib/common.sh`); feedback_server doesn't add a second.

### Contract

`POST https://feedback.sammaditthi.net/feedback`

```json
{
  "message": "සූත්‍රයේ අකුරක් වැරදියි …",
  "app": { "version": "1.1.0 (2)", "platform": "android", "language": "si" }
}
```

- Unknown fields are ignored.
- **200** `{"ok": true}` on success. Not 204: `ApiClient.postJson` treats
  anything but a 200 with a JSON object as an error.
- Errors use the research envelope `{"error": {code, message, retriable}}`, so
  the shared mapper reads them unchanged:

  | Status | `code` | When |
  |---|---|---|
  | 400 | `bad_request` | blank message, over the backstop, body too large, not JSON |
  | 429 | `rate_limited` | the per-IP limit tripped |
  | 502 | `server_error` | the send threw, or `FEEDBACK_TO` is not set |

- CORS: the same three origins as `RESEARCH_CORS_ORIGINS`, in a
  `FEEDBACK_CORS_ORIGINS` var. Native apps send no preflight.
- `GET /health` → 200 `{"status":"ok"}` when `FEEDBACK_TO` is set, else 503,
  so a deploy without the secret fails its last check.

### The email

```
From:    Sammaditthi feedback <feedback@sammaditthi.net>
To:      FEEDBACK_TO
Subject: Feedback: සූත්‍රයේ අකුරක් වැරදියි …

<message, as typed>

—
App: 1.1.0 (2) · android · si
```

- Sent with the binding's `send({ from, to, subject, text })`. Cloudflare
  recommends it; `EmailMessage` + `mimetext` is legacy. No dependency.
- Subject: `Feedback: ` + the message's first line, cut to 60 characters.
  Not one fixed subject: Gmail would thread every message into one
  conversation. Strip CR, LF and other control characters first.
- Plain text, UTF-8. `from` goes in its API field; Cloudflare refuses it as a
  custom header.

### Config sketch

```jsonc
"send_email": [
  // No recipient here: it is the FEEDBACK_TO secret (Decision 3).
  { "name": "FEEDBACK_EMAIL", "allowed_sender_addresses": ["feedback@sammaditthi.net"] }
],
"ratelimits": [
  { "name": "FEEDBACK_LIMITER", "namespace_id": "1001", "simple": { "limit": 3, "period": 60 } }
],
"dev": { "port": 8085 },
"workers_dev": false,
"preview_urls": false
```

`period` can only be 10 or 60. The limit is counted per Cloudflare location:
loose, but enough for an inbox.

### Scripts

Shaped like research's, so `scripts/deploy.sh --prod` treats it as one more
product:

- `scripts/feedback_server/deploy.sh`: `--prod` (`--dev` explains and exits
  3), `--dry-run`, `--skip-tests`, `--yes`, a `# Status:` line. Uploads
  `FEEDBACK_TO` with `write_worker_secrets` (`scripts/lib/common.sh`) and ends
  on `/health`.
- `test.sh`; `run.sh` — `wrangler dev` on 8085, `FEEDBACK_TO` through a
  temporary `--env-file` as research's `run.sh` does. `wrangler dev` simulates
  the email binding, so there is no stub mode.
- `README.md`: one-time setup, rollback.
- Add `feedback_server` to `scripts/deploy.sh` `PRODUCTS` (after
  research_server, before app/web), `scripts/test_all.sh` `ALL_PRODUCTS` and
  `scripts/release_all_dryrun.sh` `TARGETS`. `deploy.sh` tests through
  `test_all.sh` and then deploys with `--skip-tests`, so leaving it out of
  `test_all.sh` means its tests never run in a release.
- `scripts/config/targets.env`: `FEEDBACK_BASE_URL=https://feedback.sammaditthi.net`,
  `FEEDBACK_PROD_BRANCH=main`.
- `scripts/config/secrets.env.example`: `FEEDBACK_TO_ADDRESS=` with a one-line
  note.

---

## The app

Clean-architecture slices, mirroring research:

| Layer | File | What it holds |
|---|---|---|
| domain | `lib/domain/entities/feedback/feedback_submission.dart` | Freezed: `message`, `appVersion`, `platform`, `language` |
| domain | `lib/domain/repositories/feedback_repository.dart` | `Future<Either<Failure, Unit>> send(FeedbackSubmission)` |
| data | `lib/data/datasources/feedback_datasource.dart` + `feedback_remote_datasource.dart` | interface + `ApiClient.postJson('/feedback', …)`, 20-second timeout |
| data | `lib/data/repositories/feedback_repository_impl.dart` | catches `ApiException` → `mapApiException` |
| presentation | `lib/presentation/providers/feedback_provider.dart` | `feedbackBaseUrlProvider` (`--dart-define=FEEDBACK_BASE_URL`, default `http://localhost:8085`), datasource and repository providers, a send notifier: idle → sending → sent / failed |
| presentation | `lib/presentation/widgets/settings/feedback_dialog.dart` | the dialog |
| presentation | `general_settings_page.dart` | the *Send feedback* row in About; the Privacy sentence |

The notifier builds the `FeedbackSubmission`, filling in version, platform and
language, so the datasource stays plain JSON mapping.

`FEEDBACK_BASE_URL` goes wherever `RESEARCH_BASE_URL` does today:
`scripts/app/web/deploy.sh`, `scripts/app/web/run_mac.sh`,
`scripts/app/macos/run.sh`, `scripts/app/ios/run.sh`,
`scripts/app/android/run.sh`, `scripts/app/windows/run.bat`, and the native
release builds once they exist. 8085 joins the dev port map (8080 Flutter web,
8082 research, 8083 static-site preview, 8084 `check_in_browser.dart`).

---

## Build order

1. **Dashboard, by hand, ops account.**
   - `sammaditthi.net` → Email → Email Routing → enable. It adds the MX and
     SPF records.
   - Destination addresses → add the dev Gmail → click the link Cloudflare
     emails there.
   - Workers & Pages → Create → Worker → *Hello World*, named exactly
     `wisdom-feedback` (the deploy token is Editor and cannot create one).
   - wisdom-feedback → Settings → Domains & Routes → Custom domain
     `feedback.sammaditthi.net`, production only.
   - `scripts/config/secrets.env`: `FEEDBACK_TO_ADDRESS=` the dev Gmail.
2. **Worker and scripts.** Deploy, then smoke-test with `curl`: one English and
   one Sinhala message, one over the backstop, four in a row for the 429.
   Check the Sinhala subject reads right in Gmail.
3. **Gmail:** filter `from:feedback@sammaditthi.net` → never send to spam,
   label *Feedback*.
4. **Error-mapper rename** (Decision 7), on its own commit.
5. **App feature**, then the `FEEDBACK_BASE_URL` wiring in the run and deploy
   scripts.

## Still to check

Cloudflare's docs settled the rest on 2026-11-03.

- **Rate Limiting binding on Workers Free.** The docs don't say. Fallback if
  not: an in-memory counter per isolate, weaker but still slows one script.
- **Deploy token.** Whether the `send_email` binding needs an Email permission
  beyond *Workers — Editor*. The first deploy shows it.

## Later

- **An optional email field**, so we can write back. The address goes in the
  body only, length-capped; the Worker doesn't check its format.
- **Static site:** a plain HTML `<form method="post">` to the same endpoint
  works with JavaScript off
  ([`static-site-constraints.md`](../../decisions/static-site-constraints.md)).
  Needs a form-encoded body, a redirect back to a thank-you page, and a
  honeypot field, since bots do fill HTML forms.
- **"Report a problem with this text"** from the reader menu, opening the same
  dialog with the sutta's node key filled in.
- **A global daily cap** (Durable Object or KV counter), only if many-IP abuse
  ever happens.

## Open questions

1. **Phones:** wait for the phone Settings entry
   (`../reader/phone-chrome-auto-hide.md`), or add a way in now?

## Tests

Not written with this plan; a separate test agent writes them. What they
need to cover: the Worker's validation and subject stripping; the renamed
mapper (research's tests move with it); the send notifier's states; the
dialog keeping text after a failure.
