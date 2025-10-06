from flask import Flask, request, jsonify
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)

# Load the trained model and encoders
model = joblib.load('model/crop_model_v2.joblib')
soil_encoder = joblib.load('model/soil_encoder.joblib')
crop_encoder = joblib.load('model/crop_encoder.joblib')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    try:
        # Prepare the input for the model
        # Note: The feature names must match the new dataset columns
        temp = data['Temparature']
        humidity = data['Humidity']
        moisture = data['Moisture']
        soil_type_str = data['Soil Type']
        nitrogen = data['Nitrogen']
        potassium = data['Potassium']
        phosphorous = data['Phosphorous']

        # Use the soil encoder to transform the string 'Soil Type' into a number
        soil_type_encoded = soil_encoder.transform(np.array([soil_type_str]))[0]

        # Create a DataFrame in the correct order for the model
        input_data = pd.DataFrame([[temp, humidity, moisture, soil_type_encoded, nitrogen, potassium, phosphorous]], 
                                  columns=['Temparature', 'Humidity', 'Moisture', 'Soil Type', 'Nitrogen', 'Potassium', 'Phosphorous'])

        # Make a prediction
        prediction_encoded = model.predict(input_data)

        # Use the crop encoder to transform the numeric prediction back into a crop name
        prediction_str = crop_encoder.inverse_transform(prediction_encoded)[0]

        # Return the result
        return jsonify({'recommended_crop': prediction_str})

    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    # This is for local testing
    app.run(debug=True, host='0.0.0.0')