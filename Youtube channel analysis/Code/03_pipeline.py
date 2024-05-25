import time
from time import sleep
import csv, os, json
import pandas as pd
from yt_ver4_proxy import selenium_extract_edge_proxy
import random



# Load JSON file as a list of URLs
with open('url_list_cleaned.json') as file:
    url_list = json.load(file)


for url in list(url_list['urls'].values())[1:]: # Iterate over each URL in the list
    selenium_extract_edge_proxy(url)
    print('sele runner complete')
    sleep_time = random.randint(1, 15) # Generate a random sleep time between 1 and 5 seconds
    sleep(sleep_time) # Sleep for the generated random time



exit(0) # Exit the program




