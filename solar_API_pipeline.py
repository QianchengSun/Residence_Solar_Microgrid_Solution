# this the pipeline for run the solar_API package 
 
#%%
# load packages
import pandas as pd
import os 
import json
import numpy as np
import sys
from geneticalgorithm import geneticalgorithm as ga

solar_API_path = os.path.join(__file__)
sys.path.append(solar_API_path)
import solar_API

def obtain_PV_AC_output(data):
    """
    Description:
    The obtain_PV_AC_output() is used for obtaining the solar PV AC output.

    Arguments:

        Input:
            data: dataframe of the solar data from solar PV system. (data frame)

        Output: 
            solar_PV_kW_per_kW_capacity: the AC output per solar PV capacity in kWh
            
    """


    solar_PV_kW_per_kW_capacity = data["Hourly AC System Output (W)"] / 1000

    return (solar_PV_kW_per_kW_capacity)
 
def obtain_typical_consumption(file, NREL_file):
    """
    Description:
    This function is used for obtain the typical electric consumption for different residential house.
    For each residential house, based on the energy consumption type will have the "high", "base", and "low" with different scale factor.
    Therefore, this will dynamically obtain the typical consumption for different house with the input data
    """
    
    typical_electric_consumption = NREL_file["Electricity:Facility [kW](Hourly)"] / file["scale_factor"][i]


    return (typical_electric_consumption)


# Final version of simple payback for residential house calculation

def calculate_simple_payback(solar_capacity_kW):
    """
    Description
    ------------
    The calculate_simple_payback() is used to optimize the minimum payback year of the residential house by installing the solar panel





    OUtput
    ------

    After using Genetic Algorithm to optimize the solar capacity and the payback years.

    The output will include two parts:

    1. "The best solution found", in here, the best solution repersent for the best input x, 
                                        which means the best solar capacity for the current residential house

    2. "Objective function", in here, the objective function represent for the best output y, 
                                    which means the minimum payback year for installing the solar panel on current residential house

    """

    # solar_capacity_kW is the input for number of solar capacity that need for the residential house

    solar_PV_kW_per_kW_capacity = obtain_PV_AC_output(solar_data) # create a function about obtaining solar data value

    load_energy_consumption = obtain_typical_consumption(file, NREL_file) # create a function about obtaining the electric consumption 
    
    cost_capital_solar_PV_per_kW = 1.77 * 1000

    tax_incentive_solar_PV = 0.26

    cost_solar_pv_system_OM_per_kW_per_year = 12

    # calculate hourly generation, kW
    solar_PV_hourly_kW = solar_PV_kW_per_kW_capacity * solar_capacity_kW
    solar_PV_hourly_kW = np.array(solar_PV_hourly_kW).reshape(8760,1)
    # energy consumption (load)
    load_hourly_kW = load_energy_consumption 
    load_hourly_kW = np.array(load_hourly_kW).reshape(8760,1)
    # create NA values
    solar_excess_hr_kW_list = []
    solar_behind_meter_hr_kW_list = []

    for i in range(0, len(load_hourly_kW)):
        if(solar_PV_hourly_kW[i] >= load_hourly_kW[i]):
            solar_excess_hr_kW = solar_PV_hourly_kW[i] - load_hourly_kW[i]
            solar_behind_meter_hr_kW = load_hourly_kW[i]
        else:
            solar_excess_hr_kW = 0
            solar_behind_meter_hr_kW = solar_PV_hourly_kW[i]
        # append into list
        solar_excess_hr_kW_list.append(solar_excess_hr_kW)
        solar_behind_meter_hr_kW_list.append(solar_behind_meter_hr_kW)


    # Annual solar excess
    annual_solar_excess_kW = sum(solar_excess_hr_kW_list)
  
    # cost saved behind meter solar 
    behind_meter_price = 0.2
    cost_saved_behind_meter_solar_hr = np.array(solar_behind_meter_hr_kW_list, dtype = object) * behind_meter_price
  
    # annual cost saved behind meter solar 
    annual_cost_saved_behind_meter_solar = sum(cost_saved_behind_meter_solar_hr)
  
    # Income excess solar 
    generation_rate = 0.1
    income_excess_solar_hr = np.array(solar_excess_hr_kW_list, dtype=object) * generation_rate

    # annual income excess solar 
    annual_income_excess_solar = sum(income_excess_solar_hr)

    # annual total income
    annual_total_income = annual_income_excess_solar + annual_cost_saved_behind_meter_solar
    
    # solar install cost
    solar_install_cost = solar_capacity_kW * cost_capital_solar_PV_per_kW * (1 - tax_incentive_solar_PV)
    
    # solar maintenance cost annual 
    solar_maintenance_cost_annual = cost_solar_pv_system_OM_per_kW_per_year * solar_capacity_kW
    
    # simple payback 
    simple_payback = solar_install_cost / (annual_total_income - solar_maintenance_cost_annual)
    
    return(simple_payback)


