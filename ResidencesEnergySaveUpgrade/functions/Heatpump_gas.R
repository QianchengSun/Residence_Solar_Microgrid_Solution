# Heat pump upgrade option for gas heated house ---------------------------------
heat_pump_gas <- function(annual_gas_heating,
                          annual_electric_cooling,
                          typical_heating_efficiency,
                          typical_heating_system_price,
                          typical_cooling_SEER,
                          typical_cooling_system_price,
                          heat_pump_SEER,
                          heat_pump_HSPF,
                          heat_pump_price,
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


