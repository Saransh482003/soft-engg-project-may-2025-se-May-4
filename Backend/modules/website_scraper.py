import os
from dotenv import load_dotenv
import requests
import json
from bs4 import BeautifulSoup

load_dotenv()

class WebsiteScraper:
    def __init__(self, api_key=None):
        self.api_key = api_key


    def find_doctor_page_links(self, homepage_url):
        response = requests.get(homepage_url)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        links = soup.find_all('a', href=True)
        doctor_pages = []

        for link in links:
            text = link.text.lower()
            href = link['href']
            if any(kw in text for kw in ['doctor', 'gyne', 'obstetrician', 'specialist', 'department', 'our team']):
                full_url = href if href.startswith('http') else homepage_url.rstrip('/') + '/' + href.lstrip('/')
                doctor_pages.append(full_url)

        return doctor_pages