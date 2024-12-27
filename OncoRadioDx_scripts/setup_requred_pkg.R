# Set the default library path
.libPaths("~/R/x86_64-pc-linux-gnu-library/4.1")

# Set repositories
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Function to check and install packages if necessary
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Load necessary libraries and install if missing
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

BiocManager::install(version = "3.14")

# List of required packages from CRAN and Bioconductor
cran_packages <- c("matrixStats", "dplyr", "grDevices", "bootstrap", "caret")
bioc_packages <- c("preprocessCore", "limma", "impute", "GenomicRanges", 
                   "DESeq2", "survcomp", "genefu", "rmeta", "Biobase", 
                   "org.Hs.eg.db", "conflicted", "biomaRt", "iC10", "AIMS")

# Install missing CRAN packages
for (pkg in cran_packages) {
  install_if_missing(pkg)
}

# Install missing Bioconductor packages
for (pkg in bioc_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    BiocManager::install(pkg)
  }
}

# Load the libraries
suppressPackageStartupMessages(suppressWarnings({
  lapply(c(cran_packages, bioc_packages), library, character.only = TRUE)
}))

# Resolve conflicts by preferring specific functions
conflict_prefer("select", "dplyr") 
conflict_prefer("plotMA", "limma")
conflict_prefer("plotMA", "DESeq2") 
conflict_prefer("combine", "BiocGenerics") 
conflict_prefer("intersect", "dplyr") 
conflict_prefer("setdiff", "dplyr") 
conflict_prefer("union", "dplyr") 
conflict_prefer("first", "dplyr") 
conflict_prefer("rename", "dplyr") 
conflict_prefer("collapse", "dplyr") 
conflict_prefer("desc", "dplyr") 
conflict_prefer("slice", "dplyr")