def calculate_cost_per_kWh(solar_capacity_kW):
    """
    Description
    ------------

    The calculate cost per kWh function is used to optimize the cost per kWh after installing the solar panel for residence.



    Argument
    -----------

    solar_capacity_kW: the solar capacity for the solar system




    Output
    --------

    cost_per_kWh: the optimized solution on electricity cost after installing the solar panel.
    
    
    """

    # solar_capacity_kW is the input for number of solar capacity that need for the residential house

    solar_PV_kW_per_kW_capacity = obtain_PV_AC_output(solar_data) # create a function about obtaining solar data value

    load_energy_consumption = obtain_typical_consumption(file, NREL_file) # create a function about obtaining the electric consumption 

    
    cost_capital_solar_PV_per_kW = 1.77 * 1000

    tax_incentive_solar_PV = 0.26

    cost_solar_pv_system_OM_per_kW_per_year = 12

    # calculate hourly generation, kW
    solar_PV_hourly_kW = solar_PV_kW_per_kW_capacity * solar_capacity_kW
    solar_PV_hourly_kW = np.array(solar_PV_hourly_kW).reshape(8760,1)
    # energy consumption (load)
    load_hourly_kW = load_energy_consumption 
    load_hourly_kW = np.array(load_hourly_kW).reshape(8760,1)
    # create NA values
    solar_excess_hr_kW_list = []
    solar_behind_meter_hr_kW_list = []

    for i in range(0, len(load_hourly_kW)):
        if(solar_PV_hourly_kW[i] >= load_hourly_kW[i]):
            solar_excess_hr_kW = solar_PV_hourly_kW[i] - load_hourly_kW[i]
            solar_behind_meter_hr_kW = load_hourly_kW[i]
        else:
            solar_excess_hr_kW = 0
            solar_behind_meter_hr_kW = solar_PV_hourly_kW[i]
        # append into list
        solar_excess_hr_kW_list.append(solar_excess_hr_kW)
        solar_behind_meter_hr_kW_list.append(solar_behind_meter_hr_kW)


    # Annual solar excess
    annual_solar_excess_kW = sum(solar_excess_hr_kW_list)
  
    # cost saved behind meter solar 
    behind_meter_price = 0.2
    cost_saved_behind_meter_solar_hr = np.array(solar_behind_meter_hr_kW_list, dtype = object) * behind_meter_price
  
    # annual cost saved behind meter solar 
    annual_cost_saved_behind_meter_solar = sum(cost_saved_behind_meter_solar_hr)
  
    # Income excess solar 
    generation_rate = 0.1
    income_excess_solar_hr = np.array(solar_excess_hr_kW_list, dtype=object) * generation_rate

    # annual income excess solar 
    annual_income_excess_solar = sum(income_excess_solar_hr)

    # annual total income
    annual_total_income = annual_income_excess_solar + annual_cost_saved_behind_meter_solar
    
    # solar install cost
    solar_install_cost = solar_capacity_kW * cost_capital_solar_PV_per_kW * (1 - tax_incentive_solar_PV)
    
    # solar maintenance cost annual 
    solar_maintenance_cost_annual = cost_solar_pv_system_OM_per_kW_per_year * solar_capacity_kW
    
    # simple payback 
    simple_payback = solar_install_cost / (annual_total_income - solar_maintenance_cost_annual)

    # calculate the cost per kWh
    cost_per_hr = load_energy_consumption * behind_meter_price - income_excess_solar_hr - cost_saved_behind_meter_solar_hr.reshape(8760)

    cost_per_hr[cost_per_hr < 0] = 0

    # cost per kWh 
    cost_per_kWh = np.mean(cost_per_hr / load_hourly_kW.reshape(8760))
    
    return(cost_per_kWh)


