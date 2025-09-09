# needed libraries
libs <- c(
  "tidyverse", "stringr", "httr", "sf", "giscoR", "scales"
)

#check if libraries are installed and install missing ones
installed_libs <- libs %in% rownames(installed.packages())
if (any(installed_libs==FALSE)) {
  install.packages(libs[!installed_libs])
}


