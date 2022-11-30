# Envelope improvement for gas heated house ------------------------------
envelop_improvement_gas <- function(square_footage,
                                    heating_degree_hours,
                                    annual_gas_heating,
                                    annual_electric_cooling,
                                    typical_heating_efficiency,
                                    normalized_heating,
                                    normalized_cooling,
                                    normalized_heating_eta_change,
                                    normalized_cooling_eta_change,
                                    electric_price,
                                    gas_price){
  # Description:
  # envelop_improvement_gas() function is used to estimate the savings by improve the residential building envelop
  # in the envelope improvement for gas heated house, two things need to considered
  # 1) heating savings 
  # - gas input furnace saving
  # 2) cooling savings
  # - high SEER cooling saving


  # Arguments:
  #   Input:
  #     heating_degree_hours: heating degree hours that calculated by using heating_degree_hours() function
  #     annual_gas_heating: annual gas consumption in heating (unit CCF)
  #     annual_electric_cooling: annual electric consumption in cooling (unit kWh)
  #     typical_heating_efficiency: typical efficiency for heating system (here, define as 0.8)
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
    # energy consumption on envelop (kWh)
    envelop_consumption_cooling <- square_footage * (normalized_cooling_eta_change + sd(normalized_cooling_eta_change)) / normalized_cooling

    # energy consumption savings in cooling
    envelop_consumption_cooling_savings <- annual_electric_cooling - envelop_consumption_cooling
    # fix the value
    envelop_consumption_cooling_savings <- ifelse(envelop_consumption_cooling_savings < 0, 0, envelop_consumption_cooling_savings)

    # energy consumption cooling savings in USD
    envelop_consumption_cooling_savings_USD <- envelop_consumption_cooling_savings * electric_price

    # total savings by change the envelop (USD) -----------------------------------------------
    envelop_improvement_savings <- envelop_consumption_heating_savings_USD + envelop_consumption_cooling_savings_USD

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

