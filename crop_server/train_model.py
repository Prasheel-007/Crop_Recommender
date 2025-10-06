import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
import joblib

print("--- Starting Enhanced Model Training ---")

# Load the new dataset
df = pd.read_csv('data_core.csv')
print("Dataset 'data_core.csv' loaded successfully.")

# Drop the 'Fertilizer Name' as we are predicting the crop
df = df.drop('Fertilizer Name', axis=1)

# Convert categorical features (Soil Type, Crop Type) into numbers
soil_encoder = LabelEncoder()
crop_encoder = LabelEncoder()

df['Soil Type'] = soil_encoder.fit_transform(df['Soil Type'])
df['Crop Type'] = crop_encoder.fit_transform(df['Crop Type'])

# Define the features (inputs) and the target (output)
# Note the new features: Moisture and Soil Type
X = df[['Temparature', 'Humidity', 'Moisture', 'Soil Type', 'Nitrogen', 'Potassium', 'Phosphorous']]
y = df['Crop Type']

# Split the data for training and testing
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
print("Data split into training and testing sets.")

# Create and train the Random Forest model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)
print("Model training complete.")

# Check and print the model's accuracy
accuracy = model.score(X_test, y_test)
print(f"Model Accuracy: {accuracy * 100:.2f}%")

# Save the trained model and the encoders
joblib.dump(model, 'crop_model_v2.joblib')
joblib.dump(soil_encoder, 'soil_encoder.joblib')
joblib.dump(crop_encoder, 'crop_encoder.joblib')

print("Model and encoders saved successfully.")
print("--- Model Training Finished ---")