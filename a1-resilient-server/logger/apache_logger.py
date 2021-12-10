import time
import os
import signal
import logging
import threading
from datetime import datetime


# LOGGING CONF
logging.basicConfig(filename='./log_output/apache_req.log', filemode='w',
                    format='%(asctime)s - %(message)s', level=logging.INFO)

# USEFUL PARAMS
PATH = "./log_output/varnish.log"
THRESHOLD = 400000
N_OK_REQ = 0
REFRESH_TIME=60


# reload apache config
# sudo /etc/init.d/apache2 reload

# RUN VARNISH LOGGER
# sudo varnishncsa  -F "%h %l %u %t "%r" %s %b - t: %D" >> $HOME/cctf-g3/logger/log_output/varnish.log

# DEBUG ONLY
# PATH="./temp.log"

# The only purpose of this methode is to nicely stop the application and its threads after the first CTRL + C


def signal_handler(sig, frame):
    print('\n\nExiting the application. Goodbye')
    os._exit(1)


#clearing the console every REFRESH_TIME seconds
def clear_console():
    os.system('clear')
    print("\n\n{:48} {:10}".format("", "SERVER"))
    print("--------------------------------------",
          datetime.now(), "-------------------------------------------------")

    print(f"\nReading from {PATH}")
    print("Saving the log in ./log_output/apache_req.log")
    print(f"THRESHOLD SETTED TO {THRESHOLD/1000} ms")
    threading.Timer(REFRESH_TIME, clear_console).start()


def follow(f):
    global N_OK_REQ
    f.seek(0, 2)  # Pointing to the end of the file
    while True:
        line = f.readline()  # read the last line
        if not line:  # if true means that the line is empty, wait 0.1s and then repeat
            time.sleep(0.1)
            continue
        else:
            line = line.split(" ")
            response_time = line[-1]
            if str(response_time) != '' and response_time[:-2].isdigit():
                response_time = int(response_time)
                if response_time > THRESHOLD:  # for each line is checked if the response time is above a certain THRESHOLD
                    print(f"\n {datetime.now()}")
                    print(f"Weird delay responding {line[0]} last request took {float(response_time)/1000000.0}s")
                    print("N:", N_OK_REQ, "requests were ok")
                    logging.info(
                        "Delay responding "+line[0]+" last request took " + str(float(response_time)/1000.0)+"s")
                    logging.info("N: " + str(N_OK_REQ) + " requests were ok\n")
                    N_OK_REQ = 0
                else:
                    N_OK_REQ = N_OK_REQ + 1


if __name__ == '__main__':
    logfile = open(PATH, "r")
    os.system('clear')
    clear_console()
    signal.signal(signal.SIGINT, signal_handler)
    follow(logfile)  # Start following the given logfile

