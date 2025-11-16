#!/usr/bin/env Rscript
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#Reading sas7bdat, searching and generate csv file
#!/usr/bin/env Rscript
# 入力: <input.sas7bdat> <column> <value> <output_xpt>
# 出力: <output_base>.xpt（中間ファイル）
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

req_pkgs <- c("haven", "dplyr")
missing <- req_pkgs[!req_pkgs %in% installed.packages()[, "Package"]]
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")
#install.packages(c("haven","dplyr","readr"))

suppressPackageStartupMessages({ library(haven); library(dplyr) })

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  cat("Usage: Rscript filter_sas_to_xpt.R <input.sas7bdat> <column> <value> <output.xpt>\n")
#  quit(status=1)
}

#in_path <- args[1]; col <- args[2]; val <- args[3]; out_xpt <- args[4]
in_path <- "/studies/STD0001/s1reporting1_beatrice/01_input/ae.sas7bdat"
col <- "AETERM"
val <- "発熱"
out_xpt <- "/studies/STD0001/s1reporting1_beatrice/02_output/fever.xpt"
  
stopifnot(file.exists(in_path))

df <- read_sas(in_path)

# 文字列列を Shift_JIS とみなして UTF-8 に変換
# iconv で変換できない文字は NA にする（sub=""で除去することも可）
#df <- df %>%
#  mutate(across(
#    where(is.character),
#    ~ iconv(.x, from = "CP932", to = "UTF-8", sub = NA)
#  ))

if (!col %in% names(df)) stop(sprintf("Column %s not found.", col))

trim_ws <- function(x) if (is.character(x)) trimws(x) else x
df <- df %>% mutate(across(where(is.character), trimws))
filtered <- dplyr::filter(df, .data[[col]] == val)
#filtered <- df

dir.create(dirname(out_xpt), showWarnings = FALSE, recursive = TRUE)
write_xpt(filtered, out_xpt, version = 8)  # v5/v8選択可
cat("Wrote XPT: ", out_xpt, "\n")
