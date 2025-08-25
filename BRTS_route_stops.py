import pandas as pd

# ----- 1) Load files -----
final_stops = pd.read_csv("Final_brts_stops.csv")   # stop_id, stop_name
brts_stops  = pd.read_csv("BRTS_stops.csv")        # route_name, stop_name, stop_sequence

# Make sure stop_sequence is numeric
brts_stops["stop_sequence"] = pd.to_numeric(brts_stops["stop_sequence"], errors="coerce")

# ----- 2) Assign route_id dynamically -----
brts_stops["route_id"] = (brts_stops["stop_sequence"] == 1).cumsum()

# Ensure route_id starts from 1
if brts_stops["route_id"].min() == 0:
    brts_stops["route_id"] = brts_stops["route_id"] + 1

print("Route IDs assigned.")
print(brts_stops.head(5))

# Save to CSV
brts_stops.to_csv("Final_BRTS_route_stops.csv", index=False, encoding="utf-8")
print("BRTS_route_stops.csv saved successfully!")

