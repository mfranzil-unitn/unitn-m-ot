#!/bin/bash

sudo sysctl -w net.ipv4.tcp_syncookies=$((1 - $(sudo sysctl net.ipv4.tcp_syncookies | awk '{print $3}')))