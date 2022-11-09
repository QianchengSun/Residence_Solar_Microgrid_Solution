# Package Introduction ---------------------------
# This is package is used for calculating the energy upgrade options for residences, which include the result for annual savings and payback years.

# The upgrade options includes:
# 1. Heating system
# 2. Cooling system
# 3. Water heater 
# 4. Heat pump 
# 5. Envelop improvement



# Heating / Cooling degree hours calculation ------------------------------
# Note:
# before calculate the upgrade options the heating degree hours (HDH) & cooling degree hours (CDH) should be obtained.
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


# Rank order --------------------------------
rank_order <- function(target_column, max_value, min_value){
  # Description:
  # rank_order is a function that automatically generate rank index value for upgrade options
  
  # Note:
  # if the rank index (for example, rank = 1) is small, that means the best
  # if the rank index (for example, rank = 10) is big, that means the worst
  # if the rank index is 11, which means there are NA value in the target column for that specific row
  # if you want to automatically generate the rank index for the residential house, you could set yo the max value or min value as NA
  
  # Arguments:
  # Input: 
  #   target_column: the target column that need to create rank index value
  #   max_value (the excepted max value): max value of the target column, if want to generate rank index value automatrically 
  #             the max_value = NA will be input for this argument, otherwise, you can define the max_value for the range by manual, for example, max_value = 5
  #           
  #   min_value (the excepted min value): min value of the target column, if want to generate rank index value automatrically 
  #             the min_value = NA will be input for this argument, otherwise, you can define the min_value for the range by manual, for example, min_value = 5 
  
  # Output:
  #   rank: rank index for the target column
  
  rank <- NA
  
  target_column_no_NA <- ifelse(is.na(target_column), target_column[c(which(!is.na(target_column)))], target_column)
  # Remove Inf value 
  target_column_no_NA <- ifelse(target_column_no_NA == Inf, target_column_no_NA[c(which(target_column_no_NA != Inf))], target_column_no_NA)    
  
  max_value <- ifelse(is.na(max_value),max(target_column_no_NA), max_value)
  min_value <- ifelse(is.na(min_value),max(target_column_no_NA), min_value)
  
  # Need to add expected max and min value to define the range for the K means
  target_column_no_NA <- target_column_no_NA[c(which(target_column_no_NA < max_value & target_column_no_NA > min_value))]
  
  point_value <- seq(min_value, max_value, by = (max_value - min_value) /10)
  
  # rank the target column 
  for (i in 1:length(target_column)){
    # if NA value appeared, define the rank value as NA
    if (is.na(target_column[i])){
      rank[i] <- 11
    }else{
      if(target_column[i] <= point_value[1]){
        rank[i] <- 1
      }else if (target_column[i] >= point_value[1] & target_column[i] < point_value[2]){
        rank[i] <- 2
      }else if (target_column[i] >= point_value[2] & target_column[i] < point_value[3]){
        rank[i] <- 3
      }else if (target_column[i] >= point_value[3] & target_column[i] < point_value[4]){
        rank[i] <- 4
      }else if (target_column[i] >= point_value[4] & target_column[i] < point_value[5]){
        rank[i] <- 5
      }else if (target_column[i] >= point_value[5] & target_column[i] < point_value[6]){
        rank[i] <- 6
      }else if (target_column[i] >= point_value[6] & target_column[i] < point_value[7]){
        rank[i] <- 7
      }else if (target_column[i] >= point_value[7] & target_column[i] < point_value[8]){
        rank[i] <- 8
      }else if (target_column[i] >= point_value[8] & target_column[i] < point_value[9]){
        rank[i] <- 9
      }else{
        rank[i] <- 10
      }
    }
  }
  return (rank)
}


# Gas heated house ------------------------


