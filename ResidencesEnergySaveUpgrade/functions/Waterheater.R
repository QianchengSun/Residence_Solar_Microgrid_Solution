# High efficiency water heater upgrade option ---------------------
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

