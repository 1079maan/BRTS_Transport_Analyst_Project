import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select

# Load routes from CSV
routes_df = pd.read_csv("Book1.csv")
routes = routes_df['route_name'].dropna().tolist()

# Setup Selenium
driver = webdriver.Chrome()
driver.get("https://www.ahmedabadbrts.org/time-table/")
driver.maximize_window()
time.sleep(5)  # Wait for page to load
print("Page loaded successfully.")
all_stops = []

for route in routes:
    try:
        # Select route from dropdown
        WebDriverWait(driver, 50).until(
            EC.visibility_of_any_elements_located((By.XPATH, '//input[@id="inputPassword"]'))
        )
        print("Dropdown found successfully.")
        driver.find_element(By.XPATH,'//input[@id="inputPassword"]').send_keys(route)

        # Click Go button
        driver.find_element(By.XPATH, "//button[text()='GO']").click()
        
        # Click first trip (Trip 0)
        time.sleep(10)
        # WebDriverWait(driver, 60).until(
        #     EC.visibility_of_element_located((By.XPATH, '//div[@class="bus-tabbox"]'))
        # )
        
        first_trip = driver.find_element(By.XPATH, '//h4[text()=" Trip No: 0"]')
        first_trip.click()

        WebDriverWait(driver, 30).until(
            EC.visibility_of_all_elements_located((By.XPATH, '//div[@id="dvMap"]'))
        )
        
        # Extract stops
        WebDriverWait(driver, 30).until(
            EC.visibility_of_all_elements_located((By.XPATH, '//strong[@class="ng-binding"]'))
        )
        
        stops = driver.find_elements(By.XPATH, '//strong[@class="ng-binding"]')
        print(f"Stops found successfully. {stops}")

        for idx, stop in enumerate(stops, start=1):
            all_stops.append([route, idx, stop.text.strip()])
        print("Extracted stops for route")
        driver.refresh()  # Refresh page for next route
        time.sleep(2)
        # print(f"Successfully scraped route: {route}")
        
    except Exception as e:
        print("Error scraping route")

# Save to CSV
stops_df = pd.DataFrame(all_stops, columns=["route_name", "stop_sequence", "stop_name"])
stops_df.to_csv("BRTS_first_stops.csv", index=False)

driver.quit()
print("Scraping completed. File saved: BRTS_stops.csv")
