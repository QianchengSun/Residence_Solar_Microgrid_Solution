# This is the bitcoin calculation about the payback and the net income
# This package include these goals in bitcoin
# 1. Obtain the real time bitcoin information
# 2. Calculate the real time Net income and the Pay back period


#%%
# load packages
import requests
import json

def bitcoin_income_model(unit_price, hashrate, power_consumption, n_miner, electric_cost,container_price, n_container):
    """
    Function of calculating the bitcoin income

    Arguments:

    Input : 
    unit_price: numeric (unit : USD $)
            the price of single bitcoin miner

    hashrate : numeric (unit : Th/s)
            the hashrate of single bitcoin miner
    
    power_consumption : numeric (unit : kW)
            the power consumption of single bitcoin miner
    
    n_miner : numeric 
            number of the bitcoin miner will be used in the model

    electric_cost : numeric (unit : kWh)
            the electric cost in the local area
    
    container_price : numeric (unit : USD)
            the price of shipping container for the bitcoin miner
    
    n_container : numeric
            number of the shipping container for the bitcoin miner
    

    Output: 
    net_income : numeric (unit : USD)
            the daily net income of the bitcoin minning 

    annual_income : numeric (unit : USD)
            the annual income of the bitcoin minning.

    pay_back_w_container : numeric (unit : days) 
            the payback time period for bitcoin minning with the shipping container

    pay_back_no_container : numeric (unit : days)
            the payback time period for bitcoin minning without the shipping container

    """
    # change the hashrate units from Th/s into h/s
    hashrate = hashrate * 10 ** 12
    # calculate the total price of the bitcoin miner
    total_price = n_miner * unit_price
    # calculate the mining efficiency
    efficiency = power_consumption * 10 ** 3 / hashrate
    """
    An ASIC's power consumption has about a +/- 5% margin from the manufacturer machine specs.
    """
    # lower kW bracket 
    lower_kw_bracket = power_consumption * (1 - 0.05)
    # upper kw bracket
    upper_kw_bracket = power_consumption * (1 + 0.05)
    # calculate the total power consumption of the bitcoin miner
    total_power_consumption = n_miner * power_consumption
    # the daily mining time, here assume mining the 24 hr a day
    mining_time = 60 * 60 * 24 # unit : s
    
    # obtain the realtime information about bitcoin through API
    # More information please visit:
    # https://api.minerstat.com/docs-coins/documentation

    # Minerstat is a public API, therefore, there is no need to use personal API Key

    # Base URL:
    # https://api.minerstat.com/v2/coins

    """
    Note :
    The API is limited to 12 requests per minute.
    The data refreshes every 5~10 minutes, no need to call the endpoint multiple times per minute.
    Minerstat API use HTTPS protocol for requests, return responses in JSON data format
    """
    url = "https://api.minerstat.com/v2/coins?list=BTC"
    response = requests.get(url)
    bitcoin_information = json.loads(response.text)[0]
    network_hashrate = bitcoin_information["network_hashrate"]
    mining_difficulty = bitcoin_information["difficulty"]
    bitcoin_price = bitcoin_information["price"]
    reward_block = bitcoin_information["reward_block"]
    # calculate the daily bitcoin minning
    daily_btc_mined = (reward_block * hashrate * mining_time / (mining_difficulty * 2 ** 32)) * n_miner
    # calculate the daily bitcoin income value
    daily_btc_revenue = daily_btc_mined * bitcoin_price
    # calculate the daily electric cost
    daily_electric_cost = electric_cost * power_consumption * n_miner * 24
    pool_fee = 0.02 # pool fee is around 1% ~ 4%
    bitcoin_pool_fee = pool_fee * daily_btc_revenue
    # calculate the daily net income of bitcoin mining
    net_income = daily_btc_revenue - daily_electric_cost - bitcoin_pool_fee
    # calculate the annual income of bitcoin minning
    annual_income = net_income * 365
    # if there is no container include, the pay back period 
    pay_back_no_container = total_price / net_income
    # print the payback time period
    print("The payback time period (days) without shipping container is :", pay_back_no_container)
    # if there is shipping container include, the pay back period 
    pay_back_w_container =  (total_price + container_price * n_container) / net_income
    # print the payback tim period
    print("The payback time period (days) with shipping container is :", pay_back_w_container)
    return net_income, annual_income, pay_back_w_container, pay_back_no_container
