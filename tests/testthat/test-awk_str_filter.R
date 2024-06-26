# WARNING - Generated by {fusen} from dev/flat_pmbb_phewas.Rmd: do not edit by hand

test_that("awk_str_filter works", {
  ldlr_file <- "ldlr_df.tsv"
  if (!file.exists(ldlr_file)) {
    # The path to use during dev in the flat file
    ldlr_file <- file.path("tests", "testthat", ldlr_file)
    if (!file.exists(ldlr_file)) {
      stop(ldlr_file, " does not exist")
    }
  }

  res <- awk_str_filter(
    filename = ldlr_file,
    filter_col = "Gene.refGene",
    filter_str = c("LDLR")
  )
  expect_true(inherits(awk_str_filter, "function"))
  expect_true(tibble::is_tibble(res))
})
