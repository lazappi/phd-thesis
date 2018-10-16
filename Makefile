all: pdf docx html

pdf:
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_pdf')"

docx:
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_word')"

html:
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_gitbook')"
