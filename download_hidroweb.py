# coding=utf-8

import csv
from selenium import webdriver;
import selenium
import os
import time
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException


profile = webdriver.firefox.firefox_profile.FirefoxProfile()
profile.set_preference('browser.helperApps.neverAsk.saveToDisk','application/zip,application/x-zip-compressed')

driver = webdriver.Firefox(firefox_profile=profile)
#driver.get("http://hidroweb.ana.gov.br/Estacao.asp?Codigo=36580000")

with open('/home/delgado/SESAM/sesam_data/DFG_Erkenntnis_Transfer/Data/hydrometeo/discharge/stations.csv','r') as f:
    reader=csv.DictReader(f,delimiter=',')
    for row in reader:
        if os.path.isfile("/home/delgado/Downloads/VAZOES.ZIP"):
            os.remove("/home/delgado/Downloads/VAZOES.ZIP")
        driver.get("http://hidroweb.ana.gov.br/Estacao.asp?Codigo=" + row['Código'])
        try:
            driver.find_element_by_xpath("//select[@name='cboTipoReg']/option[@value='9']").click()
        except:
            print "Could not find element by xpath for" + row['Código']
            continue
        driver.execute_script("criarArq("+row['Código']+",1)")
        time.sleep(3)
        try:
            driver.find_element_by_link_text('Clique aqui').click()      
        except NoSuchElementException:
            print "After 3 seconds nothing found"
            continue
        while True:
            if os.path.isfile("/home/delgado/Downloads/VAZOES.ZIP"):
                time.sleep(5)
                os.rename("/home/delgado/Downloads/VAZOES.ZIP","/home/delgado/Downloads/Q"+row['Código']+".zip")     
                break