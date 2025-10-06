import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
import joblib

print("--- Starting Model Training ---")

# Load the dataset from the CSV file
df = pd.read_csv('Crop_recommendation.csv')
print("Dataset loaded successfully.")

# Define the features (inputs) and the target (output)
X = df[['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']]
y = df['label']

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

# Save the trained model to a file
joblib.dump(model, 'crop_model.joblib')
print("Model saved to 'crop_model.joblib'")
print("--- Model Training Finished ---")