# Tools and techniques for single-cell RNA sequencing data

[![Travis-CI Build Status](https://travis-ci.com/lazappi/phd-thesis.svg?branch=master)](https://travis-ci.com/lazappi/phd-thesis)
[![DOI](https://zenodo.org/badge/153196642.svg)](https://zenodo.org/badge/latestdoi/153196642)

![Cover image](/figures/cover.png)

This repository contains my PhD thesis _"Tools and techniques for single-cell
RNA sequencing data"_. The HTML version is available at
http://lazappi.github.io/phd-thesis.

## Abstract

RNA sequencing of individual cells allows us to take a snapshot of the dynamic
processes within a cell and explore differences between cell types. As this
technology has developed over the last few years it has been rapidly adopted by
researchers in areas such as developmental biology, and many single-cell RNA
sequencing datasets are now available. Coinciding with the development of
protocols for producing single-cell RNA sequencing data there has been a
simultaneous burst in the development of computational analysis methods. My
thesis explores the computational tools and techniques for analysing
single-cell RNA sequencing data. I present a database that charts the release
of analysis software, where it has been published and what it can be used for,
as well as a website that makes this information publicly available. I also
present two of my own tools and techniques including Splatter, a software
package for easily simulating single-cell datasets from multiple models, and
clustering trees, a visualisation approach for inspecting clustering at
multiple resolutions. In the final part of my thesis I perform analysis of a
dataset from kidney organoids to demonstrate and compare some current analysis
methods. Taken together, my thesis covers many aspects of the tools and
techniques for single-cell RNA sequencing by describing the approaches that are
available, presenting software that can help in developing and evaluating
methods, introducing an approach for aiding one of the most common analysis
tasks, and showing how tools can be used to extract meaning from a real
dataset.

## Related work

* **scRNA-tools** - A database of software tools for analysing single-cell RNA
  sequencing data ([Website](https://scrna-tools.org),
  [GitHub](https://github.com/Oshlack/scRNA-tools),
  [Publication](https://doi.org/10.1371/journal.pcbi.1006245))
* **Splatter** - An R package for the simple simulation of single-cell RNA
  sequencing data ([Bioconductor](http://bioconductor.org/packages/splatter/),
  [GitHub](https://github.com/Oshlack/splatter),
  [Publication](https://doi.org/10.1186/s13059-017-1305-0))
* **clustree** - An R package for producing clustering tree visualisation to
  show changes in clustering as resolution increases
  ([CRAN](https://CRAN.R-project.org/package=clustree),
  [GitHub](https://github.com/lazappi/clustree),
  [Publication](https://doi.org/10.1093/gigascience/giy083))
* **Combes organoid analysis** - Analysis of single-cell RNA sequencing data
  from kidney organoids to identify and profile the cell types present
  ([Website](https://oshlacklab.com/combes-organoid-paper/),
  [GitHub](https://github.com/Oshlack/combes-organoid-paper),
  [Publication](https://doi.org/10.1186/s13073-019-0615-0))
* **PhD analysis** - Re-analysis of the Combes organoid data to explore the effect
  of different tool and parameter choices during analysis
  ([Website](https://lazappi.github.io/phd-thesis-analysis/),
  [GitHub](https://github.com/lazappi/phd-thesis-analysis))
