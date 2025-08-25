import pandas as pd

# Load CSV
df = pd.read_csv("BRTS_route - Copy.csv")

# Function to normalize route name
def normalize_route(route):
    stops = route.split(" - ")
    return " - ".join(sorted(stops))

# Apply normalization
df["normalized_route"] = df["route_name"].apply(normalize_route)

# Drop duplicates based on normalized route
df_cleaned = df.drop_duplicates(subset=["normalized_route"]).drop(columns=["normalized_route"])

# Save cleaned CSV
df_cleaned.to_csv("BRTS_route_cleaned.csv", index=False)

print("cleaned file saved as BRTS_route_cleaned.csv")
