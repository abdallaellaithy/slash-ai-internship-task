# app.py
from flask import Flask, request, jsonify
from transformers import AutoImageProcessor, DetrForObjectDetection
import torch
from PIL import Image
import io

app = Flask(__name__)

# Specify the path to your local directory
local_directory = "./objectDetection"

# Load the image processor and model from the local directory
image_processor = AutoImageProcessor.from_pretrained(local_directory)
model = DetrForObjectDetection.from_pretrained(local_directory)

@app.route('/predict', methods=['POST'])
def predict():
    # Check if an image file is uploaded
    if 'image' not in request.files:
        return jsonify({'error': 'No image found in request'})

    # Read the image file
    image_file = request.files['image']
    image_bytes = image_file.read()

    # Convert image bytes to PIL Image
    image = Image.open(io.BytesIO(image_bytes))

    inputs = image_processor(images=image, return_tensors="pt")
    outputs = model(**inputs)

    target_sizes = torch.tensor([image.size[::-1]])
    results = image_processor.post_process_object_detection(outputs, threshold=0.9, target_sizes=target_sizes)[0]

    objects = set()
    for label in results["labels"]:
        objects.add(model.config.id2label[label.item()])
    
    return jsonify({'prediction': objects})

if __name__ == '__main__':
    app.run(port=8000, debug=True)
