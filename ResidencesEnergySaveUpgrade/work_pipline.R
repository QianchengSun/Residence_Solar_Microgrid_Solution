# This is the pipeline for estimate the residential equipment upgrade options
# In this work pipeline includes
# 1) Gas heated house
# - high efficiency gas input heating furnace
# - high SEER cooling system
# - high performance heat pump
# - water heater (high efficiency gas input water heater & water heater heat pump)
# - envelope improvement
# 2) Electric heated house
# - high performance heat pump system (include heating and cooling)
# - envelope improvement

# Here, the Hamilton County, Cincinnati Ohio, will be shown as an example
# Input:
electric_price <- 0.1059
natural_gas_price <- 0.85
file_path <- "/Users/qianchengsun/Desktop/Empowersaves/Code_package/Database/hamilton_county.csv"
# Output:
gas_heated_house_output_path <- "/Users/qianchengsun/Desktop/Empowersaves/Code_package/Database/hamilton_county_resulthamilton_county_gas_heated_house_with_energy_upgrade_options_2.csv"
electric_heated_house_output_path <- "/Users/qianchengsun/Desktop/Empowersaves/Code_package/Database/hamilton_county_resulthamilton_county_electric_heated_house_with_energy_upgrade_options_2.csv"

  
  
# read file  
hamilton_county <- read.csv(file_path)
# classify the gas & electric heated house
# Note:
# here use the electric heating and coolign ratio to define if the house is gas or electric heated
hamilton_county$heating_cooling_ratio <- hamilton_county$annual_electric_heating_consumption_kWh / hamilton_county$annual_cooling_energy_consumption_kWh
hamilton_county$heating_type <- ifelse(hamilton_county$heating_cooling_ratio < 0.5, "gas_heated", "electric_heated")
hamilton_county$heating_type <- ifelse(is.na(hamilton_county$heating_cooling_ratio), "gas_heated", hamilton_county$heating_type)



# hamilton county gas heated house -----------
hamilton_county_gas_heated_house <- hamilton_county[which(hamilton_county$heating_type == "gas_heated"), ]
# calculate heating degree hours
heating_degree_hours <- heating_degree_hours(T_in = 68,
                                             heating_month = c(1,2,3,4,11,12),
                                             weather_data_file_path = "/Users/qianchengsun/Desktop/Empowersaves/project_result/Hamilton_county/TMY/hamilton_TMY_2000_2020_hourly.csv",
                                             n_years = 20,
                                             hour_interval = 2)

# calculate cooling degree hours
cooling_degree_hours <- cooling_degree_hours(T_in = 72,
                                             cooling_month = c(6,7,8,9),
                                             weather_data_file_path = "/Users/qianchengsun/Desktop/Empowersaves/project_result/Hamilton_county/TMY/hamilton_TMY_2000_2020_hourly.csv",
                                             n_years = 20,
                                             hour_interval = 2)


# High effciency heating furnace  ----------------
# high (typical) efficiency furnace reference:
# https://www.homeserve.com/en-us/blog/cost-guide/new-furnace-cost/
high_efficiency_gas_heating_result <- gas_furnace(eta_low =  0.8,
                                                  eta_high = 0.95,
                                                  annual_gas_heating = hamilton_county_gas_heated_house$annual_gas_heating_consumption_CCF,
                                                  square_footage = hamilton_county_gas_heated_house$Sq_feet,
                                                  heating_degree_hours = heating_degree_hours,
                                                  gas_price = natural_gas_price,
                                                  typical_heating_system_price = 5400,
                                                  high_efficiency_heating_system_price = 7600)

# gas savings in heating by using high efficiency gas heating system (annual)
hamilton_county_gas_heated_house$savings_heating_energy_consumption_CCF <- high_efficiency_gas_heating_result[[2]]
# gas consumption after change into high efficency gas heating system (annual)
hamilton_county_gas_heated_house$annual_new_gas_heating_system_consumption_CCF <- high_efficiency_gas_heating_result[[3]]
# annual gas savings in USD by change into high efficiency gas heating system
hamilton_county_gas_heated_house$savings_heating_energy_consumption_USD <- high_efficiency_gas_heating_result[[4]]
# gas heating intensity after change into high efficiency heating system (CCF / ft^2)
hamilton_county_gas_heated_house$annual_new_gas_heating_system_consumption_intensity <- high_efficiency_gas_heating_result[[5]]
# payback years for upgrading into high efficiency heating system (yr)
hamilton_county_gas_heated_house$new_heating_system_payback_yr <- high_efficiency_gas_heating_result[[6]]
# Monthly savings by using high efficiency heating system in USD (USD)
# Note:
# Because there is about 6 month in heating mode
# therefore, the month that should be used as 6 in here
# hamilton_county_gas_heated_house$monthly_gas_heating_saving_USD <- hamilton_county_gas_heated_house$annual_gas_heating_saving_USD / 6

