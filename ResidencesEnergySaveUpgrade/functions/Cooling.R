# Cooling system (gas heated house) --------------------
# Note:
# the cooling system need to use SEER to do the calculation
# instead of using efficiency
cooling_upgrade <- function(SEER_low,
                            SEER_high,
                            electric_price,
                            annual_electric_cooling,
                            square_footage,
                            typical_SEER_system_price,
                            high_SEER_cooling_system_price){

  # Description:
  # cooling_upgrade() is a function that used to calculate the energy consumption savings after change into high efficiency cooling system
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




