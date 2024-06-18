% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_pmbb_phewas.R
\name{run_pmbb_phewas}
\alias{run_pmbb_phewas}
\title{Run a PheWAS on PMBB data}
\usage{
run_pmbb_phewas(
  mask_genotypes_list,
  phecode_file,
  covariate_files,
  populations = c("ALL"),
  covariate_cols,
  covariate_population_col = NULL,
  phenotype_case_count = 2,
  ...
)
}
\arguments{
\item{mask_genotypes_list}{A named list, where each element contains a named element called \code{genotypes} which contains \code{PMBB_ID} and \code{genotype} columns.}

\item{phecode_file}{Path to PMBB phenotype file or a dataframe containing phenotype data used to run PheWAS}

\item{covariate_files}{Path to PMBB covariate file(s) or a dataframe containing covariate data used to run PheWAS. If multiple files are provided, they will be joined by \code{PMBB_ID}, and values for duplicated columns will be preserved from the from the file that is specified earlier.}

\item{populations}{A character vector of populations to run PheWAS on. Default is \code{c("ALL")}}

\item{covariate_cols}{Vector of columns in the covariate file or dataframe that should be used as covariates in the PheWAS}

\item{covariate_population_col}{Column containing population labels in the covariate file or dataframe, required if \code{populations} is not \code{ALL}}

\item{phenotype_case_count}{The minimum number of codes required to be considered a case (Default: 2)}

\item{...}{Additional arguments passed to \code{\link[PheWAS:phewas]{PheWAS::phewas()}}}
}
\value{
A \code{\link[tibble:tibble]{tibble::tibble()}} containing the results of the PheWAS for each population and mask
}
\description{
This function runs a PheWAS on PMBB data, using genotype information and paths to PMBB files containing phenotype and covariate data. The function ideally accepts genotype information from the \code{pmbb_extract_genotype_masks} function, but can accept any genotype information of the format \code{list(mask_name = list(genotypes = data.frame(PMBB_ID = character(), genotype = character())))}
}
\examples{
\dontrun{
# Extract genotypes for a series of masks
ldlr_mask_res <- pmbb_extract_genotype_masks(
  gene = "LDLR",
  annotation_file = "/project/PMBB/PMBB-Release-2020-2.0/Exome/Variant_annotations/PMBB-Release-2020-2.0_genetic_exome_variant-annotation-counts.txt",
  gene_col = "Gene.refGene",
  masks = list(
    plof_0.001 = list(ExonicFunc.ensGene = "== 'stopgain'", gnomAD_exome_ALL = "< 0.001"),
    common = list(gnomAD_exome_ALL = "> 0.01")
  ),
  mask_operator = list(
    plof_0.001 = "burden",
    common = "single"
  ),
  variant_id_col = ID,
  effect_allele_col = Alt,
  plink_bin = "/project/voltron/Applications/PLINK/plink2_linux_avx2_20230607/plink2",
  bfile = "/project/PMBB/PMBB-Release-2020-2.0/Exome/pVCF/all_variants/PMBB-Release-2020-2.0_genetic_exome_GL")

# Run a PheWAS
phewas_res <- run_pmbb_phewas(
  mask_genotypes_list = ldlr_mask_res,
  phecode_file = "/project/PMBB/PMBB-Release-2020-2.0/Phenotype/2.3/PMBB-Release-2020-2.3_phenotype_PheCode-matrix.txt",
  covariate_files = c("/project/PMBB/PMBB-Release-2020-2.0/Phenotype/2.3/PMBB-Release-2020-2.3_covariates.txt", "/project/PMBB/PMBB-Release-2020-2.0/Phenotype/2.1/PMBB-Release-2020-2.1_phenotype_covariates.txt"),
  populations = c("ALL", "EUR"),
  covariate_population_col = Class,
  covariate_cols = c(Age = Age_at_Enrollment, Sex = Gen_Sex, dplyr::starts_with("Genotype_PC"))
)
}
}