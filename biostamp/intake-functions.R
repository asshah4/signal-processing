# Get files
get_biostamp_data <- function(folder) {

	# Successfully analyzed data
	analyzed <- list.files(
		path = folder,
		recursive = TRUE,
		full.names = TRUE,
		pattern = ".HRV.*.csv"
	) %>%
		map_dfr(., read_csv) %>%
		clean_names() %>%
		rename(patid = pat_id) %>%
		mutate(
			hf = log(hf),
			lf = log(lf),
			rmssd = log(rmssd)
		)

	# Failed analysis
	status <- list.files(
		path = folder,
		recursive = TRUE,
		full.names = FALSE,
		pattern = ".txt"
	) %>%
		str_split(., pattern = "\\/", simplify = TRUE) %>%
		as_tibble() %>%
		rename(patid = V1, status = V2) %>%
		mutate(status = gsub(pattern = "\\.txt$", "", status))

	# Return
	biostamp_data <- list(
		analyzed = analyzed,
		status = status
	)

}

