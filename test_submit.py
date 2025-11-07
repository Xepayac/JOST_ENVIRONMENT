
import requests
import json

url = "http://127.0.0.1:8080/api/submit/"
headers = {
    "Content-Type": "application/json",
    "X-API-KEY": "jost-dev-key"
}
data = {
    "simulation_parameters": {}
}

try:
    response = requests.post(url, headers=headers, data=json.dumps(data))
    print(f"Status Code: {response.status_code}")
    print("Response JSON:")
    try:
        print(response.json())
    except json.JSONDecodeError:
        print(response.text)
except requests.exceptions.RequestException as e:
    print(f"An error occurred: {e}")
