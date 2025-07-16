### Test_review (3.7.25)

1. Sending a POST request to `/api/nearby_places` with a radius (e.g., 5000) and without a radius results in different outputs. Default radius should have given the same output.
2. Negative latitude and longitude values return a `200 OK` response with no places, instead of validating and rejecting the input.
3. A POST request to `/api/place_details` returns a `500 Internal Server Error` for a valid place ID.  
   **Fix:** In `Backend/modules/nearby_places.py` at line 31,  
   Replace:
   ```python
   return response.json()["result"]
   ```
   into
   ```python
     return response.json()
   ```
5. SQLAlchemy APIs remain untested. The database appears either uninitialized or defined in multiple places, leading to inconsistency.
