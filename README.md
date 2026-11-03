# Carlo's Little Mathbook

A mathematics book written once in LaTeX and published two ways from the same
source:

- a **PDF book**, built with `latexmk`
- a **wiki-style website**, built with [LaTeXML](https://math.nist.gov/~BMiller/LaTeXML/):
  one page per chapter, a navigation tree, prev/next links, working equation
  and citation links, TikZ figures as SVG, and search ([Pagefind](https://pagefind.app))

The LaTeX in `chapters/` is the only copy of the content. Never edit the
generated HTML or PDF.

Live site (once deployed): <https://cdutoit.github.io/math-wiki-book/>

## Quick start

```bash
./setup.sh      # once per machine: TeX, LaTeXML, Node
./build.sh      # PDF + website  -> build/web/  (PDF also at build/pdf/main.pdf)
./build.sh serve  # same, then preview at http://localhost:8000
```

`setup.sh` supports macOS (Homebrew) and Ubuntu/Debian (apt). On macOS it asks
for your password once, for the BasicTeX installer and `tlmgr`. Running it
again skips anything already installed.

## Commands

| `./build.sh …`          | `make …`                  | Output |
|-------------------------|---------------------------|--------|
| *(nothing)* / `site`    | `make site`               | PDF + website in `build/web/` (what CI publishes) |
| `pdf`                   | `make pdf`                | `build/pdf/main.pdf` |
| `web`                   | `make web`                | `build/web/index.html` |
| `chapter <path>`        | `make chapter CH=<path>`  | one chapter only, `build/pdf/chapter.pdf` |
| `serve`                 | `make serve` *(after a build)* | preview at <http://localhost:8000> |
| `clean`                 | `make clean`              | deletes `build/` |
|                         | `make watch`              | rebuild the PDF on every save |

`build.sh` is a thin wrapper around the Makefile that also fixes `PATH` and a
common npm cache problem, so it works from any terminal. Use whichever you like.

A full build takes about 15 seconds for the website and a few seconds for the PDF.

## Layout

```
main.tex          Reading order: \part, then \include for each chapter
preamble.tex      Packages (shared by every book built from these chapters)
macros.tex        Notation, theorem environments, \assumes, \webonly / \printonly
refs.bib          Bibliography (BibTeX)
chapters/
  physics/                         Part I    labels: phys:...
    time-dilation.tex
    centripetal-acceleration.tex
  probability-statistics/          Part II   labels: prob:...
    basic-probability.tex
web-extras/       Code and resources shown only on the website, by part
web/              Website styling (site.css) and search box (site.js)
build/            Generated PDF and website (ignored by git)
Makefile          Build commands
setup.sh          Install the tools
build.sh          Build wrapper
.github/workflows/pages.yml   CI: build on every PR, publish main to GitHub Pages
```

Terminology: a **part** is a theme (Probability and Statistics), a **chapter**
is one topic and one `.tex` file, and a **section** is a `\section` inside it.
On the website a part is a top-level entry in the navigation, a chapter is a
page, and a section is a heading on that page.

## Writing

**Reading order lives only in `main.tex`.** Files are grouped by theme in
`chapters/<part>/` and carry no numbers, so moving a chapter means moving one
`\include` line, never renaming files.

**Adding a chapter**

1. Create `chapters/<part>/<topic>.tex` starting with:
   ```latex
   \chapter{Topic Title}
   \label{prob:topic}
   \assumes{What a reader should already know.}
   ```
2. Add `\include{chapters/<part>/<topic>}` to `main.tex` where it belongs.
3. Its web page will be `prob_topic.html` (from the label).

**Labels** start with the part's prefix: `phys:`, `prob:`, then `eq:` or `sec:`
for equations and sections, e.g. `\label{prob:eq:bayes}`, referenced with
`\eqref{prob:eq:bayes}`. Never type equation numbers by hand. A new part gets a
new prefix (e.g. `linalg:`, `cx:`).

**Every chapter starts with `\assumes{...}`**, because a reader can land on any
page of the website.

**Shared notation** goes in `macros.tex`, never in a chapter.

**Faster rebuilds while writing:** `./build.sh chapter chapters/<part>/<topic>`
builds just that chapter. Cross-references to other chapters resolve once a
full `./build.sh pdf` has been run.

## Web-only and print-only content

```latex
\webonly{
\begin{explore}[Simulate it]
  Text, maths, code (\lstinputlisting{web-extras/...}), links, videos.
  Link to a file in this repo with \repofile{web-extras/...}.
\end{explore}
}

\printonly{ Shown in the PDF only. }
```

There is no build flag to remember: `make web` turns `\webonly` on, and
pdflatex (locally, in CI, on Overleaf) leaves it off. To move something into
the book, delete the `\webonly{ }` wrapper and keep what is inside. The
`explore` box prints fine in the PDF too.

Files used by web extras live in `web-extras/<part>/`. To list every web-only
item: `grep -rn '\\webonly' chapters`.

## Viewing and editing elsewhere

- **Offline:** `make watch` rebuilds the PDF on save and opens it in Preview.
  VS Code with the *LaTeX Workshop* extension also works (pdflatex, `main.tex`).
- **Overleaf:** upload the repository as a zip (or use Overleaf's Git sync)
  and keep the default pdflatex compiler. `main.tex` is the main file.

## Publishing

Pushing to `main` runs `.github/workflows/pages.yml`, which installs TeX Live
and LaTeXML on Ubuntu, runs `make site`, and deploys `build/web` to GitHub
Pages. Pull requests run the same build without deploying, and every run keeps
the PDF as a downloadable artifact.

One-time setup on GitHub: **Settings → Pages → Build and deployment → Source:
GitHub Actions**.
