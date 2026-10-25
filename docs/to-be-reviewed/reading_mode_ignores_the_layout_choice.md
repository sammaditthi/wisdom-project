# Discussion: Chrome reading mode ignores the layout choice

**Status:** Open — spike done, fix designed, *not implemented*. Deliberately parked.
**Goal:** Make the static site's reading layout visible to Chrome's reading mode and its
read-aloud, so a reader on Sinhala-only is not read the Pali as well.
**Related:** `docs/todo/audio/tipitaka-tts-implementation-plan.md` (the reason this is parked),
`static_site_generator/lib/render/reading_layouts.dart`,
`static_site_generator/lib/render/stylesheet.dart`.

> Every number below is a **dated measurement record** (2026-10-25, Chrome 155.0.8059.86,
> local build), which is the deliberate exception in the project's "never write a corpus
> count in a doc" rule. They are not live figures and must not be refreshed in place — a
> re-run writes a new dated section.

---

## 1. Why this is parked, not dropped

Native audio is coming (see the TTS plan). Once the site and app play their own audio —
tipitaka.lk's human Pali recordings and the pre-rendered Sinhala mirror — the reason to reach
for Chrome's read-aloud mostly goes away, and this drops in priority. It does not become
*wrong*: reading mode is also a reading surface, not only a listening one, and it is the
accessibility path for anyone who already uses it.

Revisit when native audio ships. If reading mode is still the only way to listen to a page,
implement §4. If native audio covers it, this stays open as a known defect.

## 2. The defect

The site ships **both languages in every readable page** and expresses the reader's choice two
ways, neither of which survives extraction:

- author CSS — `#L-si:checked ~ .content .pali { display: none; }` (`stylesheet.dart`)
- runtime radio state — set from `localStorage` / `?layout=` by the inline `layoutScript`

Chrome's reading mode therefore shows and speaks both languages, interleaved, in the order the
markup carries them.

## 3. Root cause — settled, with the engine change that explains it

**Chrome 153 replaced reading mode's extraction engine.** It no longer reads the accessibility
tree. It injects a vendored copy of Mozilla's Readability.js and runs it on a *detached deep
clone* of the live document:

```js
// components/dom_distiller/core/javascript/readability_distiller.js
clonedDoc = document.cloneNode(/*deep=*/ true);
return new Readability(clonedDoc, options).parse();
```

A detached clone has no layout and no computed style, so no stylesheet rule can reach it.
Readability's only visibility gate never tries:

```js
// third_party/readability/modded_src/Readability.js:3037
_isProbablyVisible(node) {
  return (
    (!node.style || node.style.display != "none") &&      // inline attribute ONLY
    (!node.style || node.style.visibility != "hidden") &&
    !node.hasAttribute("hidden") &&
    (!node.hasAttribute("aria-hidden") ||
      node.getAttribute("aria-hidden") != "true" || /* …fallback-image… */)
  );
}
```

`getComputedStyle` appears **zero times** in that file (3,129 lines). The feature is
`FEATURE_ENABLED_BY_DEFAULT` in `ui/accessibility/accessibility_features.cc`.

The accessibility tree is still correct — a screen reader on these pages reads only the chosen
language. That is what made this look contradictory at first. Reading mode simply stopped using
that tree.

**Measured extraction model.** A probe page with nine differently-hidden paragraphs, read back
out of the panel's own DOM. Every row matches the source above.

| Mechanism | Reading mode reads it | Why |
| --- | --- | --- |
| stylesheet `display: none` | **yes** | inline `style` only; cascade never consulted |
| stylesheet `visibility: hidden` | **yes** | same |
| off-screen, `font-size: 0` | **yes** | no computed style at all |
| JS-inserted before `load` | **yes** | the clone is of the live DOM |
| `hidden` attribute | no | `!node.hasAttribute("hidden")` |
| `aria-hidden="true"` | no | explicit check |
| node removed from the DOM by JS | no | the clone is of the live DOM |
| `<template>` content | no | unreachable in the element walk |
| appended 1 s after `load` | no | distilled once per navigation |

Two consequences, and they are the whole design space: **author CSS can never fix this**, and
**JavaScript can**, because the engine clones the live DOM.

