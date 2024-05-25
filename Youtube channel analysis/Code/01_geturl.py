from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import json



service = Service(executable_path="chromedriver.exe")
driver = webdriver.Chrome(service=service)

#input your website here
driver.get("https://www.youtube.com/watch?v=1ZLrscUIoo8&list=UULFmsX3gl3KZVf4KtjsjtJIDQ&index=625&pp=iAQB")
time.sleep(20)


# click the no thanks button
driver.find_element(By.XPATH, '//*[@id="dismiss-button"]').click()
time.sleep(5)


# click the description section to expand it
# driver.find_element(By.ID, 'description-inline-expander').click()




video_url = []
video_url.append(driver.find_element(By.XPATH, '//*[@id="wc-endpoint"]').get_attribute('href'))
video_url.extend([element.get_attribute('href') for element in driver.find_elements(By.XPATH, '//*[@id="thumbnail"]')])



# Save the data into a json file
with open("url_list.json", "a" ,encoding="utf-8") as file:
    json.dump(video_url, file, indent=4)



time.sleep(3)
driver.quit()