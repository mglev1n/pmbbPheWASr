# WARNING - Generated by {fusen} from dev/flat_pmbb_phewas.Rmd: do not edit by hand

#' Render a PheWAS report from existing genotype mask and PheWAS output
#'
#' This function renders an HTML report from pre-saved genotype mask and PheWAS output files or R objects.
#'
#' @param mask_output Path to the saved genotype output for each mask or an R list object containing the output of [pmbbPheWASr::pmbb_extract_genotype_masks]
#' @param phewas_output Path to the saved PheWAS output dataframe or an R dataframe object containing the output of [pmbbPheWASr::run_pmbb_phewas]
#' @param output_file Full path to save the HTML report
#' @param template_path Optional path to a custom Quarto template file. If not provided, the default template will be used. This template should be a Quarto document with the necessary code to render the PheWAS report, and must be located in the top directory of the current project. An example template can be generated using: `usethis::use_template("combined_phewas_template.qmd", save_as = "combined_phewas_template.qmd", package = "pmbbPheWASr")`, which will be saved in the current working directory.
#' @param ... Additional named parameters to pass to the Quarto document
#'
#' @return The function renders an HTML report and returns silently
#'
#' @export
#' @examples
#' \dontrun{
#' render_pmbb_phewas_report(
#'   phewas_output = cftr_phewas_res,
#'   mask_output = cftr_mask_res,
#'   output_file = "CFTR_pheWAS_report.html"
#' )
#' }
render_pmbb_phewas_report <- function(mask_output, phewas_output, output_file, template_path = NULL, ...) {
  # Check if mask_output is an R object
  if (is.list(mask_output)) {
    temp_mask_file <- tempfile(fileext = ".rds")
    saveRDS(mask_output, temp_mask_file)
    mask_output <- temp_mask_file
  }

  # Check if phewas_output is an R object
  if (is.data.frame(phewas_output)) {
    temp_phewas_file <- tempfile(fileext = ".rds")
    saveRDS(phewas_output, temp_phewas_file)
    phewas_output <- temp_phewas_file
  }

  quarto_render_dir <- fs::path_temp()
  
  cli::cli_progress_step("Copying files to temporary directory")
  
  if (!is.null(template_path)) {
    if (!file.exists(template_path)) {
      cli::cli_abort("{.arg {template_path}} does not exist. Please provide a valid path to a Quarto template file.")
    }
    fs::file_copy(template_path, fs::path(quarto_render_dir, basename(template_path)), overwrite = TRUE)
    template_path <- fs::path(quarto_render_dir, basename(template_path))
  } else {
    cli::cli_alert_info("No results template provided. Using default template.")
    template_path <- fs::path(quarto_render_dir, ".combined_phewas_template.qmd")
    usethis::use_template(template = "combined_phewas_template.qmd", save_as = template_path, package = "pmbbPheWASr")
  }

  if (!file.exists(mask_output)) {
    cli::cli_abort("{.arg {mask_output}} does not exist. Please provide a valid path to a genotype mask results file.")
  }

  if (!file.exists(phewas_output)) {
    cli::cli_abort("{.arg {phewas_output}} does not exist. Please provide a valid path to a PheWAS results file.")
  }
  cli::cli_progress_step("Rendering report")
  withr::with_dir(
    quarto_render_dir,
    quarto::quarto_render(
      input = fs::path_abs(template_path),
      output_format = "html",
      execute_params = list(
        mask_results = fs::path_abs(mask_output),
        phewas_results = fs::path_abs(phewas_output),
        ...
      ),
      output_file = basename(output_file)
    )
  )

  fs::dir_create(fs::path_dir(output_file))

  fs::file_move(fs::path(quarto_render_dir, basename(output_file)), output_file)

  # if (file.exists(".combined_phewas_template.qmd")) {
  #   fs::file_delete(".combined_phewas_template.qmd")
  # }
  
  # Return the path to the generated report file
  cli::cli_alert_success("PheWAS report rendered successfully: {.val {output_file}}")
}
