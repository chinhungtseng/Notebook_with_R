#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
message(sprintf("Hello %s", args[1L]))

# Reference:
# https://stackoverflow.com/questions/750786/whats-the-best-way-to-use-r-scripts-on-the-command-line-terminal