# Water heater heat pump upgrade option --------------------------------
heat_pump_water_heater <- function(typical_water_heater_efficiency,
                                   water_heater_heat_pump_COP,
                                   annual_water_heater_consumption,
                                   water_heater_heat_pump_price,
                                   typical_water_heater_price,
                                   gas_price,
                                   electric_price){
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


    # calculate water heat pump saving in USD

    water_heater_output <- annual_water_heater_consumption * typical_water_heater_efficiency # CCF
    # water heater heat pump input in kWh
    water_heater_input <- water_heater_output * 10 ^ 5 / 3413 / water_heater_heat_pump_COP 

    # therefore need to convert into gas consumption into electricity
    water_heater_heat_pump_saving_USD <- annual_water_heater_consumption * gas_price - water_heater_input * electric_price
    # calculate payback years by using water heater heat pump in gas heated house
    water_heater_heat_pump_payback <- (water_heater_heat_pump_price - typical_water_heater_price) / water_heater_heat_pump_saving_USD

    # generate list
    heat_pump_water_heater_list <- list(water_heater_heat_pump_saving_USD,
                                        water_heater_heat_pump_payback)
    return (heat_pump_water_heater_list)
}
