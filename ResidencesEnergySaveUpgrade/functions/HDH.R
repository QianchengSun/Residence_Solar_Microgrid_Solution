# Heating degree hours  -------------

heating_degree_hours <- function(T_in, heating_month, weather_data_file_path, n_years, hour_interval){
  # Description:
  # heating_degree_hours() is a function that used to obtain the heating degree hours during certain period

  # Note:
  # Before use this function, please change the column names
  # for any column represent for month, please change into "Month"
  # for any column represent for temperture, please change into "Temperature"

  # arguments:
  # Input:
  #     T_in : the indoor temperature, unit F
  #     heating_month: the month that use gas / electric heating, vector
  #     weather_data_file_path : the file path that store the TMY weather data, usually is the .csv file, string
  #     n_years : number of years that included in the weather data file, integer
  #     hour_interval : number of time interval in an hour, for example, if the data is 30 minutes time interval, then hour_interval = 2
  #                     integer

  # Output:
  #     HDH: heating degree hours

  # Reference:
  # 1. https://www.sciencedirect.com/topics/engineering/cooling-degree-hour
  # 2. https://en.wikipedia.org/wiki/Heating_degree_day


  T_in_C <- (T_in - 32) * 5 / 9
  # outdoor temperautre
  T_out <- NA
  # Indoor and outdoor temperature difference
  delta_T <- NA
  heating_hours <- NA
  # read file
  weather_data <- read.csv(weather_data_file_path)

  for (i in 1:length(heating_month)){
    print(i)
    month_weather_data <- weather_data[which(weather_data$Month == heating_month[i]), ]

    heating_hours[i] <- length(which(month_weather_data$Temperature < T_in_C)) / (n_years * hour_interval)

    # convert C into F
    T_out[i] <- mean(month_weather_data$Temperature[which(month_weather_data$Temperature < T_in_C)]) * 9/5 + 32
    # temperature difference
    delta_T[i] <- T_in - T_out[i] # unit F

    # heating degree hours
    HDH <- sum(delta_T * heating_hours) / 1000
  }

  return (HDH)
}