## 4. The fix, as designed (not implemented)

Mark the cells the stylesheet already hides, so extraction can see the choice. The selectors
must **not** be typed a second time — `reading_layouts.dart` exists because a layout id spelled
in two places fails silently — so each layout carries its own hide-selectors in the record the
CSS is already generated from, and the markup hands them to the script on a `data-` attribute,
the way Sinhala strings and URLs already reach `site.js`:

```html
<input class="layout-input" type="radio" name="layout" id="L-si"
       value="sinhalaOnly"
       data-hides=".content .pali,.content .row.no-si">
```

```js
/* Reading mode clones the DOM and never reads our stylesheet, so the layout has to
   be a DOM state too, not only a CSS one. */
function markHidden() {
  var radios = document.getElementsByName('layout');
  for (var i = 0; i < radios.length; i++) {
    var hides = radios[i].getAttribute('data-hides');
    if (!hides) continue;
    var cells = document.querySelectorAll(hides);
    for (var j = 0; j < cells.length; j++) {
      if (radios[i].checked) cells[j].setAttribute('aria-hidden', 'true');
      else cells[j].removeAttribute('aria-hidden');
    }
  }
}
```

Called once on load and on each radio's `change`. Side-by-side and stacked carry no
`data-hides`, so they mark nothing.

| File | Change |
| --- | --- |
| `reading_layouts.dart` | one field on the `ReadingLayout` record; two of four layouts carry selectors |
| `stylesheet.dart` | read those selectors instead of spelling them in the four hide rules |
| `page_template.dart` | emit `data-hides` on the radios in `_layoutRadios()` |
| `assets/site.js` | the ~15 lines above |

Unchanged: no new asset, no new `<script>` tag, no stylesheet rule added or removed, no markup
structure change, no URL contract, no `foldedLeafKeys`, no page-set change, no loss of build
determinism. `_headers` needs nothing — its CSP is already `script-src 'self' 'sha256-…'`, the
inline `layoutScript` hash is untouched, and `site.js` keeps computing its own `?v=` from
content.

**Condition on shipping:** the selectors are generated from `readingLayouts`, never hand-typed.
Without that this reintroduces the silent-failure mode that file was written to remove.

`aria-hidden` and `hidden` are both verified excluded. `aria-hidden` has no rendering effect;
`hidden` also hides the element if the stylesheet ever fails to load, which is arguably the
safer degradation. Settle at implementation.

## 5. Measured result — 2026-10-25, Chrome 155.0.8059.86

Two real pages, served over HTTP, layout = Sinhala only, panel contents read back over CDP and
matched against each language cell's text.

| Page | Variant | Panel text | Pali blocks read aloud | Sinhala blocks kept |
| --- | --- | --- | --- | --- |
| `kn-mn-14-1` | today | 15,608 chars | **6 / 21** | 21 / 21 |
| `kn-mn-14-1` | fixed | 8,352 chars | **0 / 21** | 21 / 21 |
| `vp-mv-1` (largest, 1.3 MB) | today | 472,723 chars | **634 / 636** | 631 / 642 |
| `vp-mv-1` | fixed | 255,253 chars | **0 / 636** | 631 / 642 |

- The leak is near-total on long pages; the 6/21 is reading mode's own distiller discarding
  short blocks.
- Sinhala retention is identical before and after. The fix destroys nothing. (The 11 missing on
  the big page are the distiller dropping short blocks, both ways.)
- Runtime cost: **0.2–0.5 ms for 716 nodes**, once per page load, worst page in the corpus.
- Three implementations — detaching nodes, setting one attribute, and loading `defer`red the way
  `site.js` already loads — produced **byte-identical** panel output. The cheap one is not a
  compromise.

## 6. How to re-run it (only needed after a Chrome engine change)

1. Serve a local build over **HTTP**. `file://` is skipped by this engine.
2. Launch Chrome **by hand** with `--remote-debugging-port=9222` and a throwaway
   `--user-data-dir`. Do **not** use Selenium/Puppeteer: they add `--enable-automation`, which
   routes to the old accessibility-tree engine and makes the bug disappear.
