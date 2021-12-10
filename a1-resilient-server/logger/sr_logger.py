import pyshark
import logging
import os
import signal
import threading
import argparse
from datetime import datetime

# reload apache config
# sudo /etc/init.d/apache2 reload


# USEFUL PARAMS
TIME = 10  # number of seconds between one print of the statistics and the other
SERVER_IP = '10.1.5.2'

# PARAMS NEEDED FOR THE EXECUTION
parser = argparse.ArgumentParser(
    description='Logger for internet traffic incoming to a specific interface. A copy of the log is also saved in ./log_output folder')
parser.add_argument('-i', dest='interface', required=True,
                    type=str, help='Interface on which the script should listen')
args = parser.parse_args()

# LOGGING CONFIGURATION
logging.basicConfig(filename='./log_output/file_request.log',
                    filemode='a', format='%(message)s', level=logging.INFO)

# The only purpose of this methode is to nicely stop the application and its threads after the first CTRL + C


def signal_handler(sig, frame):
    print('\n\nExiting the application. Goodbye')
    os._exit(1)


def find(lst, key, value):
    for i, dic in enumerate(stat[lst]):
        if dic[key] == value:
            return i
    return -1


# DEBUG PURPOSE ONLY
# PATH = "./temp.log"


stat = {
    '1.html': [],
    '2.html': [],
    '3.html': [],
    '4.html': [],
    '5.html': [],
    '6.html': [],
    '7.html': [],
    '8.html': [],
    '9.html': [],
    '10.html': [],
    'others': [],
}


def print_stat():
    global stat
    os.system('clear')
    print("\n\n{:48} {:10}".format("", "SERVER"))
    print("--------------------------------------",
          datetime.now(), "-------------------------------------------------")

    logging.info("{:48} {:10}".format("", "SERVER"))
    logging.info("-------------------------------------- "+str(datetime.now()
                                                               ) + " -------------------------------------------------")
    # print the dictionary in a pretty way
    for filename, requests in stat.items():
        l = ""
        for req in requests:
            l += "[IP: " + str(req['ip']) + " N_REQ: " + \
                str(req['n_req']) + "] "

        print("  {:<10} {}".format(filename, l))
        logging.info("  {:<10} {}".format(filename, l))

    # resetting the stat variable
    stat = {
        '1.html': [],
        '2.html': [],
        '3.html': [],
        '4.html': [],
        '5.html': [],
        '6.html': [],
        '7.html': [],
        '8.html': [],
        '9.html': [],
        '10.html': [],
        'others': [],
    }

    threading.Timer(TIME, print_stat).start()

# this method will filter only for http packets and will understand the source ip before checking the content


def process_packet(p):
    if 'http' in p:
        if p.ip.dst == SERVER_IP:
            try:
                if str(p.http.request_method) == 'GET':
                    request_uri = str(p.http.request_uri).replace("/", "")
                    if request_uri is not None:
                        if request_uri not in ['1.html', '2.html', '3.html', '4.html', '5.html', '6.html', '7.html', '8.html', '9.html', '10.html']:
                            request_uri = "others"

                        index = find(request_uri, 'ip', p.ip.src)
                        if index >= 0:
                            stat[request_uri][index]['n_req'] = stat[request_uri][index]['n_req'] + 1
                        else:
                            stat[request_uri].append({'ip': p.ip.src, 'n_req': 1})
                else:
                    logging.error("\n [" + str(datetime.now()) + "] RECEIVED A " +
                                str(p.http.request_method) + " FROM " + p.ip.src)
                    print("\n [" + str(datetime.now()) + "] RECEIVED A " +
                        str(p.http.request_method) + " FROM " + p.ip.src)
            except AttributeError:
                print("RECEIVED HTTP PACKET WITHOUT REQUEST METHOD")
                logging.info(str(datetime.now()) + "RECEIVED HTTP PACKET WITHOUT REQUEST METHOD")
                

# this method will receive an interface on which pyshark is listening analyzing the incoming packet


def process_interface(cap):
    for p in cap.sniff_continuously():
        process_packet(p)


def main():

    print("Start listening on the interface " + args.interface)
    print_stat()
    cap = pyshark.LiveCapture(interface=args.interface)
    process_interface(cap)


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal_handler)
    main()
