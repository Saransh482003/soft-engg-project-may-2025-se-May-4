import os
from dotenv import load_dotenv
import requests
import json
from groq import Groq
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

load_dotenv()

class WebsiteScraper:
    def __init__(self, api_key=None):
        self.api_key = api_key
        self.client = Groq(api_key=self.api_key)

    def get_rendered_html(self, url):
        chrome_options = Options()
        chrome_options.add_argument("--headless=chrome")  # 🔥 This hides the browser
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument(
            "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
            (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
        )
        # Optional: suppress logs
        chrome_options.add_argument("--log-level=3")

        # Create driver
        driver = webdriver.Chrome(options=chrome_options)

        try:
            driver.get(url)

            # Optional: Wait for specific element (e.g. body or some known class)
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )

            html = driver.page_source
            return html
        finally:
            driver.quit()

    def find_doctor_page_links(self, homepage_url, doctor_type):
        response = requests.get(homepage_url)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        links = soup.find_all('a', href=True)
        doctor_pages = []

        for link in links:
            text = link.text.lower()
            href = link['href']
            if any(kw in text for kw in ['about-us','doctor', 'our doctors', doctor_type, 'specialist', 'department', 'our team']):
                full_url = href if href.startswith('http') else homepage_url.rstrip('/') + '/' + href.lstrip('/')
                doctor_pages.append(full_url)
    
        return doctor_pages

    def fetch_doctor_information(self, url, doctor_type):
        html = self.get_rendered_html(url)
        with open("try.html", "w", encoding="utf-8") as file:
            file.write(html)
        # print(html)
        soup = BeautifulSoup(html, 'html.parser')
        body_text = soup.find("body")
        # print(body_text)
        body_text = body_text.get_text(separator='\n', strip=True)

        prompt = f"""
        You are a medical website data extraction agent.

        From the following unstructured HTML text, extract structured doctor information. 
        Only include doctors related to "{doctor_type}". Each doctor should have:
        {{
            "Name": "Dr. John Doe",
            "Designation": "Senior Gynecologist",
            "Specialization": "Gynecology",
            "Contact": "john.doe@domain",
        }}

        Your response should be a just JSON array of objects, each representing a doctor. No other text should be included.
        if no doctors are found, return an empty 
        Text:
        '''{body_text[:6000]}'''  # limit to 6000 chars for token safety
        """

        chat_completion = self.client.chat.completions.create(
            messages=[
                {

                "role": "system",
                "content": "You are an expert HTML medical page scraper. Extract structured doctor information from the provided text."
                },
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            model="llama-3.3-70b-versatile",
        )
        try:
            response = chat_completion.choices[0].message.content
            return response
        except Exception as e:
            return f"Error: {str(e)}"