# Heating system (gas heated house) ----------------
high_efficiency_gas_heating <- function(eta_low, 
                                        eta_high, 
                                        annual_gas_heating, 
                                        square_footage, 
                                        heating_degree_hours, 
                                        gas_price, 
                                        typical_heating_system_price, 
                                        high_efficiency_heating_system_price){
  # Description:
  # high_efficiency_gas_heating() is function that could help to calculate the energy consumption after change into the high efficiency heating system for gas heated house
  # By using this function, 
  # 1) the annual energy consumption by using high efficiency heating system could be obtained
  # 2) the annual energy consumption saving for using the high efficiency heating system could be obtained
  # 3) payback years for using high efficiency heating system
  # 4) energy consumption intensity on unit square footage
  
  # Arguments:
  # Input:
  #   eta_low: efficiency value for low efficiency heating system
  #   eta_high: efficiency value for high efficiency heating system
  #   annual_gas_heating: residential annual gas heating without changing the heating efficiency (CCF)
  #   square_footage: square footage for residential house
  #   heating degree hours: heating degree hours that generated by using HDH function
  #   gas_price : natural gas price for local area
  #   typical_heating_system_price: price for low efficiency (typical heating) system (USD)
  #   high_efficiency_system_price: price for high efficiency system (USD)
  
    
  # Output:
  #   heating_U_value: Byproduct
  #   annual_gas_heating_high_efficiency: annual gas consumption after change into high efficiency heating system (CCF)
  #   annual_gas_heating_saving: annual gas consumption saving after change into high efficiency heating system (CCF)
  #   annual_gas_heating_USD: annual gas heating consumption saving convert into USD dollars (USD)
  #   normalized gas heating eta change: heating consumption intensity after change the efficiency
  #   high_efficiency_heating_system_payback: the payback years for installing the high efficiency heating system (yr)
  
  
  
  # dynamic U_value (unit kWh / K)
  # the calculated result for U_value is exactly the U_value as insulation value
  # the calculation for U_value is based on the calculation equation 
  # equation:
  # E_H <- (T_in - T_out) / eta_H * UAa * hr_H
  # ------>
  # E_H <- HDH / eta_H * UAa
  
  heating_U_value <- annual_gas_heating * 10 ^ 5 / 3413 * eta_low / heating_degree_hours # convert CCF to kWh, 
  
  # annual gas consumption change by increase the efficiency of heating system
  # annual_gas_heating with high efficiency saving
  annual_gas_heating_high_efficiency_saving <- abs(- heating_degree_hours / (eta_low ^ 2) * (eta_high - eta_low) * heating_U_value) # unit kWh
  
  # convert annual_gas_heating_high_efficiency from kWh into CCF
  # Note: 
  # could add unit option for future
  annual_gas_heating_high_efficiency_saving <- annual_gas_heating_high_efficiency_saving * 3413 / 10 ^ 5 # unit CCF
  # annual heating saving in USD with high efficiency heating
  annual_gas_heating_saving_USD <- annual_gas_heating_high_efficiency_saving * gas_price
  
  # annual gas heating consumption with high efficiency system 
  annual_gas_heating_high_efficiency <- annual_gas_heating - annual_gas_heating_high_efficiency_saving # unit CCF
 
  # normalized gas heating with efficiency change
  normalized_gas_heating_eta_change <-  annual_gas_heating_high_efficiency / square_footage
  
  # payback for installing high efficiency heating system
  high_efficiency_heating_system_payback <- (high_efficiency_heating_system_price - typical_heating_system_price) / annual_gas_heating_saving_USD
  
  # Unlike python, there is no way to return() multiple values by using 1 function
  # the list has to be created in order to generate multiple output at the same time
  high_efficiency_gas_heating_list <- list(heating_U_value, 
                                           annual_gas_heating_high_efficiency_saving, 
                                           annual_gas_heating_high_efficiency, 
                                           annual_gas_heating_saving_USD, 
                                           normalized_gas_heating_eta_change,
                                           high_efficiency_heating_system_payback)
  # output value
  return(high_efficiency_gas_heating_list)
  
}







# Cooling system (gas heated house) --------------------
# Note:
# the cooling system need to use SEER to do the calculation
# instead of using efficiency
high_efficiency_gas_cooling <- function(SEER_low,
                                        SEER_high,
                                        electric_price,
                                        annual_electric_cooling,
                                        square_footage,
                                        typical_SEER_system_price,
                                        high_SEER_cooling_system_price){
  
  # Description:
  # high_efficiency_gas_cooling() is a function that used to calculate the energy consumption savings after change into high efficiency cooling system 
  # and also calculate the payback years for upgrading the high efficiency cooling system
  
  # Arguments:
  #   Input:
  #     SEER_low: SEER value for low SEER cooling system
  #     SEER_high: SEER value for high SEER cooling system
  #     electric_price: price for local electricity price
  #     annual_electric_cooling: annual electric consumption in cooling (kWh)
  #     square_footage: square footage for residential house (ft^2)
  #     typical_SEER_system_price : price for typical (low) SEER cooling system (unit: USD)
  #     high_SEER_cooling_system_price: price for high SEER cooling system (unit: USD)
  
  #   Output:
  #     annual_electric_cooling_high_SEER_saving: annual electric consumption saving in cooling after upgrade the high efficiency cooling system (unit kWh)
  #     annual_electric_cooling_saving_USD: annual electric consumption savings in cooling after upgrade the high efficiency cooling system (unit USD)
  #     normalized_elecrtic_cooling_eta_change: cooling energy consumption intensity after upgrade into the high efficiency cooling system (unit kWh/ft^2)
  #     high_efficiency_cooling_system_payback: payback years for upgrading into the high efficiency cooling system (unit yr)
  
  
  # Cooling system should use SEER to do the calculation, instead of using efficiency
  # typical air conditioners have a SEER is from 13 to 21
  # Reference website:
  # https://www.trane.com/residential/en/resources/glossary/what-is-seer/
  
  
  # Obtain the Output cooling energy in Btu with low SEER
  Output_cooling_energy_btu <- SEER_low * annual_electric_cooling * 1000 # convert energy cooling from kWh into Wh
  # Obtain input electric energy Wh in high SEER
  Input_electric_energy_Wh <- Output_cooling_energy_btu / SEER_high
  # Convert Wh into kWh
  Input_electric_energy_kWh <- Input_electric_energy_Wh / 1000
  # annual electric savings with high SEER in kWh
  annual_electric_cooling_high_SEER_saving <- annual_electric_cooling - Input_electric_energy_kWh
  # annual electric savings with high SEER in USD
  annual_electric_cooling_saving_USD <- annual_electric_cooling_high_SEER_saving * electric_price
  # cooling consumption intensity by using high SEER cooling system (kWh/ft^2)
  normalized_electric_cooling_eta_change <- Input_electric_energy_kWh / square_footage
  # payback years for installing 
  high_efficiency_cooling_system_payback <- (high_SEER_cooling_system_price - typical_SEER_system_price) / annual_electric_cooling_saving_USD
  
  # generate list
  high_efficiency_gas_cooling_list <- list(annual_electric_cooling_high_SEER_saving,
                                           annual_electric_cooling_saving_USD,
                                           normalized_electric_cooling_eta_change,
                                           high_efficiency_cooling_system_payback)
  
  return(high_efficiency_gas_cooling_list)
  
}








