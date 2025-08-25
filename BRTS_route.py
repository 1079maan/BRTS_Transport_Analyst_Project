import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Chrome()  
driver.get("https://www.ahmedabadbrts.org/time-table/")
driver.maximize_window()
time.sleep(3)

data = []

try:
    # table = driver.find_element(By.XPATH, "//div[@id='style-4']")
    # rows = table.find_elements(By.XPATH, "//div[@class='tab-heading']")
    # print("Table found successfully.")
    
    # for row in rows[1:]: 
    #     cols = row.find_elements(By.TAG_NAME, "div")
    #     if len(cols) >= 1:
    #         route_name = cols[0].text.strip()
    #         print(f"Extracted route: {route_name}")
    #         # Extracting route name
    #         data.append([route_name])
        
    # driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    # print("Scrolled to the bottom of the page.")
    
    # # page 2
    # WebDriverWait(driver, 30).until(
    #         EC.element_to_be_clickable((By.XPATH, '//a[text()="2"]'))).click()
    # # page_2 = driver.find_element(By.XPATH, '//a[text()="2"]')
    # # page_2.click()
    # print("Clicked on page 2 successfully.")
    
    # WebDriverWait(driver, 30).until(
    #     EC.presence_of_all_elements_located((By.XPATH, "//div[@id='style-4']//div[@class='tab-heading']")))
    # print("Waiting for page 2 to load...")
    
    # # driver.execute_script("window.scrollTo(0, 0);")

    # rows_2 = driver.find_elements(By.XPATH, "//div[@id='style-4']//div[@class='tab-heading']")
    # print(f"Found {len(rows_2)} rows on page 2.")
    
    # data_page2 = []
    # for row in rows_2[1:]:
    #     cols2 = row.find_elements(By.TAG_NAME, "div")
    #     if len(cols2) >= 1:
    #         route_name2 = cols2[0].text.strip()
    #         print(f"Extracted route (page 2): {route_name2}")
    #         data_page2.append([route_name2])

    # data.extend(data_page2)
    # print("Data extracted successfully.")

    
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    pages = driver.find_elements(By.XPATH, "//ul[@class='pagination']//a")
    page_numbers = [p.text.strip() for p in pages if p.text.strip().isdigit()]
    total_pages = int(page_numbers[-1])    
    print(f"Total pages found: {total_pages}")
    
    for page in range(1, total_pages+1):
        print(f"\n Extracting page {page}")

        # Wait for rows
        WebDriverWait(driver, 30).until(
            EC.presence_of_all_elements_located((By.XPATH, "//div[@id='style-4']//div[@class='tab-heading']"))
        )
        rows = driver.find_elements(By.XPATH, "//div[@id='style-4']//div[@class='tab-heading']")

        # Extract routes
        for row in rows[1:]:
            cols = row.find_elements(By.TAG_NAME, "div")
            if len(cols) >= 1:
                route_name = cols[0].text.strip()
                print(f"Extracted route: {route_name}")
                data.append([route_name])

        # If not last page, click next
        if page < total_pages:
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            next_button = WebDriverWait(driver, 30).until(
                EC.element_to_be_clickable((By.XPATH, f"//a[text()='{page+1}']"))
            )
            next_button.click()
            time.sleep(3)

except Exception as e:
    print("Error finding the routes table:", e)
    
finally:
    driver.quit()
    
print(f"Number of routes found: {len(data)}")

# Save to CSV
df = pd.DataFrame(data, columns=["route_name"])
csv_file = "brts_all_routes.csv"
df.to_csv(csv_file, index=False, encoding="utf-8")
print(f"CSV file saved as: {csv_file}")
print("Scraping completed. File saved: brts_all_routes.csv")