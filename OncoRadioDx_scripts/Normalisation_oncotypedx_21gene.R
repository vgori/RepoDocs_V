#!/usr/bin/env Rscript

# Source the setup_requred_pkg.R script 
source("./setup_requred_pkg.R")
 

options(echo=FALSE)
# Retrieve command-line arguments
args <- commandArgs(trailingOnly = TRUE)

file_paths <- args[1:(length(args) - 1)]
oncodx_output_dir <- args[length(args)]

# Print arguments to verify
print(file_paths)# Function to create file variables dynamically

create_file_variables <- function(args) {
  # Initialize an empty list to store file names
  file_list <- list()
  
  # Loop through the arguments and assign them to list elements
  for (i in seq_along(args)) {
    file_list[[paste0("file", i)]] <- args[i]
  }
  
  # Return the list of file variables
  return(file_list)
}

# Read files with gene_counts as args
# file_vars <- create_file_variables(c("genecount_table_FC1.tsv", "genecount_table_FC2.tsv"))
file_vars <- create_file_variables(file_paths)


# 21 Gene Names sets for OncotypeDX
housekeeping_genes <- c("GAPDH",  "RPLP0",  "GUSB" ,  "TFRC")
# instead of "CTSL2" is "CTSV" (the alternative name)
target_genes <- c("MKI67",  "AURKA",  "BIRC5",  "CCNB1",  "MYBL2" , "MMP11" , "CTSV",  "GRB7",   "ERBB2" , "ESR1",   "PGR",    "BCL2" ,"SCUBE2" ,"GSTM1" , "CD68",   "BAG1",   "ACTB")
#patient_names <- c("Newone_P001", "Newone_P002", "Newone_P003")


# Function to remove "transcripts_" from the GeneName column
rm_trname_part <- function(df) {
  df$GeneName <- gsub("transcripts_", "", df$GeneName)
  return(df)
}

# Load and process gene count tables for each patient
process_patient_data <- function(file) {
  df <- read.csv(file, sep=",")
  df <- rm_trname_part(df)
  return(df)
}

# Load and process all patient data
patient_data <- lapply(file_vars, process_patient_data)

# Align tables by min CycleNumber
n_cycle <- min(sapply(patient_data, function(df) length(levels(as.factor(df$CycleNumber)))))

# Extract CopyNumbers data for the n_cycle
patient_data <- lapply(patient_data, function(df) {
  df <- df[df$CycleNumber == n_cycle, ]
  df <- df[, !names(df) %in% "CycleNumber"]
  return(df)
})


# Join all patient data 
expression_data <- Reduce(function(x, y) inner_join(x, y, by = "GeneName"), patient_data) 

# Assign column names (assuming patient_names is predefined or derived from file names) 
# have to be names of Flowcellsfile_vars gsub("genecount_table_|\\.tsv","",file_vars[1])

# Extract flowcell names from the file paths 
flowcell_names <- sapply(file_vars, function(file) { 
   basename(dirname(file)) 
  }) 
# Construct patient names with extracted flowcell names 
patient_names <- c("GeneName", sapply(1:length(flowcell_names), function(i) { 
  paste0("Patient", i, "_", flowcell_names[i]) 
  })
  )

colnames(expression_data) <- patient_names 

# Remove leading/trailing whitespace from column names 
expression_data$GeneName <- trimws(expression_data$GeneName) 


# NORMALIZATION with housekeeping genes

t_expression_data <- as.data.frame(t(expression_data[,-1]))
colnames(t_expression_data) <- expression_data$GeneName



# Calculate geometric mean
geometric_mean <- function(x) {
  exp(mean(log(x+0.0001), na.rm = TRUE))
}

normalization_factors <- apply(t_expression_data[, c(housekeeping_genes)], 1, geometric_mean)

# We can use instead of geometric mean mathematical mean or median 
#normalization_factors <- apply(t_expression_data[, c(housekeeping_genes)], 1, median)

# Create variable for Normalize target genes
normalized_expression <- t_expression_data #[, c(target_genes)]

# The sweep function divides/substract each expression value of the target genes by the corresponding normalization factor for each row (sample), normalizing the expression values.
normalized_expression[, target_genes] <- sweep(t_expression_data[, target_genes], 1, normalization_factors, FUN = "-")

# Write the output to a CSV file 
output_file_csv <- "oncotypedx_norm_expression_data.csv" 
output_file_rds <- "oncotypedx_norm_expression_data.rds" 

write.csv(normalized_expression, file = file.path(oncodx_output_dir, output_file_csv), row.names = TRUE) 
# Write the output to a rds R object to pass it to Classification script 
saveRDS(normalized_expression, file= file.path(oncodx_output_dir, output_file_rds))