# Heat pump (gas heated house) ---------------------------
heat_pump_gas <- function(heat_pump_price,
                          typical_heating_system_price,
                          typical_cooling_system_price,
                          heat_pump_SEER,
                          heat_pump_HSPF,
                          typical_cooling_SEER,
                          typical_heating_efficiency,
                          annual_gas_heating,
                          annual_electric_cooling,
                          gas_price,
                          electric_price){
  # Description:
  # heat_pump_gas() is a function that used for estimating the energy save or payback years for upgrading into heat pump
  # if using the heat pump, then the cooling and heating system could be instead, because heat pump can do heating and cooling at the same time.
  
  # Arguments:
  #   Input:
  #     heat_pump_price: price for high efficiency heat pump (USD)
  #     typical_heating_system_price: price for typical (low) efficiency heating system price (USD)
  #     typical_cooling_system_price: price for typical (low) efficiency cooling system price (USD)
  #     heat_pump_SEER: SEER value for heat pump cooling in summer (typically SEER is 21)
  #     heat_pump_HSPF: HSPF value for heat pump heating in winter (typically HSPF is 13)
  #     typical_cooling_SEER: SEER value for the typical (low) efficiency cooling system (typically SEER is 13 or 14)
  #     typical_cooling_efficiency: value of efficiency for typical (low) cooling system (typically cooling efficiency is 80%)
  #     annual_gas_heating: annual gas consumption in heating (CCF)
  #     annual_electric_cooling: annual electric consumption in cooling (kWh)
  #     gas_price: local natural gas price (USD/CCF)
  #     electric_price: local electric price (USD/kWh)  
  
  #   Output:
  #     heat_saving: savings in USD by using heat pump heating (USD)
  #     cooling_saving: savings in USD by using heat pump cooling (USD)
  #     total_annual_savings: total savings in USD by using heat pump doing cooling and heating (USD)
  #     heat_pump_payback: payback years for using heat pump (yr)
  
  
  # heat pump heating consumption in kWh
  # heating output by using typical heating system (CCF)
  typical_heating_output <- annual_gas_heating * typical_heating_efficiency
  # the comparison between heat pump and typical heating system in here is:
  # assuming the output heating is same, then compare the input energy consumption
  
  # calculate heat pump input consumption (electric)
  # 1 CCF = 10 ^ 5 Btu
  # For using heat pump in winter should use HSPF as calculation
  # HSPF = total heating output (Btu) / power input over same period (Wh)
  
  heat_pump_heating_input <- typical_heating_output * 10 ^ 5 / heat_pump_HSPF  / 1000 # convert CCF to Btu, then convert from Wh to kWh
  # heat pump saving
  # savings in heating (USD)
  heat_pump_heating_saving <- annual_gas_heating * gas_price - heat_pump_heating_input * electric_price
  heat_pump_heating_saving <- ifelse(heat_pump_heating_saving <= 0, 0, heat_pump_heating_saving)
  heat_pump_heating_saving <- ifelse(is.na(heat_pump_heating_saving), 0, heat_pump_heating_saving)
  
  # Note:
  # SEER calculation reference
  # https://www.sciencedirect.com/topics/engineering/seasonal-energy-efficiency-ratio
  
  # heat pump cooling consumption in kWh
  # calculate the cooling output by using typical cooling system
  typical_cooling_output <- annual_electric_cooling * 1000 * typical_cooling_SEER * 0.000293071
  
  # calculate the cooling output by using heat pump (which same amount electric consumption)
  heat_pump_cooling_input <- typical_cooling_output / 0.000293071 / heat_pump_SEER / 1000
  
  
  # savings in cooling (USD)
  heat_pump_cooling_saving <- (annual_electric_cooling - heat_pump_cooling_input) * electric_price
  heat_pump_cooling_saving <- ifelse(heat_pump_cooling_saving <= 0, 0, heat_pump_cooling_saving)
  heat_pump_cooling_saving <- ifelse(is.na(heat_pump_cooling_saving), 0, heat_pump_cooling_saving)
  # annual savings (USD)
  total_annual_savings <- heat_pump_heating_saving + heat_pump_cooling_saving
  
  # payback years 
  heat_pump_payback <- ( heat_pump_price - typical_cooling_system_price - typical_heating_system_price ) / total_annual_savings
  # generate list 
  heat_pump_gas_list <- list(heat_pump_heating_saving, 
                             heat_pump_cooling_saving,
                             total_annual_savings,
                             heat_pump_payback )
  # output value
  return (heat_pump_gas_list)
}



