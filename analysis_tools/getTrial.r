#! /usr/bin/env Rscript

################################################################################
# requires r-cran-ggplot2, r-cran-plyr, r-cran-hdf5
################################################################################

args <- commandArgs(trailingOnly=TRUE)

require("ggplot2")
require("reshape2")
require("plyr")
require("hdf5")

hdfname <- "test.h5"
plotname <- "test.pdf"

trialnumber <- 1
npoints <- 1000

file <- h5file("test.h5", "r")
h5close(file)
