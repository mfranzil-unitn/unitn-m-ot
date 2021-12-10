# importing the requests library
import requests
  
# api-endpoint
URL = "http://localhost:7777/process.php"

PARAMS = {
  'user':'lorenzo',
  'pass':'lorenzo',
  'drop':'deposit',
  'amount': '1',  
  }

for i in range(20):
  try:
    r = requests.get(url = URL, params = PARAMS,timeout=1)
    print(f"Request {i}: {r}")
  except requests.exceptions.ReadTimeout: 
    print(f"Request {i}: LOST")
    pass