# Water heater (gas heated house) ---------------------------

high_efficiency_gas_water_heater <- function(eta_low,
                                             eta_high,
                                             annual_water_heater_consumption,
                                             gas_price,
                                             typical_water_heater_price,
                                             high_efficiency_water_heater_price){
  
  # Description:
  # high_efficiency_gas_water_heater() is function that used for calculate the energy savings and payback years
  
  # Arguments:
  #   Input:
  #     eta_low: value of efficiency for typical (low) gas water heater
  #     eta_high: value of efficiency for high gas water heater
  #     annual_water_heater_consumption: annual gas consumption for water heater (CCF)
  #     gas_price: local price for natural gas
  #     typical_water_heater_price: price for typical (low) efficiency water heater (USD)
  #     high_efficiency_water_heater_price: price for high efficiency water heater (USD)
  
  #   Output:
  #     water_heater_high_efficiency: gas consumption by using the high efficiency water heater
  #     water_heater_saving: gas consumption saving for using high efficiency water heater (CCF)
  #     water_heater_saving_USD: gas consumption saving for using high efficiency water heater in USD (USD)
  #     water_heater_payback: payback year for using high efficiency water heater (yr)
  
  

  # energy consumption on high efficiency water heater
  water_heater_high_efficiency <- annual_water_heater_consumption * eta_low / eta_high
  
  # energy consumption saving by using high efficiency gas water heater (CCF)
  water_heater_high_efficiency_saving <- annual_water_heater_consumption - annual_water_heater_consumption * eta_low / eta_high
  # water heater savings in USD
  water_heater_saving_USD <- water_heater_high_efficiency_saving * gas_price
  # payback year for using high efficiency water heater (yr)
  water_heater_payback <- (high_efficiency_water_heater_price - typical_water_heater_price ) / water_heater_saving_USD
  # generate list
  high_efficiency_gas_water_heater_list <- list(water_heater_high_efficiency,
                                                water_heater_high_efficiency_saving,
                                                water_heater_saving_USD,
                                                water_heater_payback)
  
  return(high_efficiency_gas_water_heater_list)
}



# Heat pump water heater (gas or electric heated house) ----------------------------
heat_pump_water_heater <- function(type, 
                                   typical_water_heater_efficiency,
                                   water_heater_heat_pump_COP,
                                   water_heater_heat_pump_efficiency,
                                   annual_water_heater_consumption,
                                   water_heater_heat_pump_price,
                                   typical_water_heater_price,
                                   gas_price,
                                   electric_price,
                                   eta_water_heater_heat_pump){
  # Description:
  # heat_pump_water_heater() is the function that used for calculate the energy savings and payback years for using water heater heat pump
  # the water heater heat pump only use electricity
  
  # Arguments:
  #    Input:
  #       type: heating type of the residential house, here the input for type is either "gas" or "electric" 
  #       typical_water_heater_efficiency: the efficiency of the standard water heater, usually define as 0.6
  #       water_heater_heat_pump_COP: COP value for water heater heat pump (typical define as COP = 4)
  #       annual_water_heater_consumption: annual energy consumption for water heater
  #                                       for gas heated house is gas consumption for water heater (CCF)
  #                                       for electric heated house is electric consumption for water heater (kWh)
  #       water_heater_heat_pump_price: price for high efficiency water heater heat pump (USD)
  #       typical_water_heater_price: price for typical (low) water heater (USD)
  #       gas_price: price for local natural gas (USD/CCF)
  #       electric_price: price for local electric price (USD/kWh)
  #       eta_water_heater_heat_pump: efficiency for water heater heat pump (typical define as eta_water_heater_heat_pump = 0.95)
  
  #    Output:
  #       water_heater_heat_pump_saving_USD: energy consumption savings by using water heater heat pump in USD
  #       water_heater_heat_pump_payback: payback years for upgrading water heater heat pump (years)
  
  
  if (type == "gas"){
    # calculate water heat pump saving in USD 
    # the first condition is "gas"
    water_heater_output <- annual_water_heater_consumption * typical_water_heater_efficiency # CCF
    # water heater heat pump input in kWh
    water_heater_input <- water_heater_output * 10 ^ 5 / 3413 / water_heater_heat_pump_COP / water_heater_heat_pump_efficiency
    
    # therefore need to convert into gas consumption into electricity
    water_heater_heat_pump_saving_USD <- annual_water_heater_consumption * gas_price - water_heater_input * electric_price
    # calculate payback years by using water heater heat pump in gas heated house
    water_heater_heat_pump_payback <- (water_heater_heat_pump_price - typical_water_heater_price) / water_heater_heat_pump_saving_USD
     
  }else{
    # calculate water heater heat pump energy consumption for electric heated house
    water_heater_heat_pump_consumption <- annual_water_heater_consumption * eta_water_heater_heat_pump / water_heater_heat_pump_COP
    # calculate water heater heat pump energy consumption savings in USD
    water_heater_heat_pump_saving_USD <- (annual_water_heater_consumption - water_heater_heat_pump_consumption) * electric_price
    # calculate payback years by using water heater heat pump in electric heated house
    water_heater_heat_pump_payback <- (water_heater_heat_pump_price - typical_water_heater_price) / water_heater_heat_pump_saving_USD
  }
  # generate list
  heat_pump_water_heater_list <- list(water_heater_heat_pump_saving_USD, 
                                      water_heater_heat_pump_payback)
  return (heat_pump_water_heater_list)
}


