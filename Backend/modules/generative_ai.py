import google.generativeai as genai
import base64
from flask import jsonify


class GenerativeAI:
    def __init__(self, api_key):
        self.api_key = api_key

    def generate_asana_images(self, asana_name, limit):
        try:
            # Prompt for sequential stages
            prompt = (
                f"Generate {limit} sequential step-by-step images showing the correct progression "
                f"into the yoga pose '{asana_name}'. Each image should be a clear, realistic photo-style "
                f"depiction of a person performing the pose, starting from the initial stance and ending "
                f"in the full asana. White background, consistent style."
            )

            # Request all images in one API call
            response = genai.generate_images(
                model="gemini-2.0-flash",
                prompt=prompt,
                number_of_images=limit  # Ask Gemini to give the specified number of images at once
            )

            # Convert binary images to base64
            images_base64 = [
                base64.b64encode(img).decode("utf-8")
                for img in response.images
            ]

            return jsonify({"images": images_base64})
        
        except Exception as e:
            return jsonify({"error": str(e)}), 500
