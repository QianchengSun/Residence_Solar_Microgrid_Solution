# Heat pump (electric heated house) -----------------------
heat_pump_electric <- function(square_footage,
                            low_HSPF,
                            low_SEER,
                            high_HSPF,
                            high_SEER,
                            annual_electric_heating,
                            annual_electric_cooling,
                            standard_heat_pump_price,
                            high_performance_heat_pump_price,
                            electric_price){
    # Description:
    #   For electric heated house, most of the residential house use heat pump for heating.
    #   However, the heat pump also could be used for cooling, therefore, in this function, 
    #   It should include heating and cooling in this function for electric heated house



    # Arguments:
    # Input:
    #       square_footage: the square footage of residential house (ft^2)
    #       low_HSPF: HSPF for standard heat pump
    #       low_SEER: SEER for standard heat pump
    #       high_HSPF: HSPF for high performance heat pump
    #       high_SEER: SEER for high performance heat pump
    #       annual_electric_heating: annual electric consumption in heating (kWh)
    #       annual_electric_cooling: annual electric consumption in cooling (kWh)
    #       standard_heat_pump_price: investment price for standard heat pump (USD)
    #       high_performance_heat_pump_price: investment price for high performance heat pump (USD)
    #       electric_price: local electric price (USD)


    #   Output:
    #       heating_input: electric consumption for high performance heat pump in heating (kWh)
    #       heating_saving: electric consumption saving in heating after installing the high performance heat pump (kWh)
    #       heating_saving_USD: electric consumption saving in USD after installing the high performance heat pump (USD)
    #       normalized_heating_high_HSPF: the heating intensity after installing the high performance heat pump (kWh/ft^2)
    #       cooling_input: electric consumption for high performance heat pump in cooling (kWh)
    #       cooling_saving: electric consumption saving in cooling after installing the high performance heat pump (kWh)
    #       cooling_saving_USD: electric consumption saving in USD after installing the high performance heat pump (USD)
    #       normalized_cooling_high_SEER: the cooling intensity after installing the high performance heat pump (kWh/ ft^2)
    #       payback_year: payback years for changing into high performance heat pump system (yr)
    
    # heating ------------------------------------
    # heating output
    heating_output <- annual_electric_heating * 1000 * low_HSPF / 3412
    
    # heating input with high HSPF
    heating_input <- heating_output * 3412 / high_HSPF / 1000

    # heating saving
    heating_saving <- annual_electric_heating - heating_input

    # heating saving in USD after change into high HSPF system
    heating_saving_USD <- heating_saving * electric_price 

    # heating intensity after change into high HSPF
    normalized_heating_high_HSPF <- heating_input / square_footage


    # cooling ----------------------------------------
    # cooling output (Btu)
    cooling_output <- low_SEER * annual_electric_cooling * 1000 # convert kWh into Wh

    # cooling input with high SEER
    cooling_input <- cooling_output / high_SEER / 1000

    # cooling saving
    cooling_saving <- annual_electric_cooling - cooling_input 

    # cooling saving in USD after change into high SEER system
    cooling_saving_USD <- cooling_saving * electric_price

    # cooling intensity after change into high SEER
    normalized_cooling_high_SEER <- cooling_input / square_footage

    # Payback years --------------------------------
    # payback years by change into high performace heat pump
    payback_year <- (high_performance_heat_pump_price - standard_heat_pump_price) / (heating_saving_USD + cooling_saving_USD)

    return_list <- list(heating_input,
                        heating_saving,
                        heating_saving_USD,
                        normalized_heating_high_HSPF,
                        cooling_input,
                        cooling_saving,
                        cooling_saving_USD,
                        normalized_cooling_high_SEER,
                        payback_year)

}
