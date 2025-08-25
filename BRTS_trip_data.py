import time
import random
import re
import pandas as pd
from datetime import datetime, timedelta
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Load all routes
routes_df = pd.read_csv("Final_brts_routes.csv")  # must have route_id, route_name

# Start Selenium Chrome
driver = webdriver.Chrome()
driver.maximize_window()
time.sleep(2)

all_trips = []

for idx, row in routes_df.iterrows():
    route_id = row["route_id"]
    route_name = row["route_name"]

    try:
        driver.get("https://www.ahmedabadbrts.org/time-table/")
        # WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.ID, "route")))
        WebDriverWait(driver, 50).until(
            EC.visibility_of_any_elements_located((By.XPATH, '//input[@id="inputPassword"]'))
        )
        print("Page loaded successfully.")
        options = driver.find_element(By.XPATH,'//input[@id="inputPassword"]')
        options.send_keys(route_name)
        print(f"Selecting route: {route_name}")
    
        # Click search
        driver.find_element(By.XPATH, "//button[text()='GO']").click()
        time.sleep(2)
        print("Clicked GO button.")
        
        # Get all trips, but limit to max 5
        time.sleep(10)
        trips = driver.find_elements(By.XPATH, '//div[@class="col-xs-4"]')
        max_trips = 10
        trips = trips[:max_trips]  # <= restrict to first 5 trips
        print(f"Found {len(trips)} trips for route: {route_name}")
        
        all_times = []
        for trip in trips:
            cols = trip.find_elements(By.TAG_NAME, 'h5')
            texts = [c.text.strip() for c in cols if c.text.strip() != ""]
            clean_texts = [re.sub(r"[^\d:]", "", t) for t in texts]
            if clean_texts:
                clean_textss = [t.lstrip(": ").strip() for t in clean_texts]
                all_times.extend(clean_textss)
                
        print("ALL TIMES:", all_times)
        for i in range(0, len(all_times), 2):    
            if i+1 < len(all_times): 
                sched_departure = all_times[i]
                sched_arrival   = all_times[i+1]
                print(f"Trip {i//2+1} → Departure: {sched_departure}, Arrival: {sched_arrival}")

                # Attach random date (last 7 days)
                random_date = datetime.now() - timedelta(days=random.randint(0, 7))
                print(f"Random Date: {random_date.strftime('%Y-%m-%d')}")
                
                # Parse using 24-hour format HH:MM:SS
                time_obj_depart  = datetime.strptime(sched_departure, "%H:%M:%S")
                sched_departure_dt = datetime.combine(random_date.date(), time_obj_depart.time())
                # .replace(
                #     year=random_date.year, month=random_date.month, day=random_date.day
                # )
                time_obj_arrival = datetime.strptime(sched_arrival, "%H:%M:%S")
                sched_arrival_dt = datetime.combine(random_date.date(), time_obj_arrival.time())
                # sched_arrival_dt = datetime.strptime(sched_arrival, "%H:%M:%S").replace(
                #     year=random_date.year, month=random_date.month, day=random_date.day
                # )
                print(f"Scheduled Departure: {sched_departure_dt}, Scheduled Arrival: {sched_arrival_dt}")
                
                # Add random delay (1–10 minutes)
                delay_minutes = random.randint(1, 10)
                delay_sec = delay_minutes * 60

                actual_departure_dt = sched_departure_dt + timedelta(minutes=delay_minutes)
                actual_arrival_dt = sched_arrival_dt + timedelta(minutes=delay_minutes)
                print(f"Actual Departure: {actual_departure_dt}, Actual Arrival: {actual_arrival_dt}")
                
                # Random weather
                weather = random.choice(["Clear", "Cloudy", "Rain", "Fog"])
                print(f"Weather Condition: {weather}")
                
                # Append trip data
                all_trips.append([
                    # f"{route_id}-{i}",  # trip_id
                    route_id,
                    sched_departure_dt,
                    sched_arrival_dt,
                    actual_departure_dt,
                    actual_arrival_dt,
                    delay_sec,
                    weather
                ])
                print(f"Added trip {i} for route {route_name}")


    except Exception as e:
        print(f"Error scraping route {route_name}: {e}")
        continue

driver.quit()

# Save results
df = pd.DataFrame(all_trips, columns=[
    "route_id", "scheduled_departure", "scheduled_arrival",
    "actual_departure", "actual_arrival", "delay_sec", "weather_condition"
])


df.to_csv("trip_data.csv", index=False)
print("Trip data saved to trip_data.csv")