# Envelop improvement (gas or electric heated house) ------------------------

envelop_improvement <- function(type,
                                heating_degree_hours,
                                cooling_degree_hours,
                                annual_gas_heating,
                                annual_electric_heating,
                                annual_electric_cooling,
                                typical_heating_efficiency,
                                typical_cooling_efficiency,
                                normalized_heating,
                                normalized_cooling,
                                normalized_heating_eta_change,
                                normalized_cooling_eta_change,
                                electric_price,
                                gas_price){
  # Description:
  # envelop_improvement function is used to estimate the savings by improve the residential building envelop
  
  # Arguments:
  #   Input: 
  #     type: heating type of the residential house, here the heating type is either "gas" or "electric"
  #     heating_degree_hours: heating degree hours that calculated by using heating_degree_hours() function
  #     cooling_degree_hours: cooling degree hours that calculated by using cooling_degree_hours() function
  #     annual_gas_heating: annual gas consumption in heating (unit CCF)
  #     annual_electric_heating: annual electric consumption in heating (unit kWh)
  #     annual_electric_cooling: annual electric consumption in cooling (unit kWh)
  #     typical_heating_efficiency: typical efficiency for heating system (here, define as 0.8)
  #     typical_cooling_efficiency: typical efficiency for cooling system (here, define as 0.8)
  #     normalized_heating: the heating energy consumption intensity before change into high efficiency heating system (CCF/ft^2)
  #     normalized_cooling: the cooling energy consumption intensity before change into high efficiency cooling system (kWh/ft^2)
  #     normalized_heating_eta_change: the heating efficiency intensity after change into high efficiency heating system (CCF/ft^2)
  #     normalized_cooling_eta_change: the cooling efficiency intensity after change into high efficiency heating system (kWh/ft^2)
  #     electric_price: price of the local electricity price (USD/kWh)
  #     gas_price: price of the local gas price (USD/kWh)
  
  #   Output:
  #     envelop_consumption_heating: annual heating consumption after envelope improvement (CCF or kWh)
  #     envelop_consumption_heating_savings: annual heating consumption savings after envelope improvement (CCF or kWh)
  #     envelop_consumption_heating_savings_USD: annual heating consumption savings after envelope improvement in USD (USD)
  #     envelop_consumption_cooling: annual cooling consumption after envelope improvement (kWh)
  #     envelop_consumption_cooling_savings: annual cooling consumption savings after envelope improvement (kWh)
  #     envelop_consumption_cooling_savings_USD: annual cooling consumption savings after envelope improvement in USD (USD)
  #     envelop_improvement_savings: annual energy consumption savings in USD (USD)
  
  
  
  # Identify if the house is "gas heated" or "electric heated"
  if (type == "gas"){
    # heating system -----------------------------------------------------
    heating_U_value <- annual_gas_heating * typical_heating_efficiency / heating_degree_hours # CCF 
    
    # energy consumption on envelop improvement in heating (CCF)
    envelop_consumption_heating <- heating_degree_hours / typical_heating_efficiency * 
      (normalized_heating_eta_change + sd(normalized_heating_eta_change[which(!is.na(normalized_heating_eta_change))])) / normalized_heating * heating_U_value

    
    # energy consumption savings in heating (CCF)
    envelop_consumption_heating_savings <- annual_gas_heating - envelop_consumption_heating # ()
    # fix the value
    # Note:
    # Here, change the negative value become 0,
    # which means the original envelope for the residential house is good enough, which is not necessary change
    envelop_consumption_heating_savings <- ifelse(envelop_consumption_heating_savings < 0, 0, envelop_consumption_heating_savings)
    
    # energy consumption heating savings in USD
    envelop_consumption_heating_savings_USD <- envelop_consumption_heating_savings * gas_price
    
    # cooling system ---------------------------------------------------------------------
    cooling_U_value <- annual_electric_cooling * typical_cooling_efficiency / cooling_degree_hours
    
    # energy consumption on envelop (kWh) 
    envelop_consumption_cooling <- cooling_degree_hours / typical_cooling_efficiency * cooling_U_value *
      (normalized_cooling_eta_change + sd(normalized_cooling_eta_change[which(!is.na(normalized_cooling_eta_change))])) / normalized_cooling
    
    # energy consumption savings in cooling
    envelop_consumption_cooling_savings <- annual_electric_cooling - envelop_consumption_cooling
    # fix the value 
    envelop_consumption_cooling_savings <- ifelse(envelop_consumption_cooling_savings < 0, 0, envelop_consumption_cooling_savings)
    
    # energy consumption cooling savings in USD
    envelop_consumption_cooling_savings_USD <- envelop_consumption_cooling_savings * electric_price
    
    # total savings by change the envelop (USD)
    envelop_improvement_savings <- envelop_consumption_heating_savings_USD + envelop_consumption_cooling_savings_USD
    
  }else{
    # Here will be the calculation for electric heated house
    
    # heating system -----------------------------------------
    heating_U_value <- annual_electric_heating * typical_heating_efficiency / heating_degree_hours # kWh
    
    # energy consumption on envelop improvement in heating (kWh)
    envelop_consumption_heating <- heating_degree_hours / typical_heating_efficiency * heating_U_value * 
      (normalized_heating_eta_change + sd(normalized_heating_eta_change[which(!is.na(normalized_heating_eta_change))])) / normalized_heating

    # energy consumption savings in heating
    envelop_consumption_heating_savings <- annual_electric_heating - envelop_consumption_heating
    # fix the value
    envelop_consumption_heating_savings <- ifelse(envelop_consumption_heating_savings < 0, 0, envelop_consumption_heating_savings)
    
    # energy consumption heating savings in USD
    envelop_consumption_heating_savings_USD <- envelop_consumption_heating_savings * electric_price
    
    # cooling system ------------------------------------------
    cooling_U_value <- annual_electric_cooling * typical_cooling_efficiency / cooling_degree_hours
    
    # energy consumption on envelop (kWh)
    envelop_consumption_cooling <- cooling_degree_hours / typical_cooling_efficiency * cooling_U_value * 
      (normalized_cooling_eta_change + sd(normalized_cooling_eta_change[which(!is.na(normalized_cooling_eta_change))])) / normalized_cooling

    # energy consumption savings in cooling
    envelop_consumption_cooling_savings <- annual_electric_cooling - envelop_consumption_cooling
    # fix the value 
    envelop_consumption_cooling_savings <- ifelse(envelop_consumption_cooling_savings < 0, 0, envelop_consumption_cooling_savings)
    
    # energy consumption cooling savings in USD
    envelop_consumption_cooling_savings_USD <- envelop_consumption_cooling_savings * electric_price
    
    # total savings by change the envelop (USD)
    envelop_improvement_savings <- envelop_consumption_heating_savings_USD + envelop_consumption_cooling_savings_USD
    
    
  }
  envelop_improvement_list <- list(envelop_consumption_heating,
                                   envelop_consumption_heating_savings,
                                   envelop_consumption_heating_savings_USD,
                                   envelop_consumption_cooling,
                                   envelop_consumption_cooling_savings,
                                   envelop_consumption_cooling_savings_USD,
                                   envelop_improvement_savings)
  # optional 
  # add cooling_U_value, heating_U_value as the output to check if the result is correct.
  return(envelop_improvement_list)
}


