# aisb-slides

Beamer decks for [AI Security Bootcamp](https://github.com/AI-Security-Bootcamp/aisb)
lectures. Folder layout mirrors the [`aisb`](https://github.com/AI-Security-Bootcamp/aisb)
repo: one `<day>.<section>-<topic>/` folder per deck (e.g. `3.2-jailbreaking/`).

> **🌐 Live site:** **[ai-security-bootcamp.github.io/aisb-slides](https://ai-security-bootcamp.github.io/aisb-slides/)** — every deck's handout and presentation PDF, open inline in the browser.

`0.0-example/` is a sample deck that shows the conventions. Copy from it or
from `template.tex`, and delete it once real decks exist.

## Add a new deck

1. `mkdir 3.2-jailbreaking && cp template.tex 3.2-jailbreaking/main.tex`
2. Put any images in a sibling `img/` folder.
3. Push to `main`.

CI finds every `<day>.<section>-<topic>/main.tex` and builds **two** PDFs per
deck: a handout (no `\pause` reveals, compact) and a presentation (each
`\pause` becomes a separate page, for live talks). It then republishes the
live site. The PDF name is the folder name:

| Folder | Handout | Presentation |
|---|---|---|
| `0.0-example/` | `0.0-example.pdf` | `0.0-example-present.pdf` |
| `3.2-jailbreaking/` | `3.2-jailbreaking.pdf` | `3.2-jailbreaking-present.pdf` |

Folder names must match `^[0-9]+\.[0-9]+-[a-z0-9-]+$`. Other folders are skipped with a CI warning.

## Build locally

```sh
cd 0.0-example
pdflatex main.tex          # or: latexmk -pdf main.tex
```

Or check that every deck compiles, the same way CI does:

```sh
./check-builds.sh            # handout mode
./check-builds.sh --present  # presentation mode
```

The deck's first real line is `\providecommand{\HANDOUT}{1}`. Change `1` to `0`
to make a bare `pdflatex main.tex` produce the presentation version. CI
ignores this line (it always builds both modes through `-usepretex`), so set it to
whichever mode you want locally.

`main.tex` loads the shared preamble via `\input{../aisb_beamer.sty}`,
which is also where the actual `\documentclass` call lives.

## Hosting

Every push to `main` rebuilds every deck and replaces the live site. The
index page lists all decks grouped by day. Stable per-deck URLs:

```
https://ai-security-bootcamp.github.io/aisb-slides/<slug>.pdf          # handout
https://ai-security-bootcamp.github.io/aisb-slides/<slug>-present.pdf  # presentation
```

PRs and non-`main` branches build (to catch errors early) but don't deploy.
PDFs are **not** committed. The LaTeX on `main` is the only source of truth.

One-time setup: in the GitHub repo settings, go to **Pages → Build and deployment → Source** and set it to
**GitHub Actions**.

## Where things live

| To change... | Edit... |
|---|---|
| Slide content / math / figures | the deck's `main.tex` |
| Slide images | the deck's sibling `img/` folder |
| Shared LaTeX preamble, theme, custom macros | `aisb_beamer.sty` |
| The index page's look (HTML / CSS) | `.github/workflows/build-slides.yml`, step **"Generate public/index.html (day-grouped)"** |
| Day names on the index page | same step, the `case "$day" in ...` block |
| A deck's title as shown on the index page | the `{{[X.Y] Title}}` line near the top of that deck's `main.tex` |
| Build/CI behaviour | `.github/workflows/build-slides.yml` (other steps) |
