# Solar_API

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
3. Open your terminal window and type :
```
python3 solar_API_pipeline.py
```

4. Then you will get the solar data about PV watts by your fixed parameters.


Working required packages & installiation:
1. numpy
```
pip3 install numpy
```
2. pandas
```
pip3 install pandas
```
3. requests
```
pip3 install requests
```
4. json
```
pip3 install json
```
5. os




