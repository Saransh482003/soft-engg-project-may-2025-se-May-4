from flask import Flask, request, jsonify, send_from_directory
import requests

app = Flask(__name__, static_folder="static")

def find_doctors_by_specialty(lat, lon, disease_name, radius=5000):
    overpass_url = "http://overpass-api.de/api/interpreter"

    disease_specialty_map = {
        "heart": ["cardiology", "cardiologist"],
        "eye": ["ophthalmology", "eye"],
        "skin": ["dermatology", "skin"],
        "diabetes": ["endocrinology", "diabetes"],
        "bones": ["orthopedics", "orthopaedic"],
        "lungs": ["pulmonology", "chest"],
        "teeth": ["dentist", "dental"],
    }

    keywords = disease_specialty_map.get(disease_name.lower(), [disease_name.lower()])

    query = f"""
    [out:json];
    (
    node["healthcare:speciality"~"dermatology|skin"](around:{radius},{lat},{lon});
    node["speciality"~"dermatology|skin"](around:{radius},{lat},{lon});
    node["amenity"~"hospital|clinic|doctors"](around:{radius},{lat},{lon});
    );
    out center;
    """


    response = requests.get(overpass_url, params={'data': query})
    data = response.json()
    # print(data["elements"])
    matched_places = []
    for el in data["elements"]:
        tags = el.get("tags", {})
        name = tags.get("name", "Unnamed Facility")

        address_parts = [
            tags.get("addr:housenumber", ""),
            tags.get("addr:street", ""),
            tags.get("addr:city", ""),
            tags.get("addr:postcode", ""),
        ]
        full_address = ", ".join(part for part in address_parts if part)
        specialty = tags.get("healthcare:speciality", "") + tags.get("speciality", "")

        # print(keywords,name)
        if any(kw in specialty.lower() for kw in keywords) or any(kw in name.lower() for kw in keywords):
            matched_places.append({
                "name": name,
                "address": full_address or "Address not available",
                "lat": el.get("lat") or el.get("center", {}).get("lat"),
                "lon": el.get("lon") or el.get("center", {}).get("lon"),
            })
    # print(matched_places)
    return matched_places

@app.route("/")
def serve_index():
    return send_from_directory("static", "index.html")

@app.route("/nearby-hospitals", methods=["POST"])
def nearby_hospitals():
    data = request.json
    lat = data.get("latitude")
    lon = data.get("longitude")

    disease_type = "teeth"  # You can make this dynamic later
    results = find_doctors_by_specialty(lat, lon, disease_type)
    return jsonify(results)

if __name__ == "__main__":
    app.run(debug=True)
