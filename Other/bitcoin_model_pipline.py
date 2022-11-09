# this is the pipeline of using bitcoin model
"""
Here is the pipeline for calculate the income and payback time period of the bitcoin mining model.
There are two goals for using this pipeline:

1. Obtain the real time information about bitcoin, such as, the bitcoin price, minning difficulty, etc. 

2. Calculate the Income and the Payback period for the bitcoin mining model based on the 

number of miner, bitcoin miner power consumption, shipping container fee, etc.
"""
#%% load package

import os 
import sys
bitcoin_model_path = os.path.join(__file__)
sys.path.append(bitcoin_model_path)
import bitcoin_model as bm
def main():
    net_income, annual_income, pay_back_w_container, pay_back_no_container = bm.bitcoin_income_model(unit_price= 800,
                                                                                                hashrate= 11.5,
                                                                                                power_consumption=1.127,
                                                                                                n_miner= 1,
                                                                                                electric_cost= 0,
                                                                                                container_price= 32000,
                                                                                                n_container=13)
    print("Daily net income is :", net_income)
    print("Annual net income is :", annual_income)
    print("Payback period (days) with container is :", pay_back_w_container)
    print("Payback period (days) without container is :", pay_back_no_container)

if __name__ == '__main__':
    main()
# %%
