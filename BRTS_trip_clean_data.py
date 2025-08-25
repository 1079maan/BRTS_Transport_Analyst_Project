import pandas as pd

# 1. Load your CSV
df = pd.read_csv("trip_data.csv")

# 2. Normalize column names (remove spaces, lowercase)
df.columns = df.columns.str.strip().str.lower()

# 3. Auto-detect datetime-like columns (those containing 'departure' or 'arrival')
datetime_cols = [col for col in df.columns if "departure" in col or "arrival" in col]

print("Detected datetime columns:", datetime_cols)

# 4. Convert to datetime and extract only time (HH:MM:SS)
for col in datetime_cols:
    df[col] = pd.to_datetime(df[col], errors="coerce").dt.strftime("%H:%M:%S")

# 5. Preview result
print("\nPreview after removing dates:\n")
print(df.head())

# 6. Save to new CSV
df.to_csv("trip_data_time_only.csv", index=False)

print("\nTime-only CSV saved as trip_data_time_only.csv")
