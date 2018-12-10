RMD := $(shell find . -type f -name '*.Rmd')
OUT_DIR := docs

all: pdf docx html wordcount.pdf

pdf: $(OUT_DIR)/thesis.tex

docx: $(OUT_DIR)/thesis.docx

html: $(OUT_DIR)/index.html

$(OUT_DIR)/thesis.tex: $(RMD)
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"

$(OUT_DIR)/thesis.docx: $(RMD)
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_word')"

$(OUT_DIR)/index.html: $(RMD)
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_gitbook')"

wordcount.txt: $(OUT_DIR)/thesis.tex
	prettytc -c -l $(OUT_DIR)/wordcount.txt $(OUT_DIR)/thesis.tex

wordcount.pdf: wordcount.txt R/plot_wordcount.R
	Rscript R/plot_wordcount.R
