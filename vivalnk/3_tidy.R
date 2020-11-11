#!/usr/bin/env Rscript

#### HRV Transformation ####

# Data
df <- df_hrv

# Transform HRV appropriately
df$BPM <- (df$NN/1000/60)^-1
df$PNN50 <- df$PNN50 * 100
df$HF %<>% log()
df$LF %<>% log()
df$VLF %<>% log()
df$TP %<>% log()

df_hrv <- df

#### HRV Time Series ####

# Data frame
df <- df_hrv

# Convert time series 
start_time <- today() + hms("13:34:00")
cath_time <- as.POSIXct(today() + hms("14:25:00"))
df$time <- start_time + dseconds(df$time)
df$time %<>% as.POSIXct()

df_hrv <- df