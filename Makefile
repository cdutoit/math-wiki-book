# Build commands for the book. Outputs go to build/ (ignored by git).
#
#   make pdf                 full book          -> build/pdf/main.pdf
#   make chapter CH=<path>   one chapter only   -> build/pdf/chapter.pdf
#                            e.g. CH=chapters/physics/time-dilation
#   make watch               rebuild the full book on every save
#   make web                 website            -> build/web/index.html
#   make serve               preview the website at http://localhost:8000
#   make clean               remove build/

PDF_DIR := build/pdf
LATEXMK := latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error -outdir=$(PDF_DIR)

# pdflatex cannot create folders, so mirror chapters/ under build/pdf for the
# per-chapter .aux files that \include writes.
CHAPTER_DIRS := $(addprefix $(PDF_DIR)/,$(shell find chapters -type d))

WEB_DIR := build/web
PAGEFIND := npx -y pagefind@1.3.0

.PHONY: pdf chapter watch web serve clean

pdf: | $(CHAPTER_DIRS)
	$(LATEXMK) main.tex

# Uses its own job name so the full book's main.pdf is never overwritten by a
# partial build. Cross-references to other chapters still resolve once a full
# `make pdf` has been run.
chapter: | $(CHAPTER_DIRS)
	@test -n "$(CH)" || { echo "usage: make chapter CH=chapters/<part>/<chapter>"; exit 1; }
	$(LATEXMK) -jobname=chapter -usepretex='\includeonly{$(CH)}' main.tex

watch: | $(CHAPTER_DIRS)
	$(LATEXMK) -pvc main.tex

# One page per part and chapter, named from the \label (prob_basic-probability.html),
# then a Pagefind search index over the chapter text. --preload=latexml.sty
# turns on \iflatexml, so \webonly content is included (see macros.tex).
web:
	rm -rf $(WEB_DIR)
	latexmlc main.tex --preload=latexml.sty --path=. --sourcedirectory=. --log=build/latexml.log \
	  --format=html5 --split --splitat=chapter --splitnaming=label \
	  --navigationtoc=context --css=web/site.css --javascript=web/site.js \
	  --dest=$(WEB_DIR)/index.html
	$(PAGEFIND) --site $(WEB_DIR) --root-selector .ltx_page_content --exclude-selectors math

serve:
	python3 -m http.server 8000 --bind 127.0.0.1 --directory $(WEB_DIR)

$(CHAPTER_DIRS):
	mkdir -p $@

clean:
	rm -rf build
