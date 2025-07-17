import requests

BASE_URL = "http://127.0.0.1:5000"

def test_get_yoga_videos_no_filter():
    """Test getting all yoga videos without any difficulty filter"""
    resp = requests.get(BASE_URL + "/api/yoga-videos")
    print("All Videos Output:", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "videos" in data
    assert isinstance(data["videos"], list)

def test_get_yoga_videos_valid_difficulty():
    """Test filtering yoga videos by a valid difficulty"""
    valid_difficulty = "beginner"  # replace with a difficulty existing in your DB
    resp = requests.get(BASE_URL + f"/api/yoga-videos?difficulty={valid_difficulty}")
    print(f"Videos filtered by difficulty='{valid_difficulty}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "videos" in data
    for video in data["videos"]:
        assert video["difficulty"].lower() == valid_difficulty.lower()

def test_get_yoga_videos_invalid_difficulty():
    """Test filtering yoga videos by an invalid/non-existing difficulty"""
    invalid_difficulty = "superhard"
    resp = requests.get(BASE_URL + f"/api/yoga-videos?difficulty={invalid_difficulty}")
    print(f"Videos filtered by invalid difficulty='{invalid_difficulty}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    # Expecting empty list because no videos of that difficulty
    assert "videos" in data
    assert len(data["videos"]) == 0

def test_get_yoga_videos_empty_difficulty_param():
    """Test passing empty difficulty parameter (should return all videos)"""
    resp = requests.get(BASE_URL + "/api/yoga-videos?difficulty=")
    print("Videos filtered by empty difficulty param:", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "videos" in data
    assert isinstance(data["videos"], list)

def test_get_yoga_videos_special_characters_in_difficulty():
    """Test passing special characters as difficulty (should return no videos)"""
    special_difficulty = "!@#$%^&*"
    resp = requests.get(BASE_URL + f"/api/yoga-videos?difficulty={special_difficulty}")
    print(f"Videos filtered by special characters difficulty='{special_difficulty}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "videos" in data
    assert len(data["videos"]) == 0