3. Open the reading-mode side panel manually — **one click, unavoidable**. There is no Chrome
   switch to auto-open it, and `chrome://read-anything-side-panel.top-chrome/` cannot be opened
   as a tab (`ERR_INVALID_URL`).
4. The panel is then a debuggable target (`chrome://read-anything-side-panel.top-chrome/` in
   `/json/list`). Attach and read its text, descending through shadow roots. Navigating the page
   tab re-distills, so one click covers every variant.
5. Discriminate by matching each `.content .pali` / `.content .si` cell's `textContent` against
   the panel text. Do **not** count ZWJ: the Sinhala translation quotes Pali with touching
   conjuncts too, so ZWJ is not a language discriminator here.

Other traps found the hard way: the panel distills **once per navigation**, so a layout switch
with the panel open never refreshes it; and two driver processes navigating the same tab produce
results lagging one variant behind, which looks like a real difference.

## 7. Known gaps this fix does not close

- **242 TOC pages read both languages even in the browser.** They print a bilingual preamble but
  carry no layout radios (`withLayouts = page.isReadable && bothLanguages`), so there is no
  layout state for any fix to read. Separate and smaller. Of those 242, **3** have no row holding
  both languages (`atta-kn-ps`, `atta-mn-1`, `atta-kn-nc`) — a single-language layout would blank
  their preamble outright, which is the exact hazard the current guard prevents. Any fix keeps a
  per-page test, never a blanket "TOC + bilingual". Recompute with: count built pages containing
  `class="pali"` and `class="si"` but not `class="layout-input"`.
- **Firefox Reader View has the same root cause** (serializes the DOM, same visibility check), so
  the fix should carry over — unmeasured.
- **Safari Reader** is closed source and unmeasured. Third-party reports say it honours `hidden`.
- **Chrome's fallback engine was never affected** — PDFs, Google Docs, non-HTTP URLs and
  automated browsers still use the accessibility tree, which excludes the hidden language
  correctly.

## 8. Will Chrome fix it?

Assume not. Nothing announced in chromestatus, release notes or the developer blog. Upstream
treats it as out of scope by design — on `mozilla/readability` issue 984 (open since 2025-09):
*"isn't really fixable in readability the way it is currently designed… we don't have a CSS
parser and a layout engine, so determining which styles apply isn't possible."* Chrome's *older*
engine did consult computed style and got this right; that engine is being deleted. The only
standards escape, a CSS media query for reader modes (`w3c/csswg-drafts` issue 8546), has sat
unresolved since 2023.

Reversibility is fine either way: if Chrome does fix it, this change becomes redundant, not
harmful — marking already-hidden content as hidden is a no-op for every other consumer.

### Sources

Fetched and verified directly:

- [`readability_distiller.js`](https://chromium.googlesource.com/chromium/src/+/main/components/dom_distiller/core/javascript/readability_distiller.js) — the clone + `new Readability(...)`
- [`Readability.js`](https://chromium.googlesource.com/chromium/src/+/main/third_party/readability/modded_src/Readability.js) — `_isProbablyVisible` at line 3037; no `getComputedStyle`
- [`accessibility_features.cc`](https://chromium.googlesource.com/chromium/src/+/main/ui/accessibility/accessibility_features.cc) — `FEATURE_ENABLED_BY_DEFAULT` at line 400

Reported by a research pass, **not** independently verified — re-check before quoting externally:

- [`mozilla/readability` 984](https://github.com/mozilla/readability/issues/984) — upstream position
- [`w3c/csswg-drafts` 8546](https://github.com/w3c/csswg-drafts/issues/8546) — reader-mode media query
- [`DomUtil.java`](https://chromium.googlesource.com/chromium/dom-distiller/+/refs/heads/main/java/org/chromium/distiller/DomUtil.java) — the old engine's computed-style check
- [`read_anything_untrusted_page_handler.cc`](https://chromium.googlesource.com/chromium/src/+/main/chrome/browser/ui/webui/side_panel/read_anything/read_anything_untrusted_page_handler.cc) — the automation / non-HTTP / PDF / Docs gates
- Chrome 153 as the milestone where the default flipped
