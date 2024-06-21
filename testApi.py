import requests
from PIL import Image
import io

# Load the image
image_path = "pizza.jpg"
image = Image.open(image_path)

# Convert the image to binary data
image_bytes = io.BytesIO()
image.save(image_bytes, format='JPEG')
image_bytes = image_bytes.getvalue()

# Define the URL of the API endpoint
url = 'http://localhost:8000/predict'

# Send a POST request to the API endpoint with the image data
response = requests.post(url, files={'image': image_bytes})

# Check if the request was successful
if response.status_code == 200:
    # Get the prediction from the response
    prediction = response.json()['prediction']
    print("Predicted labels:", prediction)
else:
    print("Error:", response.text)
