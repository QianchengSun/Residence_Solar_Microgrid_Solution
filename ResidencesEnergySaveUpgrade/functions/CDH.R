# Cooling degree hours --------------------
cooling_degree_hours <- function(T_in, cooling_month, weather_data_file_path, n_years, hour_interval){
  # Description:
  # cooling_degree_hours() is a function that used to obtain the heating degree hours during certain period
  # the function could be change if needed

  # Note:
  # Before use this function, please change the column names
  # for any column represent for month, please change into "Month"
  # for any column represent for temperture, please change into "Temperature"

  # arguments:
  # Input:
  #     T_in : the indoor temperature, unit F
  #     cooling_month: the month that use gas / electric heating, vector
  #     weather_data_file_path : the file path that store the TMY weather data, usually is the .csv file, string
  #     n_years : number of years that included in the weather data file, integer
  #     hour_interval : number of time interval in an hour, for example, if the data is 30 minutes time interval, then hour_interval = 2
  #                     integer

  # Output:
  #     CDH: cooling degree hours

  # Reference:
  # 1. https://www.sciencedirect.com/topics/engineering/cooling-degree-hour
  # 2. https://en.wikipedia.org/wiki/Heating_degree_day

  # convert C in F 
  T_in_C <- (T_in - 32) * 5 / 9

  T_out <- NA

  delta_T <- NA

  weather_data <- read.csv(weather_data_file_path)

  for (i in 1:length(cooling_month)){
    month_weather_data <- weather_data[which(weather_data$Month == cooling_month[i]), ]

    cooling_hours <- length(which(month_weather_data > T_in_C)) / (n_years * hour_interval)
    # convert C into F
    T_out[i] <- mean(month_weather_data$Temperature[which(month_weather_data$Temperature > T_in_C)]) * 9/5 + 32
    # temperature difference
    delta_T[i] <-  T_out[i] - T_in # unit F
    # cooling degree hours
    CDH <- sum(delta_T * cooling_hours) / 1000
  }

  return (CDH)

}