# Rank order of the residential house for upgrading the high efficiency heating system payback years
hamilton_county_gas_heated_house$rating_new_heating_system_payback_yr <- rank_order(target_column = hamilton_county_gas_heated_house$new_heating_system_payback_yr,
                                                                                    max_value = 50,
                                                                                    min_value = 0)


hist(hamilton_county_gas_heated_house$new_heating_system_payback_yr[which(hamilton_county_gas_heated_house$new_heating_system_payback_yr >0 & 
                                                                            hamilton_county_gas_heated_house$new_heating_system_payback_yr < 50)],
     xlab = "Payback years",
     ylab = "Number of houses",
     main = "Payback years for heating system upgrade options",
     breaks = 10)

hist(hamilton_county_gas_heated_house$rating_new_heating_system_payback_yr,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for upgrading heating system payback year")

# high SEER cooling system (gas heated house) -------------------------------------------------------------------------------
high_efficiency_gas_cooling_result <- cooling_upgrade(SEER_low = 13,
                                                      SEER_high = 21,
                                                      electric_price = electric_price,
                                                      annual_electric_cooling = hamilton_county_gas_heated_house$annual_cooling_energy_consumption_kWh/2, # should be update with the new predicted electric cooling 
                                                      square_footage = hamilton_county_gas_heated_house$Sq_feet,
                                                      typical_SEER_system_price = 2820,
                                                      high_SEER_cooling_system_price = 5390)


# annual electric cooling saving by using high SEER cooling system (kWh)
hamilton_county_gas_heated_house$annual_electric_cooling_high_SEER_saving_kWh <- high_efficiency_gas_cooling_result[[1]]

# annual electric cooling saving in USD by using high efficiency cooling system (USD)
hamilton_county_gas_heated_house$annual_electric_cooling_saving_USD <- high_efficiency_gas_cooling_result[[2]]

# electric consumption intensity in cooling by changing into high efficiency cooling system (kWh / ft^2)
hamilton_county_gas_heated_house$annual_new_cooling_system_consumption_intensity <- high_efficiency_gas_cooling_result[[3]]
# payback years by using high efficiency cooling system (yr)
hamilton_county_gas_heated_house$new_cooling_system_payback_yr <- high_efficiency_gas_cooling_result[[4]]

# monthly electric cooling saving by using high efficiency cooling in USD
# Note:
# here the total cooling month is 4
# hamilton_county_gas_heated_house$monthly_electric_cooling_saving_USD <- hamilton_county_gas_heated_house$annual_electric_cooling_saving_USD / 4


# Rank order of the residential house for upgrading the high efficiency cooling system payback years
hamilton_county_gas_heated_house$rating_new_cooling_system_payback_yr <- rank_order(target_column = hamilton_county_gas_heated_house$new_cooling_system_payback_yr,
                                                                                    max_value = 60,
                                                                                    min_value = 0)

hist(hamilton_county_gas_heated_house$new_cooling_system_payback_yr[which(hamilton_county_gas_heated_house$new_cooling_system_payback_yr > 0 &
                                                                            hamilton_county_gas_heated_house$new_cooling_system_payback_yr < 60)],
     xlab = "Payback years",
     ylab = "Number of houses",
     main = "Payback years for cooling upgrade options",
     breaks = seq(0, 60, by= 6))


hist(hamilton_county_gas_heated_house$rating_new_cooling_system_payback_yr,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for upgrading cooling system payback year")

# Heat pump option for gas heated house ---------------------------
heat_pump_SEER <- 21
heat_pump_HSPF <- 13
heat_pump_efficiency <- 0.95
typical_cooling_SEER <- 13

heat_pump_gas_result <- heat_pump_gas(heat_pump_price = 13500,
                                      typical_heating_system_price = 5400,
                                      typical_cooling_system_price = 2820, # SEER is 14 usually 
                                      heat_pump_SEER = heat_pump_SEER,
                                      heat_pump_HSPF = heat_pump_HSPF,
                                      typical_cooling_SEER = typical_cooling_SEER,
                                      typical_heating_efficiency = 0.8,
                                      annual_gas_heating = hamilton_county_gas_heated_house$annual_gas_heating_consumption_CCF,
                                      annual_electric_cooling = hamilton_county_gas_heated_house$annual_cooling_energy_consumption_kWh/2,
                                      gas_price = natural_gas_price,
                                      electric_price = electric_price)

# annual heat pump saving in heating consumption in USD
hamilton_county_gas_heated_house$heat_pump_heating_saving_USD <- heat_pump_gas_result[[1]]
# annual heat pump saving in cooling consumption saving in USD
hamilton_county_gas_heated_house$heat_pump_cooling_saving_USD <- heat_pump_gas_result[[2]]
# annual heat pump saving in cooling & saving in USD
hamilton_county_gas_heated_house$savings_heat_pump_annual_USD <- heat_pump_gas_result[[3]]
# payback years for upgrading the heat pump (yr)
hamilton_county_gas_heated_house$heat_pump_payback_year <- heat_pump_gas_result[[4]]

# Monthly savings by using the heat pump instead of the heating and cooling system
# Here use 10 month in the calculation
# because, for heating there are 6 months, and for cooling there are 4 months
# hamilton_county_gas_heated_house$monthly_heat_pump_savings_USD <- hamilton_county_gas_heated_house$heat_pump_total_annual_savings / 10

# Rank order for the heat pump pay back years
hamilton_county_gas_heated_house$rating_heat_pump_payback_year <- rank_order(target_column = hamilton_county_gas_heated_house$heat_pump_payback_year,
                                                                           max_value = 30,
                                                                           min_value = 0)

hist(hamilton_county_gas_heated_house$rating_heat_pump_payback_year[which(hamilton_county_gas_heated_house$heat_pump_payback_year > 0 &
                                                                   hamilton_county_gas_heated_house$heat_pump_payback_year < 30)],
     xlab = "Payback years",
     ylab = "Number of houses",
     main = "Payback years for heat pump upgrade option",
     breaks = seq(0, 30, by= 3))


hist(hamilton_county_gas_heated_house$rating_heat_pump_payback_year,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for heat pump upgrade option")

# High efficiency water heater ---------------------------
high_efficiency_gas_water_heater_result <- high_efficiency_gas_water_heater(eta_low = 0.6,
                                                                            eta_high = 0.8,
                                                                            annual_water_heater_consumption = hamilton_county_gas_heated_house$annual_gas_water_heater_consumption_CCF,
                                                                            gas_price = natural_gas_price,
                                                                            typical_water_heater_price = 810,
                                                                            high_efficiency_water_heater_price = 1650)
# annual high efficiency water heater consumption (CCF)
hamilton_county_gas_heated_house$annual_new_water_heater_consumption_CCF <- high_efficiency_gas_water_heater_result[[1]]
# annual high efficiency water heater consumption saving after upgrade (CCF)
hamilton_county_gas_heated_house$savings_new_water_heater_consumption_CCF <- high_efficiency_gas_water_heater_result[[2]]

# annual energy consumption savings in USD by upgrading into high efficiency water heater (USD)
hamilton_county_gas_heated_house$savings_new_water_heater_consumption_USD <- high_efficiency_gas_water_heater_result[[3]]
# payback years by using high efficiency water heater (yr)
hamilton_county_gas_heated_house$new_water_heater_payback_yr <- high_efficiency_gas_water_heater_result[[4]]
# monthly water heater savings in USD
# Note:
# the water heater will be used every day, therefore, in here the month = 12 
# hamilton_county_gas_heated_house$monthly_water_heater_savings_USD <- hamilton_county_gas_heated_house$water_heater_saving_USD / 12

# Rank order for using high efficiency water heater
hamilton_county_gas_heated_house$rating_new_water_heater_payback_yr <- rank_order(target_column = hamilton_county_gas_heated_house$new_water_heater_payback_yr,
                                                                                  max_value = 35,
                                                                                  min_value = 0)


hist(hamilton_county_gas_heated_house$new_water_heater_payback_yr[which(hamilton_county_gas_heated_house$new_water_heater_payback_yr > 0 &
                                                                          hamilton_county_gas_heated_house$new_water_heater_payback_yr < 35)],
     xlab = "Payback Year",
     ylab = "Number of houses",
     main = "Payback year for water heater upgrade option",
     breaks = seq(0, 35, by = 3.5))

hist(hamilton_county_gas_heated_house$rating_new_water_heater_payback_yr,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for water heater upgrade option")

# Heat pump water heater ---------------------------------------
heat_pump_water_heater_result <- heat_pump_water_heater(typical_water_heater_efficiency = 0.6,
                                                        water_heater_heat_pump_COP = 4, 
                                                        annual_water_heater_consumption = hamilton_county_gas_heated_house$annual_gas_water_heater_consumption_CCF,
                                                        water_heater_heat_pump_price = 3300,
                                                        typical_water_heater_price = 810,
                                                        gas_price = natural_gas_price,
                                                        electric_price = electric_price)

# heat pump water heater savings in USD
hamilton_county_gas_heated_house$savings_water_heater_heat_pump_consumption_USD <-  heat_pump_water_heater_result[[1]]
# payback years for upgrading into high efficiency water heater heat pump
hamilton_county_gas_heated_house$water_heater_heat_pump_payback_yr <- heat_pump_water_heater_result[[2]]

# Monthly heat pump water heater payback  USD
# hamilton_county_gas_heated_house$monthly_water_heater_heat_pump_payback_USD <- hamilton_county_gas_heated_house$water_heater_heat_pump_saving_USD / 12


# Rank order for using high efficincy heat pump water heater
hamilton_county_gas_heated_house$rating_water_heater_heat_pump_payback_yr <- rank_order(target_column = hamilton_county_gas_heated_house$water_heater_heat_pump_payback_yr,
                                                                                        max_value = 10,
                                                                                        min_value = 0)

hist(hamilton_county_gas_heated_house$water_heater_heat_pump_payback_yr[which(hamilton_county_gas_heated_house$water_heater_heat_pump_payback_yr > 0 & 
                                                                                hamilton_county_gas_heated_house$water_heater_heat_pump_payback_yr < 60)],
     xlab = "Payback Year",
     ylab = "Number of houses",
     main = "Payback years for water heater heat pump upgrade option")

hist(hamilton_county_gas_heated_house$rating_water_heater_heat_pump_payback_yr,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for water heater heat pump upgrade option")

# Envelope improvement -------------
# remove outliers
hamilton_county_gas_heated_house <- hamilton_county_gas_heated_house[which(hamilton_county_gas_heated_house$annual_gas_heating_consumption_intensity < 100), ]
hamilton_county_gas_heated_house <- hamilton_county_gas_heated_house[which(hamilton_county_gas_heated_house$annual_cooling_energy_consumption_intensity < 100), ]

envelope_improvement_result_gas <- envelop_improvement_gas(square_footage = hamilton_county_gas_heated_house$Sq_feet,
                                                        heating_degree_hours = heating_degree_hours,
                                                        annual_gas_heating = hamilton_county_gas_heated_house$annual_gas_heating_consumption_CCF,
                                                        annual_electric_cooling = hamilton_county_gas_heated_house$annual_cooling_energy_consumption_kWh /2,
                                                        typical_heating_efficiency = 0.8,
                                                        normalized_heating = hamilton_county_gas_heated_house$annual_gas_heating_consumption_intensity,
                                                        normalized_cooling = hamilton_county_gas_heated_house$annual_cooling_energy_consumption_intensity,
                                                        normalized_heating_eta_change = hamilton_county_gas_heated_house$annual_new_gas_heating_system_consumption_intensity,
                                                        normalized_cooling_eta_change = hamilton_county_gas_heated_house$annual_new_cooling_system_consumption_intensity,
                                                        electric_price = electric_price,
                                                        gas_price = natural_gas_price)

hamilton_county_gas_heated_house$envelop_consumption_heating <- envelope_improvement_result_gas[[1]] 
hamilton_county_gas_heated_house$envelop_consumption_heating_savings <- envelope_improvement_result_gas[[2]]
# when doing histogram on the envelop consumption savings, please only select the residential house which has the value is larger than 0
# Because majority of the residential house does not need to have upgrade on their envelop
hamilton_county_gas_heated_house$envelop_consumption_heating_savings_USD <- envelope_improvement_result_gas[[3]]
hamilton_county_gas_heated_house$envelop_consumption_cooling <- envelope_improvement_result_gas[[4]]
hamilton_county_gas_heated_house$envelop_consumption_cooling_savings <- envelope_improvement_result_gas[[5]]
# when doing histogram on the envelop consumption savings, please only select the residential house which has the value is larger than 0
# Because majority of the residential house does not need to have upgrade on their envelop
hamilton_county_gas_heated_house$envelop_consumption_cooling_savings_USD <- envelope_improvement_result_gas[[6]]
hamilton_county_gas_heated_house$envelop_improvement_savings <- envelope_improvement_result_gas[[7]]

# Rank order for envelop improvement
# If the rank value is really small means, the residential house doesnt not need any upgrade
hamilton_county_gas_heated_house$rank_envelop_improvement_savings <- rank_order(target_column = hamilton_county_gas_heated_house$envelop_improvement_savings,
                                                                                max_value = 1500,
                                                                                min_value = 0)

hist(hamilton_county_gas_heated_house$envelop_improvement_savings[which(hamilton_county_gas_heated_house$envelop_improvement_savings >0 &
                                                                          hamilton_county_gas_heated_house$envelop_improvement_savings < 1500)],
     xlab = "Annual Savings (USD/year)",
     ylab = "Number of houses",
     main = "Envelop improvement upgrade option",
     breaks = seq(0, 1500, by = 150))


hist(hamilton_county_gas_heated_house$rank_envelop_improvement_savings,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for envelop improvement upgrade option")

# calculate payback years
insulation_payback_gas <- (2.5 * hamilton_county_gas_heated_house$Sq_feet) / hamilton_county_gas_heated_house$envelop_improvement_savings 

hist(insulation_payback_gas[which(insulation_payback_gas >0 & insulation_payback_gas < 30) ],
     xlab = "Payback years",
     ylab = "Number of houses",
     main = "Payback year for envelop improvement option",
     breaks = seq(0, 30, by = 3))

insulation_rank_order <- rank_order(target_column = insulation_payback_gas,
                                    max_value = 30,
                                    min_value = 0)


hist(insulation_rank_order,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for envelop improvement payback year")


write.csv(hamilton_county_gas_heated_house, gas_heated_house_output_path)


# hamilton electric heated house ----------------------
# select electric heated house
hamilton_county_electric_heated_house <- hamilton_county[which(hamilton_county$heating_type == "electric_heated"), ]

# Heat pump system ---------------
heat_pump_electric_result <- heat_pump_electric(square_footage = hamilton_county_electric_heated_house$Sq_feet,
                                                low_HSPF = 8,
                                                low_SEER = 13,
                                                high_HSPF = 13,
                                                high_SEER = 21,
                                                annual_electric_heating = hamilton_county_electric_heated_house$annual_electric_heating_consumption_kWh,
                                                annual_electric_cooling = hamilton_county_electric_heated_house$annual_cooling_energy_consumption_kWh,
                                                standard_heat_pump_price = 6450,
                                                high_performance_heat_pump_price = 8100,
                                                electric_price = electric_price)


# 
hamilton_county_electric_heated_house$heat_pump_heating <- heat_pump_electric_result[[1]]
hamilton_county_electric_heated_house$heat_pump_heating_saving <- heat_pump_electric_result[[2]]
hamilton_county_electric_heated_house$heat_pump_heating_saving_USD <- heat_pump_electric_result[[3]]
hamilton_county_electric_heated_house$normalized_heating_intensity_high_HSPF <- heat_pump_electric_result[[4]]
hamilton_county_electric_heated_house$heat_pump_cooling <- heat_pump_electric_result[[5]]
hamilton_county_electric_heated_house$heat_pump_cooling_saving <- heat_pump_electric_result[[6]]
hamilton_county_electric_heated_house$heat_pump_cooling_saving_USD <- heat_pump_electric_result[[7]]
hamilton_county_electric_heated_house$normalized_cooling_intensity_high_SEER <- heat_pump_electric_result[[8]]
hamilton_county_electric_heated_house$heat_pump_payback_year <- heat_pump_electric_result[[9]]


# Rank order for payback years on high efficiency electric heating system
hamilton_county_electric_heated_house$rating_heat_pump_payback_year <- rank_order(target_column = hamilton_county_electric_heated_house$heat_pump_payback_year,
                                                                                         max_value = 30,
                                                                                         min_value = 0)


hist(hamilton_county_electric_heated_house$heat_pump_payback_year[which(hamilton_county_electric_heated_house$heat_pump_payback_year > 0 &
                                                                                 hamilton_county_electric_heated_house$heat_pump_payback_year < 30)],
     xlab = "Payback years",
     ylab = "Number of houses",
     main = "Payback years for heating system upgrade option",
     breaks = seq(0, 30, by = 3))


hist(hamilton_county_electric_heated_house$rating_heat_pump_payback_year,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for heating system upgrade option")


# Envelope improvement (electric) ---------------------
envelope_improvement_result_electric <- envelop_improvement_electric(square_footage = hamilton_county_electric_heated_house$Sq_feet,
                                                                     annual_electric_heating = hamilton_county_electric_heated_house$annual_electric_heating_consumption_kWh,
                                                                     annual_electric_cooling = hamilton_county_electric_heated_house$annual_cooling_energy_consumption_kWh,
                                                                     normalized_heating = hamilton_county_electric_heated_house$annual_electric_heating_consumption_intensity,
                                                                     normalized_cooling = hamilton_county_electric_heated_house$annual_cooling_energy_consumption_intensity,
                                                                     normalized_heating_eta_change = hamilton_county_electric_heated_house$normalized_heating_intensity_high_HSPF,
                                                                     normalized_cooling_eta_change = hamilton_county_electric_heated_house$normalized_cooling_intensity_high_SEER,
                                                                     electric_price = electric_price)


hamilton_county_electric_heated_house$envelop_consumption_heating <- envelope_improvement_result_electric[[1]]
hamilton_county_electric_heated_house$envelop_consumption_heating_savings <- envelope_improvement_result_electric[[2]]
hamilton_county_electric_heated_house$envelop_consumption_heating_savings_USD <- envelope_improvement_result_electric[[3]]
hamilton_county_electric_heated_house$envelop_consumption_cooling <- envelope_improvement_result_electric[[4]]
hamilton_county_electric_heated_house$envelop_consumption_cooling_savings <- envelope_improvement_result_electric[[5]]
hamilton_county_electric_heated_house$envelop_consumption_cooling_savings_USD <- envelope_improvement_result_electric[[6]]
hamilton_county_electric_heated_house$envelop_improvement_savings <- envelope_improvement_result_electric[[7]]



# If the rank value is really small means, the residential house does not need any upgrade
hamilton_county_electric_heated_house$rank_envelop_improvement_savings <- rank_order(target_column = hamilton_county_electric_heated_house$envelop_improvement_savings,
                                                                                     max_value = 1500,
                                                                                     min_value = 0)

hist(hamilton_county_electric_heated_house$envelop_improvement_savings[which(hamilton_county_electric_heated_house$envelop_improvement_savings > 0 &
                                                                               hamilton_county_electric_heated_house$envelop_improvement_savings < 1500)],
     xlab = "Annual savings (USD/year)",
     ylab = "Number of houses",
     main = "Envelop improvement upgrade option",
     breaks = seq(0,1500,by=150))

hist(hamilton_county_electric_heated_house$rank_envelop_improvement_savings,
     xlab = "Rank index",
     ylab = "Number of houses",
     main = "Ranking for envelop improvement upgrade option")


write.csv(hamilton_county_electric_heated_house, electric_heated_house_output_path)



# combine two dataset together 
# Use dplyr is faster than option 2
library(dplyr)
hamilton_county_upgrade_options <- bind_rows(hamilton_county_gas_heated_house ,hamilton_county_electric_heated_house)
# Option 2
# use setdiff(names(df1), names(df2)) could quickly find out the name difference 
# hamilton_county_upgrade_options <- rbind(hamilton_county_gas_heated_house, hamilton_county_electric_heated_house)

output_path <- "/Users/qianchengsun/Desktop/Empowersaves/Code_package/Database/hamilton_county_upgrade_options_2.csv"
write.csv(hamilton_county_upgrade_options, output_path)



