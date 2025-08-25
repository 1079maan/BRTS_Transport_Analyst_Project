import pandas as pd
import re

# Load the CSV
df = pd.read_csv("brts_all_routes.csv")

# Function to remove tags like "1D", "2U", "12S" from start_stop and end_stop
def clean_stop_name(name):
    return re.sub(r'^[0-9]+[A-Z]?\s*', '', str(name))

# Clean start and end stops
df['route_name'] = df['route_name'].apply(clean_stop_name)

# Split route_name into start_stop and end_stop
df[['start_stop', 'end_stop']] = df['route_name'].str.split(' - ', expand=True)

# Save cleaned data
df.to_csv("brts_routes_cleaning.csv", index=False)

print("Cleaned routes saved to brts_routes_clean.csv")