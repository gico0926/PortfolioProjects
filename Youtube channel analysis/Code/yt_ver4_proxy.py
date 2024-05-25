def selenium_extract_edge_proxy(url):

    from selenium import webdriver
    from selenium.webdriver.edge.service import Service
    from selenium.webdriver.edge.options import Options
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    import time
    import json, os
    import pandas as pd
    import random



    # enable the headless mode
    options = Options()
    # options.add_argument('--headless=new')
    options.add_argument("--enable-chrome-browser-cloud-management")


    # # enable proxy server
    # options.add_argument("--proxy-server=http://geo.iproyal.com:11200")
    

    # # prevent been detected by the website
    # options.add_experimental_option("excludeSwitches", ["enable-automation"])
    # options.add_experimental_option('useAutomationExtension', False)
    # options.add_argument('--disable-blink-features=AutomationControlled')



    service = Service(executable_path="msedgedriver.exe")
    driver = webdriver.Edge(service=service, options=options)

    #input your website here
    driver.get(url)
    time.sleep(24)



    # wait
    WebDriverWait(driver, 4).until(
            EC.visibility_of_element_located((By.XPATH, '//*[@id="dismiss-button"]'))
    )
    # click the no thanks button
    driver.find_element(By.XPATH, '//*[@id="dismiss-button"]').click()


    # time.sleep(2)
    sleep_time = random.randint(5, 15)
    time.sleep(sleep_time)


    # wait
    WebDriverWait(driver, 4).until(
            EC.visibility_of_element_located((By.XPATH, '//*[@id="expand"]'))
    )
    # click the description section to expand it
    driver.find_element(By.XPATH, '//*[@id="expand"]').click()



    # initialize the dictionary that will contain
    # the data scraped from the YouTube page
    video = {}

    # scraping logic
    title = driver \
        .find_element(By.XPATH, '//*[@id="title"]/h1/yt-formatted-string') \
        .text

    print(title)


    # dictionary where to store the channel info
    channel = {}

    # scrape the channel info attributes
    channel_element = driver \
        .find_element(By.XPATH, '//*[@id="owner"]')

    channel_url = channel_element \
                .find_element(By.XPATH, '//*[@id="text"]/a') \
                .get_attribute('href')
    channel_name = channel_element \
                .find_element(By.XPATH, '//*[@id="text"]/a') \
                .text
    channel_subs = channel_element \
                .find_element(By.XPATH, '//*[@id="owner-sub-count"]') \
                .text.replace('位訂閱者', '')

    channel['url'] = channel_url
    channel['name'] = channel_name
    channel['subs'] = channel_subs


    views = driver.find_elements(By.XPATH, '//*[@id="info"]/span[1]')[0].text.strip('觀看次數：').replace('次', '')
    publication_date = driver.find_elements(By.XPATH, '//*[@id="info"]/span[3]')[0].text


    likes = driver \
        .find_element(By.XPATH, '//*[@id="top-level-buttons-computed"]/segmented-like-dislike-button-view-model/yt-smartimation/div/div/like-button-view-model/toggle-button-view-model/button-view-model/button/div[2]') \
        .text

    videourl = driver.find_elements(By.XPATH, '//*[@id="wc-endpoint"]')[0].get_attribute('href')

    video['videourl'] = videourl
    video['title'] = title
    video['channel'] = channel
    video['views'] = views
    video['publication_date'] = publication_date
    video['likes'] = likes


    df = pd.DataFrame(
        {
            'channel_name': [video['channel']['name']],
            'channel_subs': [video['channel']['subs']],
            'video_title': [video['title']],
            'publication_date': [video['publication_date']],
            'views': [video['views']],
            'likes': [video['likes']],
            'channel_url': [video['channel']['url']],
            'video_url': [video['videourl']]
        }
    )



    if not os.path.isfile(r'D:\專案\Projects\Youtube channel analysis\gj888ytdata.csv'):
        df.to_csv(r'D:\專案\Projects\Youtube channel analysis\gj888ytdata.csv', header='column_names', encoding='utf-8')
    else:
        df.to_csv(r'D:\專案\Projects\Youtube channel analysis\gj888ytdata.csv', mode='a', header=False, encoding='utf-8')

    sleep_time2 = random.randint(3, 8)
    time.sleep(sleep_time2)
    driver.quit()

