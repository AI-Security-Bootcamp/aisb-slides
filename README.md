# aisb-slides

Beamer decks for [AI Security Bootcamp](https://github.com/AI-Security-Bootcamp/aisb)
lectures. Each bootcamp day opens with one lecture, so there is one deck per day.
Names mirror the [`aisb`](https://github.com/AI-Security-Bootcamp/aisb) repo:

- deck folder: `day<N>-<day-title>/`, from the aisb curriculum's day titles
  (cf. aisb's `day0-setup/`), e.g. `day5-adversarial-ml/`;
- section files: named after the matching aisb section folder, e.g.
  `day5-adversarial-ml/5.2-adversarial-language.tex` for aisb's
  `5.2-adversarial-language/`. `main.tex` `\input`s them in order.

> **🌐 Live site:** **[ai-security-bootcamp.github.io/aisb-slides](https://ai-security-bootcamp.github.io/aisb-slides/)** — every deck's handout and presentation PDF, open inline in the browser.

`day0-example/` is a sample deck that shows the basic conventions. Copy from it or
from `template.tex`.

## After cloning

```sh
./install-hooks.sh
```

This enables the versioned git hooks in `.githooks/` and pulls the LFS files.
The hooks handle Git LFS, and a **pre-push** hook refuses the push unless
every deck compiles in both handout and presentation mode, the same builds
CI runs. Bypass in an emergency with `git push --no-verify`.

## Add a new deck

1. `mkdir day3-llm-inference-security && cp template.tex day3-llm-inference-security/main.tex`
2. Put any images in a sibling `img/` folder. Images and other binaries are
   stored with **Git LFS** (`.gitattributes`). Add a pattern to `.gitattributes` before committing a new binary type.
3. Push to `main`.

CI finds every `day<N>-<topic>/main.tex` and builds **two** PDFs per
deck: a handout (no `\pause` reveals, compact) and a presentation (each
`\pause` becomes a separate page, for live talks). It then republishes the
live site. The PDF name is the folder name:

| Folder | Handout | Presentation |
|---|---|---|
| `day0-example/` | `day0-example.pdf` | `day0-example-present.pdf` |
| `day5-adversarial-ml/` | `day5-adversarial-ml.pdf` | `day5-adversarial-ml-present.pdf` |

Folder names must match `^day[0-9]+-[a-z0-9-]+$`. Other folders are skipped with a CI warning.

Decks with a `biblo.bib` use biblatex + biber; `latexmk` runs biber automatically.

## Build locally

```sh
cd day0-example
latexmk -pdf main.tex      # or pdflatex, for decks without a bibliography
```

Build every deck in both modes into `out/` (gitignored), named as on the live site:

```sh
./build-all.sh                       # all decks
./build-all.sh day5-adversarial-ml   # just one
```

Or just check that every deck compiles, the same way CI does:

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
| A deck's title as shown on the index page | the `\title[<short title>]` line in that deck's `main.tex` (a leading `Day N:` is stripped) |
| Build/CI behaviour | `.github/workflows/build-slides.yml` (other steps) |
| Local pre-push build check | `.githooks/pre-push` |
