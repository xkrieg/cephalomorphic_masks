# -*- coding: utf-8 -*-

#Import libraries
from bs4 import BeautifulSoup
from urllib.request import urlretrieve
from selenium import webdriver
from nltk import word_tokenize
from tqdm import tqdm
import pandas as pd
import os

#Login to Artkhade
def login(driver):
    
    #Login to ArtKhade
    driver.get("https://www.artkhade.com/en/user/login")
    soup_level1=BeautifulSoup(driver.page_source, 'lxml')
    
    #Enter credentials
    username = driver.find_element_by_name('username')
    password = driver.find_element_by_name('password')
    username.send_keys("xkrieg@gmail.com")
    password.send_keys("xand3223")
    
    xpath = "//input[@class='btn btn-primary medium'][@type='submit']"
    elem = driver.find_element_by_xpath(xpath).click()
    
    return(driver)

#Get urls of object pages from one search result page
def get_object_pages(driver, url, filter_by = "/object/"):

    #Open page
    driver.get(url)

    #Get list of links
    object_links = driver.find_elements_by_xpath("//a[@href]")
    object_links = [link.get_attribute("href") for link in object_links]
    object_links = [link for link in object_links if filter_by in link]
    object_links = list(dict.fromkeys(object_links))
    
    return(driver, object_links)

#Downloads mask image and returns id (filename)
def download_image(driver):

    images = driver.find_elements_by_tag_name('img')
    mask_image = [image.get_attribute('src') for image in images if "/420/" in image.get_attribute('src')][0]
        
    filename = "/".join(["images", mask_image.split("/")[7]])
    urlretrieve(mask_image, filename)
    
    return filename

#Collects data from object page
def get_mask_data(driver, url, index, page):

    #Set up dictionary
    mask_info = dict.fromkeys(["Region", "Culture", "Period", "Categories", 
                               "Features", "Materials", "Size"], "NA")
    mask_keys = list(mask_info.keys())

    #Set retrieval information
    mask_info['Search URL'] = url
    mask_info['Page Index'] = index
    mask_info['Page URL'] = page

    #Get mask image
    mask_info['Image'] = download_image(driver)

    #Get page text
    soup = BeautifulSoup(driver.page_source, 'lxml')
    text = soup.get_text()
    text = word_tokenize(text)

    #Text mine information
    for key in mask_keys: #Except ID
        #Note: get text from after ": " to the newline marker startswith('€')
        try:
            mask_info[key] = text[text.index(key)+1]
        except:
            break

    #Add sales price
    # if any(item.startswith('€') for item in text):
    #     mask_info['Price'] = [item for item in text if item.startswith('€')][0]

    return(mask_info)

#Upon executon
if __name__ == '__main__':

    #Initiate & login
    driver = webdriver.Chrome(executable_path=os.popen('which chromedriver').read().strip())
    driver = login(driver)
    data_list = []

    #Navigate through search pages and get results
    base_url = 'https://www.artkhade.com/en/search/cephalomorphic?l=+&q=feature-423+objecttype-736&ob=latest_sale_date&l='
    count = 0
    for i in tqdm(range(1350,10000,50)):
        url = "".join([base_url, str(i), "+50"])
        driver, pages = get_object_pages(driver, url)

        for j, page in enumerate(pages):
            try:
                driver.get(page)
                data = get_mask_data(driver, url, j, page)
                data_list.append(data)
    
                dataset = pd.DataFrame(data_list)
                dataset.to_csv("data/data.csv")
            except Exception as e:
                pass

    print(dataset)