#%%
"""
Solar optimization pipeline
"""
# read target file
file_path = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/Test_solar_API/hamilton_county.csv"
file = pd.read_csv(file_path)
# In here, only need to obtain the address as the solar API input
target_address = file["Address"]
actual_annual_electric_consumption = file["typical_annual_electric_consumption"]


# NREL file path (Only for Cincinnati area ---- Hamilton County)

# High NREL electric consumption
NREL_path_1 = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/NREL_consumption/HIGH/USA_OH_Cincinnati.Muni.AP-Lunken.Field.724297_TMY3_HIGH.csv"

# Base NREL electric consumption
NREL_path_2 = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/NREL_consumption/BASE/USA_OH_Cincinnati.Muni.AP-Lunken.Field.724297_TMY3_BASE.csv"

# Low NREL electric consumption
NREL_path_3 = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/NREL_consumption/LOW/USA_OH_Cincinnati.Muni.AP-Lunken.Field.724297_TMY3_LOW.csv"


NREL_file_high = pd.read_csv(NREL_path_1) # High consumption
NREL_file_base = pd.read_csv(NREL_path_2) # Base consumption
NREL_file_low = pd.read_csv(NREL_path_3) # Low consumption


# solar API setup
api_key = "OmLmJHgTudxD6hHchGkPc30zvBTFGNf2Q2Idt8AB"
# url for obtain PV watts dataset
pv_watts_url = "https://developer.nrel.gov/api/pvwatts/v6"
# data format
data_format = ".json"
# location latitude
# lat = "39.77" # type = decimal, range = (-90, 90)
# location longitude 
# lon = "-84.18" # type = decimal, range = (-180, 180)
# system capacity, Nameplates capacity(kW)
system_capacity = "1" # type = decimal, range = (0.05, 500000)
module_type = "0" # Here step up the module type is Standard
# System loss (precent)
losses = "10" # data type = decimal, range = (-5, 99)
# array_type 
array_type = "0" # data type = integer
# tilt angle degrees
tilt = "20" # data type = decimal, range = [0, 90]
# azimuth angle
azimuth = "180" # data type = decimal, range = (0,360)
# time frame 
timeframe = "hourly"
# path for save the data
output_path = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/Test_solar_API"

optimized_solar_capacity_list = []
optimized_payback_year_list = [] 
optimized_cost_per_kWh_list = []

# len(target_address)
for i in range(0, len(target_address)):
    print(file["consumption_type"][i])
    if file["consumption_type"][i] == "High":
            NREL_file = NREL_file_high
            # NREL high need to remove duplicate rows
            NREL_file = NREL_file.drop(range(0, 24))
    elif file["consumption_type"][i] == "Base":
            NREL_file = NREL_file_base

    else:
            NREL_file = NREL_file_low
            # NREL high need to remove duplicate rows
            NREL_file = NREL_file.drop(range(0, 24))
    
    typical_electric_consumption =  NREL_file["Electricity:Facility [kW](Hourly)"] / file["scale_factor"][i]

    address = file["Address"][i]

    print(address)

    solar_data_json = solar_API.solar_PV_watts_API(api_key= api_key,
                                    solar_api_url= pv_watts_url,
                                    data_format= data_format, 
                                    address = address,
                                    system_capacity= system_capacity, 
                                    module_type= module_type,
                                    losses= losses,
                                    array_type= array_type,
                                    tilt= tilt,
                                    azimuth= azimuth,
                                    timeframe= timeframe,
                                    output_dir = output_path)

    # Obtain the hourly solar PV data
    solar_data = solar_API.solar_data_from_json(input_data= solar_data_json,
                                output_dir= output_path,
                                time_switch= False) # data include the solar PV data

    boundary = np.array([[np.max(typical_electric_consumption),10]])
    if boundary[:, 0] >= boundary[:,1]:
        boundary = np.array([[0, 10]])

    # set up algorithm parameters
    algorithm_parameters={'max_num_iteration':100,\
                        "population_size":150,\
                        'mutation_probability':0.01,\
                        'elit_ratio':0,\
                        'crossover_probability':0.8,\
                        'parents_portion':0.3,\
                        # the option is uniform, one_point, two_point
                        'crossover_type': 'uniform',\
                        'max_iteration_without_improv': 10}

    # run GA optimization
    payback_optimization_model = ga(function= calculate_simple_payback,
                                dimension= 1,
                                variable_type= "real",
                                variable_boundaries= boundary,
                                algorithm_parameters=algorithm_parameters,
                                convergence_curve= True, # plot the convergence curve or not 
                                progress_bar= True) # show the progress bar or not


    # Best solution is the x input
    # objective function is the y output

    payback_optimization_model.run()
    convergence = payback_optimization_model.report
    solution = payback_optimization_model.output_dict

    

    # set up boundary for the fixed solar capacity
    boundary_2 = np.array([[np.min(convergence), np.max(convergence) + 0.001 ]])

    cost_optimization_model = ga(function = calculate_cost_per_kWh,
                                            dimension = 1, 
                                            variable_type = "real", 
                                            variable_boundaries= boundary_2,
                                            algorithm_parameters= algorithm_parameters,
                                            convergence_curve= True,
                                            progress_bar= True)

    cost_optimization_model.run()
    cost_convergence = cost_optimization_model.report
    cost_solution = cost_optimization_model.output_dict

    optimized_solar_capacity = cost_solution["variable"]
    optimized_payback_year = solution["function"]
    optimized_cost_per_kWh = cost_solution["function"]
    
    optimized_solar_capacity_list.append(optimized_solar_capacity)
    optimized_payback_year_list.append(optimized_payback_year)
    optimized_cost_per_kWh_list.append(optimized_cost_per_kWh)
