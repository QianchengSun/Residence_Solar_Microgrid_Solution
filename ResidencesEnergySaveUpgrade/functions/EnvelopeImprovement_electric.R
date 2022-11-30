# Envelope improvement for electric heated house -----------------------
envelop_improvement_electric <- function(square_footage,
                                        annual_electric_heating,
                                        annual_electric_cooling,
                                        normalized_heating,
                                        normalized_cooling,
                                        normalized_heating_eta_change,
                                        normalized_cooling_eta_change,
                                        electric_price){
  # Description:
  # envelop_improvement_electric() function is used to estimate the savings by improve the residential building envelop
  # in this envelope improvement for electric heated house, include two savings
  # 1) heating 
  # 2) cooling 
  # heating and cooling are saved by the heat pump

  # Arguments:
    # Input: 
    #   square_footage: square footage of residential house
    #   annual_electric_heating: annual electric consumption in heating (kWh)
    #   annual_electric_cooling: annual electric consumption in cooling (kWh)
    #   normalized_heating: the electric heating intensity before envelope improvement (kWh/ft^2)
    #   normalized_cooling: the electric cooling intensity before envelope improvement (kWh/ft^2)
    #   normalized_heating_eta_change: the electric heating intensity after envelope improvement (kWh/ft^2)
    #   normalized_cooling_eta_change: the electric cooling intensity after envelope improvement (kWh/ft^2)
    #   electric_price: local electric price (USD/kWh)

    # Output:
    #   envelop_consumption_heating: the enevelope consumption in heating after the envelope improvement (kWh)
    #   envelop_consumption_heating_savings: the envelope consumption saving in heating after the envelope improvement (kWh)
    #   envelop_consumption_heating_savings_USD: heating savings after the envelope improvement (USD)
    #   envelop_consumption_cooling: the envelope consumption in cooling after the envelope improvement (kWh)
    #   envelop_consumption_cooling_savings: the envelope consumption saving in cooling after the envelope improvement (kWh)
    #   envelop_consumption_cooling_savings_USD: cooling savings after the envelope improvement (USD)
    #   envelop_improvement_savings: total savings in heating & cooling after the envelope improvement (USD)


    # heating system -----------------------------------------------------

    # energy consumption on envelop improvement in heating (CCF)
    envelop_consumption_heating <-  square_footage * (normalized_heating_eta_change + sd(normalized_heating_eta_change)) / normalized_heating

    # energy consumption savings in heating (CCF)
    envelop_consumption_heating_savings <- annual_electric_heating - envelop_consumption_heating
    # fix the value
    # Note:
    # Here, change the negative value become 0,
    # which means the original envelope for the residential house is good enough, which is not necessary change
    envelop_consumption_heating_savings <- ifelse(envelop_consumption_heating_savings < 0, 0, envelop_consumption_heating_savings)

    # energy consumption heating savings in USD
    envelop_consumption_heating_savings_USD <- envelop_consumption_heating_savings * electric_price

    # cooling system ---------------------------------------------------------------------
    # energy consumption on envelop (kWh)
    envelop_consumption_cooling <- square_footage * (normalized_cooling_eta_change + sd(normalized_cooling_eta_change)) / normalized_cooling

    # energy consumption savings in cooling
    envelop_consumption_cooling_savings <- annual_electric_cooling - envelop_consumption_cooling
    # fix the value
    envelop_consumption_cooling_savings <- ifelse(envelop_consumption_cooling_savings < 0, 0, envelop_consumption_cooling_savings)

    # energy consumption cooling savings in USD
    envelop_consumption_cooling_savings_USD <- envelop_consumption_cooling_savings * electric_price

    # total savings by change the envelop (USD) ---------------------------------------------
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
