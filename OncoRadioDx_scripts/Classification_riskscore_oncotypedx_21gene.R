#!/usr/bin/env Rscript

# Source the setup_requred_pkg.R script 
source("./setup_requred_pkg.R")

args <- commandArgs(trailingOnly = TRUE)
oncodx_output_dir <- args[length(args)]

# Construct the full path to the RDS file 
rds_file_path <- file.path(oncodx_output_dir, "oncotypedx_norm_expression_data.rds")

data(sig.oncotypedx)
dannotation <- sig.oncotypedx[,c("symbol", "EntrezGene.ID")]

dannotation$symbol <-  gsub("CTSL2", "CTSV", dannotation$symbol) 
# Rename the row name instead of "CTSL2" is "CTSV" (the alternative name)
rownames(dannotation)[rownames(dannotation) == "CTSL2"] <- "CTSV"

normalized_expression <- readRDS(rds_file_path)
print(colnames(normalized_expression))
print(rownames(normalized_expression))
RISK_SCORE_results <- oncotypedx(data = normalized_expression, 
                                 annot = dannotation, 
                                 do.mapping = T)




##### Make an Output to pdf
# RULES #
# indicating low risk (RS < 18), intermediate risk (RS 18–30), or high risk (RS ≥ 31) of disease recurrence. Low risk patients are recommended to receive endocrine-modulating therapy (tamoxifen or aromatase inhibitors) only, and high risk patients are recommended to receive both endocrine-modulating therapy and adjuvant chemotherapy
generate_pdfs <- function(nums) {
  # seq_along(nums) to iterate over the indices and referenced the elements correctly.
  for (i in seq_along(nums)) {
    num <- nums[i]
    name <- names(nums)[i]
      # Determine the file name and text based on the value of num
      if (num > 30) {
        file_name <- file.path(oncodx_output_dir, paste0("output_", name, "_HR.pdf"))
        pdf_text <- paste0("The risk score is ",num , "%","(> 30%), ERGO it is a HIGH RISK")
      } else if (num >= 18 && num <= 30) {
        file_name <- file.path(oncodx_output_dir, paste0("output_", name, "_IntR.pdf"))
        pdf_text <- paste0("The risk score is ",num , "%","(18%–30%), ERGO it is a INTERMEDIATE RISK")
      } else {
        file_name <- file.path(oncodx_output_dir, paste0("output_", name, "_LR.pdf"))
        pdf_text <- paste0("The risk score is ",num , "%","(<18%), ERGO it is a LOW RISK")
      }

    
      # Create the PDF file
      pdf(file_name)
      plot.new()  # Creates a new blank plot
      
      # text(0.5, 0.5, pdf_text, cex = 2)  # Add text to the plot
      # Wrap the text to fit the page width
      wrapped_text <- strwrap(pdf_text, width = 40)
      text_y_positions <- seq(0.5, 0.5 - 0.05 * (length(wrapped_text) - 1), by = -0.05)
      
      # Adjust text size (cex parameter)
      for (j in seq_along(wrapped_text)) {
        text(0.5, text_y_positions[j], wrapped_text[j], cex = 1.5)
      }
      
      dev.off()  # Close the PDF file
  }

}

# Example usage with a numeric vector
num_vector <- c(RISK_SCORE_results$score)
#patient_name <- names(num_vector)
generate_pdfs(num_vector)