$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$env:PYTHONPATH="Backend"

pytest --html=Tests/Reports/report_auth.html --self-contained-html Tests/test_auth.py
pytest --html=Tests/Reports/function_routes.html --self-contained-html Tests/test_function_routes.py
pytest --html=Tests/Reports/routes_analytics.html --self-contained-html Tests/test_routes_analytics.py
pytest --html=Tests/Reports/routes_content.html --self-contained-html Tests/test_routes_content.py
pytest --html=Tests/Reports/routes_doctors.html --self-contained-html Tests/test_routes_doctors.py
pytest --html=Tests/Reports/routes_emergency.html --self-contained-html Tests/test_routes_emergency.py
pytest --html=Tests/Reports/routes_reminders.html --self-contained-html Tests/test_routes_reminders.py
pytest --html=Tests/Reports/routes_health.html --self-contained-html Tests/test_routes_health.py

