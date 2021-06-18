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
		full.names = TRUE,
		pattern = "Removed.*.csv"
	) %>%
		map_dfr(., read_csv) %>%
		clean_names() %>%
		rename(patid = pat_id)

	# Return
	biostamp_data <- list(
		analyzed = analyzed,
		status = status
	)

}

# Write files
write_biostamp_data <- function(biostamp_data) {

	biostamp_data$analyzed %>%
		write_csv(., "./biostamp/summary_data.csv")

	# Return
	return("./biostamp/summary_data.csv")

}
