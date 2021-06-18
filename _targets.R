library(targets)
library(tarchetypes)


# Functions
source("biostamp/intake-functions.R")

# Set target-specific options such as packages.
tar_option_set(
	packages = c(
		# Personal
		"card", "aim",
		# Tidyverse/models
		"tidyverse", "tidymodels", "readxl", "haven", "janitor",
		# Tables / figures
		"gt", "gtsummary", "labelled",
		# Stats
		"lme4", "Hmisc"
	),
	error = "workspace"
)

# Define targets
targets <- list(

	# Files ====
	tar_file(biostamp_folder, "../../data/biostamp/proc_data/"),

	# Intake ====
	tar_target(biostamp_data, get_biostamp_data(biostamp_folder)),

	# Report ====
	tar_render(biostamp_prelim, "biostamp/prelim.Rmd")
)
