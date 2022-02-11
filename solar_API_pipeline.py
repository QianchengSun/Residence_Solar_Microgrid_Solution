# this the pipeline for run the solar_API package 
 
#%%
# load packages
import requests # use requests to obtain the information from URL
import pandas as pd
import os 
import json
import numpy as np
import sys
solar_API_path = os.path.join(__file__)
sys.path.append(solar_API_path)
import solar_API

def main():
    #%% test for obtain the data from API dataset
    api_key = "OmLmJHgTudxD6hHchGkPc30zvBTFGNf2Q2Idt8AB"
    # url for obtain PV watts dataset
    pv_watts_url = "https://developer.nrel.gov/api/pvwatts/v6"
    # data format
    data_format = ".json"
    # location latitude
    lat = "39.77" # type = decimal, range = (-90, 90)
    # location longitude 
    lon = "-84.18" # type = decimal, range = (-180, 180)
    # system capacity, Nameplates capacity(kW)
    system_capacity = "4" # type = decimal, range = (0.05, 500000)
    module_type = "0" # Here step up the modu;e type is Standard
    # System loss (precent)
    losses = "10" # data type = decimal, range = (-5, 99)
    # array_type 
    array_type = "0" # data type = integer
    # tilt angle degrees
    tilt = "45" # data type = decimal, range = [0, 90]
    # azimuth angle
    azimuth = "60" # data type = decimal, range = (0,360)
    # time frame 
    timeframe = "hourly"
    # path for save the data
    output_path = r"/Users/qianchengsun/PhD/github/Solar_API/"
    """
    Use function from solar_API package to obtain the data through API, and generate csv file
    """
    solar_data = solar_API.solar_PV_watts_API(api_key= api_key,
                                solar_api_url= pv_watts_url,
                                data_format= data_format, 
                                latitude= lat,
                                longitude= lon,
                                system_capacity= system_capacity, 
                                module_type= module_type,
                                losses= losses,
                                array_type= array_type,
                                tilt= tilt,
                                azimuth= azimuth,
                                timeframe= timeframe,
                                output_dir = output_path)
    data = solar_API.solar_data_from_json(input_data= solar_data,
                            output_dir= output_path,
                            time_switch= False)

# apply the main function 
if __name__=='__main__':
    main()

# %%
