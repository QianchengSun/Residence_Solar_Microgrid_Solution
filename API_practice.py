## This is the code for request data from PV watts API

#%% Load packages 

# https://developer.nrel.gov/docs/solar/nsrdb/himawari-download/


from array import array
import requests # use requests to obtain the information from URL
# use your personal token to access the API
"""
Please enter your own personal token to access the API
Weblink for obtain API Key :
https://developer.nrel.gov/docs/solar/nsrdb/himawari-download/

Reference information for PV watts API :
https://developer.nrel.gov/docs/solar/pvwatts/v6/
"""
api_key = "OmLmJHgTudxD6hHchGkPc30zvBTFGNf2Q2Idt8AB"
# url for obtain PV watts dataset
pv_watts_url = "https://developer.nrel.gov/api/pvwatts/v6"
# data format
# represent for the data format that you want to download
# Options : .json, .xml
data_format = ".json"

# location latitude
lat = "39.77" # type = decimal, range = (-90, 90)

# location longitude 
lon = "-84.18" # type = decimal, range = (-180, 180)

# system capacity, Nameplates capacity(kW)
system_capacity = "4" # type = decimal, range = (0.05, 500000)

# module type 
# module type for PV 
# Options : 0 for Standard. 1 for Premium. 2 for Thin film
module_type = "0" # Here step up the modu;e type is Standard

# System loss (precent)
losses = "10" # data type = decimal, range = (-5, 99)

# array_type 
array_type = "0" # data type = integer
# option:
# 0, Fixed - Open Rack
# 1, Fixed - Roof Mounted
# 2, 1 - Axis 
# 3, 1 - Axis Backtracking
# 4, 2 - Axis

# tilt angle degrees
tilt = "45" # data type = decimal, range = [0, 90]
#
# azimuth angle
azimuth = "60" # data type = decimal, range = (0,360)
# time frame 
timeframe = "hourly"
url = pv_watts_url + data_format + "?" +\
     "api_key=" + api_key + "&"\
        + "lat=" + lat + "&" \
            + "lon=" + lon + "&" \
                + "losses=" + losses + "&" \
                    + "system_capacity=" + system_capacity + "&"\
                        + "module_type=" + module_type + "&" \
                            + "array_type=" + array_type + "&" \
                                + "tilt=" + tilt + "&" \
                                    + "azimuth=" + azimuth + "&" \
                                        + "timeframe=" + timeframe

response = requests.get(url)
print(response.text)

#%%


def solar_PV_watts_API(api_key, 
    solar_api_url, 
    data_format, 
    latitude,
    longitude,
    system_capacity, 
    module_type,
    losses,
    array_type,
    tilt,
    azimuth,
    timeframe):

    """
    This is the function that obtain the dataset as .json file from PVwatts website.

    Notification:
    
    Please enter your own personal token to access the API
    Weblink for obtain API Key :
    https://developer.nrel.gov/docs/solar/nsrdb/himawari-download/

    Reference information for PV watts API :
    https://developer.nrel.gov/docs/solar/pvwatts/v6/


    Input Arguments:
    
    """

