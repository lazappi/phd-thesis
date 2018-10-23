RMD := $(shell find . -type f -name '*.Rmd')

all: pdf docx html output/wordcount.txt

pdf: output/thesis.tex

docx: output/thesis.docx

html: output/index.html

output/thesis.tex: $(RMD)
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_pdf')"

output/thesis.docx: $(RMD)
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_word')"

output/index.html: $(RMD)
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_gitbook')"

output/wordcount.txt: output/thesis.tex
	prettytc -c -l output/wordcount.txt output/thesis.tex
