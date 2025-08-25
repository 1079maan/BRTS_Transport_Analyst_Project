from geopy.geocoders import Nominatim
import pandas as pd
import time

df = pd.read_csv("BRTS_stops.csv")

geolocator = Nominatim(user_agent='BRST_Project')

latitudes = []
longitudes = []

for stop in df['stop_name']:
    try:
        location = geolocator.geocode(f"{stop}, Ahmedabad, India")
        if location:
            latitudes.append(location.latitude)
            longitudes.append(location.longitude)
            print(f"{stop} → {location.latitude}, {location.longitude}")
        else:
            latitudes.append(None)
            longitudes.append(None)       
    except:
        latitudes.append(None)
        longitudes.append(None)
    
    time.sleep(1)

df['latitude'] = latitudes
df['longitude'] = longitudes

df.to_csv("BRTS_stop_data_Transformation.csv", index=False, encoding="utf-8")
print("file saved : BRTS_stop_data_Transformation.csv")