#%%
# save as csv file
# add solar capacity to the dataset
file["solar_capacity"] = ""
file["solar_capacity"].iloc[:len(optimized_solar_capacity_list)] = optimized_solar_capacity_list



# add optimized payback year to the dataset
file["optimized_payback_year"] = ""
file["optimized_payback_year"].iloc[:len(optimized_payback_year_list)] = optimized_payback_year_list

# add optimized cost per kWh
file["optimized_cost_per_kWh"] = ""
file["optimized_cost_per_kWh"].iloc[:len(optimized_cost_per_kWh_list)] = optimized_cost_per_kWh_list

output_path = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/Test_solar_API/solar_capacity_demo.csv"
file.to_csv(output_path)

"""
Impact of Net Energy Cost is developed in R
Reference link for the cost is list below:
"""
# monthly solar loan : 50 ~250
# reference website:
# https://www.supermoney.com/much-cost-lease-solar-power-system-supermoney-solar-installation-cost-guide/

# monthly electric bill: 171
# reference website
# https://www.energysage.com/local-data/electricity-cost/oh/


#%%


"""
Example:

Here is the example to show the solar optimization for several houses from the dataset

"""

i = 30
if file["consumption_type"][i] == "High":
        NREL_file = NREL_file_high
        # NREL high need to remove duplicate rows
        NREL_file = NREL_file.drop(range(0, 24))
elif file["consumption_type"][i] == "Base":
        NREL_file = NREL_file_base

else:
        NREL_file = NREL_file_low
        # NREL high need to remove duplicate rows
        NREL_file = NREL_file.drop(range(0, 24))

typical_electric_consumption = NREL_file["Electricity:Facility [kW](Hourly)"] / file["scale_factor"][i]

address = file["Address"][i]

print(address)
solar_data_json = solar_API.solar_PV_watts_API(api_key= api_key,
                                solar_api_url= pv_watts_url,
                                data_format= data_format, 
                                address = address,
                                system_capacity= system_capacity, 
                                module_type= module_type,
                                losses= losses,
                                array_type= array_type,
                                tilt= tilt,
                                azimuth= azimuth,
                                timeframe= timeframe,
                                output_dir = output_path)

    # Obtain the hourly solar PV data
solar_data = solar_API.solar_data_from_json(input_data= solar_data_json,
                            output_dir= output_path,
                            time_switch= False) # data include the solar PV data


boundary = np.array([[np.max(typical_electric_consumption),10]])
if boundary[:, 0] >= boundary[:,1]:
        boundary = np.array([[0, 10]])
# set up algorithm parameters
algorithm_parameters={'max_num_iteration':100,\
                    "population_size":150,\
                    'mutation_probability':0.01,\
                    'elit_ratio':0,\
                    'crossover_probability':0.8,\
                    'parents_portion':0.3,\
                    # the option is uniform, one_point, two_point
                    'crossover_type': 'uniform',\
                    'max_iteration_without_improv': 10}