# Electric heated house -------------------------------------------------------------------------------------------------------------------
# Heating system (electric heated house) -------------------------------

high_efficiency_electric_heating <- function(eta_low,
                                             eta_high,
                                             heating_degree_hours,
                                             annual_electric_heating,
                                             typical_heating_system_price,
                                             high_heating_system_price,
                                             electric_price,
                                             square_footage){
  
  # Description:
  # high_efficiency_electric_heating() is a function that used to calculate the energy consumption for electric heated house after change into the high efficiency heating system
  
  # Arguments:
  #   Input:
  #     eta_low: value of efficiency for typical (low) efficiency heating system
  #     eta_high: value of efficiency for high efficiency heating system
  #     heating_degree_hours: heating degree hours which generated by using heating_degree_hours() function
  #     annual_electric_heating: annual electric heating consumption (kWh)
  #     typical_heating_system_price: price for typical (low) efficiency heating system
  #     high_heating_system_price: price for high efficiency heating system
  #     electric_price: local electric price (USD/kWh)
  #     square_footage: square footage for residential houses
  
  # Output:
  #     heating_U_value: bi-product,
  #     high_efficiency_electric_heating_saving: electric savings in heating by using high efficiency heating system (kWh)
  #     high_efficiency_electric_heating_saving_USD: electric savings in heating by using high efficiency heating system in USD (USD)
  #     high_efficiency_electric_heating: electric consumption in heating by changing into the high efficiency heating system (kWh)
  #     normalized_heating_eta_change: electric consumption in heating intensity after change into the high efficiency heating system (kWh/ft^2)
  #     high_efficiency_electric_heating_payback: payback years for changing the high efficiency heating system (yr)
  
  
  
  # calculate dynamic U value for residential house (kWh/k)
  heating_U_value <- annual_electric_heating * eta_low / heating_degree_hours
  # high efficiency heating consumption savings on electric consumption (kWh)
  high_efficiency_electric_heating_saving <- abs(-heating_degree_hours / (eta_low ^ 2) * (eta_high - eta_low) * heating_U_value)
  
  # energy consumption saving in USD after using high efficiency heating system
  high_efficiency_electric_heating_saving_USD <- high_efficiency_electric_heating_saving * electric_price
  
  # energy consumption by using high efficiency heating system
  high_efficiency_electric_heating <- annual_electric_heating - high_efficiency_electric_heating_saving
  
  # obtain the normalized heating intensity after change into the high efficiency heating system
  normalized_heating_eta_change <- high_efficiency_electric_heating / square_footage
  
  
  # payback by using high efficiency heating system
  high_efficiency_electric_heating_payback <- (high_heating_system_price - typical_heating_system_price) / high_efficiency_electric_heating_saving_USD
  
  
  return_list <- list(heating_U_value,
                      high_efficiency_electric_heating_saving,
                      high_efficiency_electric_heating_saving_USD,
                      high_efficiency_electric_heating,
                      normalized_heating_eta_change,
                      high_efficiency_electric_heating_payback)
  
  
  return (return_list)
  
}








