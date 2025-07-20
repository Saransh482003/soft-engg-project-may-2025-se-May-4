from modules.website_scraper import WebsiteScraper
web = WebsiteScraper(api_key="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")
doctor_info = web.fetchDoctorInfomation(url="https://iswarya.com/doctors/", doctor_type="radiology")
print(doctor_info)