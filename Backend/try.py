import requests
import base64
import os
from datetime import datetime

# Create asana folder if it doesn't exist
asana_folder = "./asana"
if not os.path.exists(asana_folder):
    os.makedirs(asana_folder)
    print(f"Created folder: {asana_folder}")

response = requests.post("http://127.0.0.1:5000/api/generate-asana-images", json={
    "asana_name": "Chakra Asana",
    "limit": 4
})

if response.status_code == 200:
    data = response.json()
    print(f"API Response Status: {data.get('status', 'success')}")
    print(f"Response data: {data}")
    
    if 'images' in data and data['images']:
        images = data['images']
        asana_name = data.get('asana_name', 'Chakra Asana')
        
        # Clean asana name for filename (remove special characters)
        clean_asana_name = "".join(c for c in asana_name if c.isalnum() or c in (' ', '-', '_')).rstrip()
        clean_asana_name = clean_asana_name.replace(' ', '_').lower()
        
        print(f"Found {len(images)} images for {asana_name}")
        
        saved_files = []
        for i, image_data in enumerate(images):
            try:
                # Handle base64 encoded images (expected format from your API)
                if isinstance(image_data, str):
                    base64_data = image_data
                    
                    # Add proper base64 padding if needed
                    missing_padding = len(base64_data) % 4
                    if missing_padding:
                        base64_data += '=' * (4 - missing_padding)
                    
                    # Decode base64 data
                    image_bytes = base64.b64decode(base64_data)
                    
                    # Generate filename with timestamp
                    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                    filename = f"{clean_asana_name}_{i+1}_{timestamp}.png"
                    filepath = os.path.join(asana_folder, filename)
                    
                    # Save image file
                    with open(filepath, 'wb') as f:
                        f.write(image_bytes)
                    
                    saved_files.append(filepath)
                    print(f"✅ Saved image {i+1}: {filepath}")
                
                # Handle dictionary format (if it contains base64 or URL)
                elif isinstance(image_data, dict):
                    # Look for base64 data in various possible fields
                    base64_data = None
                    for key in ['image_data', 'base64', 'data', 'image', 'content', 'base64_image']:
                        if key in image_data and image_data[key]:
                            base64_data = image_data[key]
                            break
                    
                    # Look for image URL
                    image_url = image_data.get('image_url') or image_data.get('url')
                    
                    if base64_data:
                        # Remove data:image prefix if present
                        if base64_data.startswith('data:image/'):
                            base64_data = base64_data.split(',', 1)[1]
                        
                        # Add proper base64 padding if needed
                        missing_padding = len(base64_data) % 4
                        if missing_padding:
                            base64_data += '=' * (4 - missing_padding)
                        
                        # Decode base64 data
                        image_bytes = base64.b64decode(base64_data)
                        
                        # Generate filename with timestamp
                        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                        filename = f"{clean_asana_name}_{i+1}_{timestamp}.png"
                        filepath = os.path.join(asana_folder, filename)
                        
                        # Save image file
                        with open(filepath, 'wb') as f:
                            f.write(image_bytes)
                        
                        saved_files.append(filepath)
                        print(f"✅ Saved image {i+1}: {filepath}")
                    
                    elif image_url:
                        print(f"Downloading image {i+1} from: {image_url}")
                        
                        # Download the image
                        img_response = requests.get(image_url, timeout=30)
                        if img_response.status_code == 200:
                            # Generate filename with timestamp
                            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                            filename = f"{clean_asana_name}_{i+1}_{timestamp}.png"
                            filepath = os.path.join(asana_folder, filename)
                            
                            # Save image file
                            with open(filepath, 'wb') as f:
                                f.write(img_response.content)
                            
                            saved_files.append(filepath)
                            print(f"✅ Saved image {i+1}: {filepath}")
                        else:
                            print(f"❌ Failed to download image {i+1}: HTTP {img_response.status_code}")
                    
                    else:
                        print(f"Image {i+1}: No base64 data or image_url found in: {list(image_data.keys())}")
                
                else:
                    print(f"Image {i+1}: Unexpected data format: {type(image_data)}")
                    continue
                
            except Exception as e:
                print(f"❌ Error saving image {i+1}: {str(e)}")
                # Print more details for debugging
                print(f"   Image data type: {type(image_data)}")
                if isinstance(image_data, str):
                    print(f"   String length: {len(image_data)}")
                    print(f"   First 50 chars: {image_data[:50]}")
                elif isinstance(image_data, dict):
                    print(f"   Dict keys: {list(image_data.keys())}")
                continue
        
        print(f"\n📁 Successfully saved {len(saved_files)} images to {asana_folder}/")
        for file in saved_files:
            print(f"   - {file}")
            
    else:
        print("No 'images' field found in response or images list is empty")
        print("Full response data:", data)
        
else:
    print(f"API request failed with status code: {response.status_code}")
    print("Response:", response.text)