# Cooling system (electric heated house) -----------------------------

high_efficiency_electric_cooling <- function(SEER_low,
                                             SEER_high,
                                             annual_electric_cooling,
                                             square_footage,
                                             typical_SEER_system_price,
                                             high_SEER_cooling_system_price,
                                             electric_price){
  
  # Description:
  # high_efficiency_electric_cooling() is the function that used for calculate energy savings and payback years for upgrading the high efficiency cooling system
  
  # Arguments:
  #   Input:
  #     eta_low: value of efficiency for typical (low) efficiency cooling system
  #     eta_high: value of efficiency for high efficiency cooling system
  #     cooling_degree_hours: cooling degree hours that calculated by using cooling_degree_hours() function
  #     annual_electric_cooling: annual electric consumption in cooling (kWh)
  #     square_footage: square footage for residential houses
  #     typical_cooling_system_price: price for the typical (low) efficiency cooling system (USD)
  #     high_efficiency_cooling_system_price: price for the high efficiency cooling system (USD)
  #     electric_price: local electric price
  
  #   Output:
  #     cooling_U_value: bi-product
  #     high_efficiency_electric_cooling_savings: energy consumption savings on coooling by using high efficiency cooling system (kWh)
  #     high_efficiency_electric_cooling_savings_USD: energy consumption savings on cooling by using high efficiency cooling system in USD (USD)
  #     high_efficiency_electric_cooling: energy consumption by using high efficiency cooling system (kWh)
  #     normalized_electric_cooling_eta_change: cooling energy consumption intensity by changing into high efficiency cooling system (kWh)
  #     high_efficiency_electric_cooling_payback: payback year for upgrading into high efficiency cooling system (yr)
  
  
  # Obtain the Output cooling energy in Btu with low SEER
  Output_cooling_energy_btu <- SEER_low * annual_electric_cooling * 1000 # convert kWh into Wh
  # Obtain input electric energy Wh in high SEER
  Input_electric_energy_Wh <- Output_cooling_energy_btu / SEER_high
  # Convert Wh into kWh
  Input_electric_energy_kWh <- Input_electric_energy_Wh / 1000
  # annual electric savings with high SEER in kWh
  annual_electric_cooling_high_SEER_saving <- annual_electric_cooling - Input_electric_energy_kWh
  # annual electric savings with high SEER in USD
  annual_electric_cooling_saving_USD <- annual_electric_cooling_high_SEER_saving * electric_price
  # cooling consumption intensity by using high SEER cooling system (kWh/ft^2)
  normalized_electric_cooling_eta_change <- Input_electric_energy_kWh / square_footage
  # payback years for installing 
  high_efficiency_cooling_system_payback <- (high_SEER_cooling_system_price - typical_SEER_system_price) / annual_electric_cooling_saving_USD
  
  # generate list
  return_list <- list(annual_electric_cooling_high_SEER_saving,
                      annual_electric_cooling_saving_USD,
                      normalized_electric_cooling_eta_change,
                      high_efficiency_cooling_system_payback)
  
  
  return(return_list)
}






