import pyshark
import threading
import os
import signal
import logging
import copy
import argparse
from datetime import datetime

# USEFUL PARAMS
TIME = 0.5  # number of seconds between one print of the table and the other
LOG_TIME = 10  # number of seconds between one print of the table in the log and the other
SERVER_IP = '10.1.5.2'
CLIENT_1 = '10.1.2.2'
CLIENT_2 = '10.1.3.2'
CLIENT_3 = '10.1.4.2'
GATEWAY_IP = '10.1.5.3'
ROUTER_IP = '10.1.1.2'
OTHER = 'other'
TOTAL = 'total'  # this represent the total of package received

# PARAMS NEEDED FOR THE EXECUTION
parser = argparse.ArgumentParser(
    description='Logger for internet traffic incoming to a specific interface. A copy of the log is also saved in ./log_output folder')
parser.add_argument('-i', dest='interface', required=True,
                    type=str, help='Interface on which the script should listen')
parser.add_argument('-n', dest='machine_name', required=True,
                    type=str, help='Name of the machine')
args = parser.parse_args()


# LOGGING PARAMS
logging.basicConfig(filename='./log_output/traffic_'+args.machine_name+'.log',
                    filemode='a', format='%(message)s', level=logging.INFO)

# The only purpose of this methode is to nicely stop the application and its threads after the first CTRL + C
def signal_handler(sig, frame):
    print('\n\nExiting the application. Goodbye')
    os._exit(1)


# This method is used to print the statistics in a table every "TIME" seconds
def print_stat():
    global stat
    global print_stat_copy
    os.system('clear')
    print("\n\nUPDATE EVERY: " + str(TIME) + "s")
    print("{:48} {:10}".format("", args.machine_name))
    print("--------------------------------------",
          datetime.now(), "---------------------------------------------")

    # print the dictionary in a pretty way
    print("{:<10} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7}".format(
        'SOURCE', 'TCP', 'B_TCP', 'SYN', 'B_SYN', 'UDP', 'B_UDP', 'ICMP', 'B_ICMP', 'OTHER', 'B_OTHER'))
    print("---------------------------------------------------------------------------------------------------------------")
    for k, v in stat.items():
        if k != TOTAL:
            print("{:<10} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7}".format(
                v['NAME'], v['TCP'], v['B_TCP'], v['SYN'], v['B_SYN'], v['UDP'], v['B_UDP'], v['ICMP'], v['B_ICMP'], v['OTHER'], v['B_OTHER']))

    print("---------------------------------------------------------------------------------------------------------------")

    print("{:<10} | +{:<7}| {:<7} | +{:<7}| {:<7} | +{:<7}| {:<7} | +{:<7}| {:<7} | +{:<7}| {:<7}".format(
        "VARIANCE", stat[TOTAL]['TCP'] - print_stat_copy[TOTAL]['TCP'], "",
        stat[TOTAL]['SYN'] - print_stat_copy[TOTAL]['SYN'], "",
        stat[TOTAL]['UDP'] - print_stat_copy[TOTAL]['UDP'], "",
        stat[TOTAL]['ICMP'] - print_stat_copy[TOTAL]['ICMP'], "",
        stat[TOTAL]['OTHER'] - print_stat_copy[TOTAL]['OTHER'], ""))

    print_stat_copy = copy.deepcopy(stat)
    threading.Timer(TIME, print_stat).start()

# This method is used to print the statistics in the log every "LOG_TIME" seconds
def print_log():
    global stat
    global log_stat_copy
    logging.info("{:48} {:10}".format("", args.machine_name))
    logging.info("\n\n--------------------------------------" +
                 str(datetime.now()) + "-------------------------------------------")
    # print the dictionary in a pretty way
    logging.info("{:<10} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7}".format(
        'SRC_IP', 'TCP', 'B_TCP', 'SYN', 'B_SYN', 'UDP', 'B_UDP', 'ICMP', 'B_ICMP', 'OTHER', 'B_OTHER'))

    for k, v in stat.items():
        logging.info("{:<10} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7} | {:<7}".format(
            v['NAME'], v['TCP'], v['B_TCP'], v['SYN'], v['B_SYN'], v['UDP'], v['B_UDP'], v['ICMP'], v['B_ICMP'], v['OTHER'], v['B_OTHER']))

    logging.info(
        "---------------------------------------------------------------------------------------------------------------")
    
    logging.info("{:<10} | +{:<7}| {:<7} | +{:<7}| {:<7} | +{:<7}| {:<7} | +{:<7}| {:<7} | +{:<7}| {:<7}".format(
        "VARIANCE", stat[TOTAL]['TCP'] - log_stat_copy[TOTAL]['TCP'], "",
        stat[TOTAL]['SYN'] - log_stat_copy[TOTAL]['SYN'], "",
        stat[TOTAL]['UDP'] - log_stat_copy[TOTAL]['UDP'], "",
        stat[TOTAL]['ICMP'] - log_stat_copy[TOTAL]['ICMP'], "",
        stat[TOTAL]['OTHER'] - log_stat_copy[TOTAL]['OTHER'], ""))

    log_stat_copy = copy.deepcopy(stat)
    threading.Timer(LOG_TIME, print_log).start()


