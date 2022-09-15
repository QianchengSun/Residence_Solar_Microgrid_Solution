# Software introduction:
# This is the solar calculation software for the solar choice for different residential house


# Work flow introduction:
# 1. Need to build a for loop to continuesly calculate the residential solar options which include:
#    1). Obtain the residential house address (from residential energy consumption data)
#    2). Obtain the scale factor for each house (from residential energy consumption data)
#    3). Obtain the consumption type for each house (from residential energy consumption data [include "High", "Base", "Low"])
#    4). Match with the typical energy consumption dataset (from NREL)
#    5). Obtain the typical solar energy production (hourly) for the residential house
#    6). Obtain the maximum value to get the AC capacity, then could transfer into DC capacity. (multiple 1.2)

# 2. Use solar API to access PV watts website to obtain the solar production data. 

#%%
# load packages
import requests # use requests to obtain the information from URL
import pandas as pd
import os 
import json
import numpy as np
import os
import tqdm



# read typical energy consumption file (include "High", "Base", and "Low")
"""
Low energy consumption house (typical)
"""
low_path = r"/Users/qianchengsun/Desktop/Empowersaves/Code_package/solar_payback/RESIDENTIAL_LOAD_DATA_E_PLUS_OUTPUT/LOW"
# show the working directory as a list in the folder
low_list = os.listdir(low_path)
# add folder path and .csv file path together to generate the path for each csv file
file_name_list = []
for i in range(len(low_list)):
    low_file_name = os.path.join(low_path,low_list[i])
    file_name_list.append(low_file_name)






#%%
# read text file
def read_text_file(file_path):
    with open(file_path,'r') as f:
        print(f.read())

# iterate through all file
for file in os.listdir():
    # Check whether file is in text format or not
    if file.endswith(".csv"):
        file_path = f"{file_path}\{file}"
  
        # call read text file function
        read_text_file(file_path)





























# %%
energy_consumption_file_path = r"/Users/qianchengsun/Desktop/Empower_energy_project/report/Hamilton_county/baseload/TMY_baseload/hamilton_county_TMY_result.csv"
energy_consumption_data = pd.read_csv(energy_consumption_file_path)

energy_consumption_data["Address"]