# run GA optimization
payback_optimization_model = ga(function= calculate_simple_payback,
                            dimension= 1,
                            variable_type= "real",
                            variable_boundaries= boundary,
                            algorithm_parameters=algorithm_parameters,
                            convergence_curve= True, # plot the convergence curve or not 
                            progress_bar= True) # show the progress bar or not


# Best solution is the x input
# objective function is the y output


payback_optimization_model.run()
convergence = payback_optimization_model.report
solution = payback_optimization_model.output_dict


optimized_solar_capacity = solution["variable"]
optimized_payback_year = solution["function"]
#%%
# # set up boundary for the fixed solar capacity
boundary_2 = np.array([[np.min(convergence), np.max(convergence) + 0.001 ]])

cost_optimization_model = ga(function = calculate_cost_per_kWh,
                                            dimension = 1, 
                                            variable_type = "real", 
                                            variable_boundaries= boundary_2,
                                            algorithm_parameters= algorithm_parameters,
                                            convergence_curve= True,
                                            progress_bar= True)

cost_optimization_model.run()
cost_convergence = cost_optimization_model.report
cost_solution = cost_optimization_model.output_dict

#%%
"""
Step by step validating.
"""
solar_capacity_kW = 5
solar_PV_kW_per_kW_capacity = obtain_PV_AC_output(solar_data) # create a function about obtaining solar data value

load_energy_consumption = obtain_typical_consumption(file, NREL_file) # create a function about obtaining the electric consumption 

electric_price = 0.14

cost_capital_solar_PV_per_kW = 1.77 * 1000

tax_incentive_solar_PV = 0.26

cost_solar_pv_system_OM_per_kW_per_year = 12

# calculate hourly generation, kW
solar_PV_hourly_kW = solar_PV_kW_per_kW_capacity * solar_capacity_kW
solar_PV_hourly_kW = np.array(solar_PV_hourly_kW).reshape(8760,1)
# energy consumption (load)
load_hourly_kW = load_energy_consumption 
load_hourly_kW = np.array(load_hourly_kW).reshape(8760,1)
# create NA values
solar_excess_hr_kW_list = []
solar_behind_meter_hr_kW_list = []

for i in range(0, len(load_hourly_kW)):
    if(solar_PV_hourly_kW[i] >= load_hourly_kW[i]):
        solar_excess_hr_kW = solar_PV_hourly_kW[i] - load_hourly_kW[i]
        solar_behind_meter_hr_kW = load_hourly_kW[i]
    else:
        solar_excess_hr_kW = 0
        solar_behind_meter_hr_kW = solar_PV_hourly_kW[i]
    # append into list
    solar_excess_hr_kW_list.append(solar_excess_hr_kW)
    solar_behind_meter_hr_kW_list.append(solar_behind_meter_hr_kW)


# Annual solar excess
annual_solar_excess_kW = sum(solar_excess_hr_kW_list)

# cost saved behind meter solar 
behind_meter_price = 0.2
cost_saved_behind_meter_solar_hr = np.array(solar_behind_meter_hr_kW_list, dtype = object) * behind_meter_price

# annual cost saved behind meter solar 
annual_cost_saved_behind_meter_solar = sum(cost_saved_behind_meter_solar_hr)

# Income excess solar 
generation_rate = 0.1
income_excess_solar_hr = np.array(solar_excess_hr_kW_list, dtype=object) * generation_rate

# annual income excess solar 
annual_income_excess_solar = sum(income_excess_solar_hr)

# annual total income
annual_total_income = annual_income_excess_solar + annual_cost_saved_behind_meter_solar

# solar install cost
solar_install_cost = solar_capacity_kW * cost_capital_solar_PV_per_kW * (1 - tax_incentive_solar_PV)

# solar maintenance cost annual 
solar_maintenance_cost_annual = cost_solar_pv_system_OM_per_kW_per_year * solar_capacity_kW

# simple payback 
simple_payback = solar_install_cost / (annual_total_income - solar_maintenance_cost_annual)

# calculate the cost per kWh
cost_per_hr = load_energy_consumption * electric_price - income_excess_solar_hr - cost_saved_behind_meter_solar_hr.reshape(8760)

cost_per_hr[cost_per_hr < 0] = 0

# cost per kWh 
cost_per_kWh = np.mean(cost_per_hr / load_hourly_kW.reshape(8760))
# %%
