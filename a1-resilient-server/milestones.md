# Milestones

## Defense

- (one week) Develop monitoring at the server that will let you automatically check the content of HTTP requests you are getting and who is sending them.
- (one week) Develop monitoring software on the gateway machine that will let you automatically check if server is getting slow.
- (one week) Extend your monitoring software so you can automatically get statistics on number of packets and bytes sent to the server in TCP data, TCP SYN, UDP and ICMP and Total categories so you can diagnose various DDoS attacks. Make sure the software monitors the correct interface.
- (two weeks) Extend your monitoring software so you can detect number of packets and bytes sent to the server by each client IP. Make sure the software monitors the correct interface.
- (one-two weeks) Learn how you would write rules for iptables to filter traffic with some characteristics, e.g., by protocol, sender IP, length, TCP flags, etc. You may need to write those rules manually during the exercise but make sure you have tried to write them while preparing for the exercise and that they work correctly. You can check correctness by generating attack traffic with some signature (e.g., packet length, sender IP, protocol, etc.), writing a rule to filter it and checking that that traffic is dropped. You can check for drops in two ways. First, you could run your monitoring software on the interface leading to the server. Second, you could use an option with iptables that lets you see counts of times a rule was matched. It may be advisable to try both methods for measuring correctness as the first measures what goes to the server and the second shows you that the rule was activated by attack traffic.

## Attack

- (one week) Develop attacks that may crash the server because they require it to process too many requests or because requests are malformed. This may or may not be possible but give it a try.
- (one week) Develop attacks that flood the link between the gateway and the server. It may be advisable to use raw sockets here to craft packets. It may also be advisable to parameterize attack software so that you can easily change spoofing technique, if any, packet type, packet length, etc. You can use Flooder tool for this purpose.
- (one week) Develop attacks that flood the link or the server with too many HTTP requests.
- (two weeks) Develop attacks that use slow HTTP flood.
- (one-two weeks) Test ALL your attacks and make sure they do work against your server implementation. Then iterate between trying to handle those that work against your server and trying to craft new attacks that will bring that even more hardened server down.