# Heat pump (electric heated house) -----------------------------------
heat_pump_electric <- function(typical_cooling_SEER,
                               typical_heating_HSPF,
                               typical_cooling_efficiency,
                               typical_heating_efficiency,
                               heat_pump_SEER,
                               heat_pump_HSPF,
                               typical_cooling_system_price,
                               typical_heating_system_price,
                               heat_pump_price,
                               annual_electric_heating,
                               annual_electric_cooling,
                               electric_price){
  
  # Description:
  # heat_pump_electric() is the function that used for calculating the energy consumption savings and payback years for residential house 
  # upgrade into heat pump 
  
  # Arguments:
  #   Input:
  #     typical_cooling_SEER: SEER value for the typical (low) efficiency cooling system, usually is around 12 ~ 15
  #     typical_heating_SEER: SEER value for the typical (low) efficiency heating system, usually is around 12 ~ 15
  #     typical_cooling_efficiency: efficiency value for typical (low) efficiency cooling system
  #     typical_heating_efficiency: efficiency value for typical (low) efficiency heating system
  #     heat_pump_SEER: SEER value for heat pump, usually is around 21
  #     heat_pump_HSPF: HSPF value for heat pump, usually is around 13
  #     typical_cooling_system_price: price for typical (low) efficiency cooling system
  #     typical_heating_system_price: price for typical (low) efficiency heating system
  #     heat_pump_price: price for heat pump (USD)
  #     annual_electric_heating: annual electric consumption in heating (kWh)
  #     annual_electric_cooling: annual electric consumption in cooling (kWh)
  #     electric_price: local electric price (USD)
  
  #   Output:
  #     heat_pump_consumption: energy consumption by using the heat pump (kWh)
  #     heat_pump_consumption_USD: energy consumption by using the heat pump in USD (USD)
  #     heat_pump_savings: energy consumption savings by using the heat pump (kWh)
  #     heat_pump_savings_USD: energy consumption savings by using the heat pump in USD (USD)
  #     heat_pump_payback: payback years by using heat pump (yr)

  
  # typical heating output 
  typical_heating_output <- annual_electric_heating * 1000 * typical_heating_efficiency * typical_heating_HSPF  / 3412 # convert Btu to kWh 
  
  # typical cooling output
  typical_cooling_output <- annual_electric_cooling * 1000 * typical_cooling_efficiency * typical_cooling_SEER / 3412 # convert Btu to kWh
  
  
  # heat pump input to generate same output of heating by using heat pump
  heat_pump_heating_input <- typical_heating_output * 3412 / heat_pump_HSPF / 1000
  
  # heat pump input to generate same output of cooling by using heat pump
  heat_pump_cooling_input <- typical_cooling_output * 3412 / heat_pump_SEER / 1000
  
  # heat pump annual heating savings (kWh)
  heat_pump_heating_saving <- annual_electric_heating - heat_pump_heating_input
  # fix the value, if there is negative value make as 0
  heat_pump_heating_saving <- ifelse(heat_pump_heating_saving < 0, 0 , heat_pump_heating_saving)
  
  
  # heat pump annual cooling savings (kWh)
  heat_pump_cooling_saving <- annual_electric_cooling - heat_pump_cooling_input
  # fix the value, if there is negative value make as 0
  heat_pump_cooling_saving <- ifelse(heat_pump_cooling_saving < 0, 0 , heat_pump_cooling_saving)
  
  
  # energy savings after upgrade into using heat pump
  heat_pump_savings <- heat_pump_heating_saving + heat_pump_cooling_saving
  
  # heat pump savings in USD
  heat_pump_savings_USD <- heat_pump_savings * electric_price
  
  # payback years for upgrade using heat pump
  heat_pump_payback <- (heat_pump_price - typical_cooling_system_price - typical_heating_system_price) / heat_pump_savings_USD
  
  return_list <- list(heat_pump_heating_saving,
                      heat_pump_cooling_saving,
                      heat_pump_savings,
                      heat_pump_savings_USD,
                      heat_pump_payback)
  
  return(return_list)
  
  
}

# Water heater (electric heated house) --------------------------------
high_efficiency_water_heater_electric <- function(eta_low,
                                                  eta_high,
                                                  electric_price,
                                                  annual_electric_baseload,
                                                  typical_water_heater_price,
                                                  high_efficiency_water_heater_price){
  
  # Description:
  # high_efficiency_water_heater_electric() is the function that used to calculate the energy consumption savings and payback years for using high efficiency water heater
  
  # Arguments:
  #   Input:
  #     eta_low: value of efficiency for typical (low) efficiency water heater
  #     eta_high: value of efficiency for high efficiency water heater
  #     electric_price: local electric price (USD)
  #     annual_electric_baseload: annual water heater electric consumption (kWh)
  #     typical_water_heater_price: price for typical (low) efficiency water heater (USD)
  #     high_efficiency_water_heater_price: price for high efficiency water heater (USD)
  
  # Output:
  #     water_heater_consumption: energy consumption for high efficiency water heater (kWh)
  #     water_heater_savings: energy consumption savings for high efficiency water heater (kWh)
  #     water_heater_saving_USD: energy consumption savings for high efficiency water heater (USD)
  #     water_heater_high_efficiency_payback: payback years for using high efficiency water heater (yr)
  
  # annual water heater electric consumption by using high efficiency water heater
  water_heater_consumption <- annual_electric_baseload * eta_low / eta_high
  # water heater savings after upgrade into high efficiency water heater
  water_heater_savings <- annual_electric_baseload - water_heater_consumption
  
  # water heater savings in USD 
  water_heater_saving_USD <- water_heater_savings * electric_price
  # high efficiency water heater payback
  water_heater_high_efficiency_payback <- (high_efficiency_water_heater_price - typical_water_heater_price) / water_heater_saving_USD 
  
  return_list <- list(water_heater_consumption,
                      water_heater_savings,
                      water_heater_saving_USD,
                      water_heater_high_efficiency_payback)
  
  return(return_list)

}


# Heat pump water heater (electric heated house) ----------------------------------
# has been already defined in gas heated house

# Envelop improvement (electric heated house) ----------------------------
# has been already defined in gas heated house
