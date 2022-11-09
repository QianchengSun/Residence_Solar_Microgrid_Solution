# Data Analytics to Find Most Cost Effective Residential / Small Commercial Buildings Energy Reduction and Solar Microgrid Options

# Abstract
A tool is developed to assess the energy effectiveness of millions of residential buildings in Ohio; using this assessment to develop priority recommendations for insulation addition and upgrades for the heating, cooling, and water heating systems. The process to develop these priority recommendations is as follows. First, historical monthly consumption data for all (gas and electric) was obtained for all Ohio residences. Next, residential building data was obtained for each house from open-source county auditor databases. These data were merged by address and combined with date synched weather data. Singular machine learning models were developed to respectively predict monthly gas and electric energy consumption for any residence with accuracy. Energy effectiveness rankings were developed for all residences for each fuel type. Next, a tool was developed to identify the most cost-effective energy characteristics to improve first. Ultimately, the tool developed has the ability to identify the most cost-effective energy reduction actions from all residences in Ohio (and elsewhere).  Never has this been done before at such a scale. Additionally, realistic real-time demand profiles were created for each residence utilizing the monthly consumption data. From these, a cost optimal solar sizing was developed for each residence. The posed solar sizing effectively maximizes behind the meter solar production relative to solar returned to the grid.  

# In this repositories include two parts
1. Residence upgrade options
2. Solar microgrid optimization

# Introduction to Solar API

This is the developed package for obtain the solar data about PV watts from https://pvwatts.nrel.gov/

Prepare:
In order to run this code you have to prepare your own API key for https://pvwatts.nrel.gov/
Please go to the following link to obtain your own API for NREL:
https://developer.nrel.gov/signup/

The following link shows the information about how to use PV watts API from NREL:
https://developer.nrel.gov/docs/solar/pvwatts/v6/

Package Tutorial:
1. Open your terminal window and type :
```
git clone https://github.com/QianchengSun/Solar_API.git
```
2. Go to the Solar_API file, fix the parameters in solar_API_pipeline.py, and save file






