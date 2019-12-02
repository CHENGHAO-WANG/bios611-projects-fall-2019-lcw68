.PHONY: project3
project3:
	docker image build -t project_3 .
	python Proj3_wrangling.ipynb
	Rscript R_plot.R
	Rscript -e "library(rmarkdown); rmarkdown::render('project3.Rmd', 'html_document')"  && mv project3.html ../results
