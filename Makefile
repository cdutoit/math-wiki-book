# Build commands for the book. Outputs go to build/ (ignored by git).
#
#   make pdf                 full book          -> build/pdf/main.pdf
#   make chapter CH=<path>   one chapter only   -> build/pdf/chapter.pdf
#                            e.g. CH=chapters/physics/time-dilation
#   make watch               rebuild the full book on every save
#   make clean               remove build/

PDF_DIR := build/pdf
LATEXMK := latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error -outdir=$(PDF_DIR)

# pdflatex cannot create folders, so mirror chapters/ under build/pdf for the
# per-chapter .aux files that \include writes.
CHAPTER_DIRS := $(addprefix $(PDF_DIR)/,$(shell find chapters -type d))

.PHONY: pdf chapter watch clean

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

$(CHAPTER_DIRS):
	mkdir -p $@

clean:
	rm -rf build