# Dictionary that will contain the statistics about the captured package
stat = {
    CLIENT_1: {
        'NAME': 'CLIENT_1',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    CLIENT_2: {
        'NAME': 'CLIENT_2',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    CLIENT_3: {
        'NAME': 'CLIENT_3',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    GATEWAY_IP: {
        'NAME': 'GATEWAY',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    ROUTER_IP: {
        'NAME': 'ROUTER',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    SERVER_IP: {
        'NAME': 'SERVER',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    OTHER: {
        'NAME': 'OTHERS',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
    TOTAL: {
        'NAME': 'TOTAL',
        'TCP': 0,
        'B_TCP': 0,
        'SYN': 0,
        'B_SYN': 0,
        'UDP': 0,
        'B_UDP': 0,
        'ICMP': 0,
        'B_ICMP': 0,
        'OTHER': 0,
        'B_OTHER': 0,
    },
}

# copy of stat used for calculate the amount of packets received in a particular timespan
print_stat_copy = copy.deepcopy(stat)
log_stat_copy = copy.deepcopy(stat)

# this method will check every intercepted packet understanding the type and updating the stat dictionary
def check_packet(p, CLIENT):
    # check if the packet is a TCP packet
    if 'tcp' in p:
        stat[CLIENT]['TCP'] = stat[CLIENT]['TCP'] + 1
        stat[CLIENT]['B_TCP'] = stat[CLIENT]['B_TCP'] + int(p.length)
        # check if the packet is a TCP SYN packet (SYN without ACK so new connection request)
        if int(p.tcp.flags_syn) == 1 and int(p.tcp.flags_ack) == 0:
            stat[CLIENT]['SYN'] = stat[CLIENT]['SYN'] + 1
            stat[CLIENT]['B_SYN'] = stat[CLIENT]['B_SYN'] + int(p.length)
    # check if the packet is a ICMP packet
    elif 'icmp' in p:
        stat[CLIENT]['ICMP'] = stat[CLIENT]['ICMP'] + 1
        stat[CLIENT]['B_ICMP'] = stat[CLIENT]['B_ICMP'] + int(p.length)
    # check if the packet is a UDP packet
    elif 'udp' in p:
        stat[CLIENT]['UDP'] = stat[CLIENT]['UDP'] + 1
        stat[CLIENT]['B_UDP'] = stat[CLIENT]['B_UDP'] + int(p.length)
    else:
        stat[CLIENT]['OTHER'] = stat[CLIENT]['OTHER'] + 1
        stat[CLIENT]['B_OTHER'] = stat[CLIENT]['B_OTHER'] + 1

# this method will filter only for the ip packets and will understand the source ip before checking the content
def process_packet(p):
    if hasattr(p, 'ip'):
        if p.ip.dst == SERVER_IP:
            if p.ip.src == CLIENT_1:                 # check for CLIENT_1
                check_packet(p, CLIENT_1)

            elif p.ip.src == CLIENT_2:               # check for CLIENT_2
                check_packet(p, CLIENT_2)

            elif p.ip.src == CLIENT_3:               # check for CLIENT_3
                check_packet(p, CLIENT_3)

            elif p.ip.src == SERVER_IP:              # check for SERVER_IP
                check_packet(p, SERVER_IP)
                
            elif p.ip.src == ROUTER_IP:              # check for ROUTER_IP
                check_packet(p, ROUTER_IP) 
            
            elif p.ip.src == GATEWAY_IP:             # check for GATEWAY_IP
                check_packet(p, GATEWAY_IP)    
                
            else:                                    # IP not registered in the network
                check_packet(p, OTHER)

            # saving the total amount of intercepted packets
            check_packet(p, TOTAL)

# this method will receive an interface on which pyshark is listening analyzing the incoming packet
def process_interface(cap):
    for p in cap.sniff_continuously():
        process_packet(p)

def main():
    print("Start listening on the interface " + str(args.interface))
    print("Log name: traffic_" + args.machine_name + ".log")
    print_stat()
    print_log()
    cap = pyshark.LiveCapture(interface=args.interface)
    process_interface(cap)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    main()
