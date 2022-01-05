#docker run -d -it --security-opt seccomp=unconfined --cap-add=SYS_PTRACE --name Franzil-BOF-2 -e QEMU_GDB=10240 -p 8080:8080 -p 8081:8081 --platform linux/amd64 --mount type=bind,source="/Users/matte/OneDrive/Codice/github/unitn-m-ot/04-bof",target=/data amd64/ubuntu:18.04
docker run -d -it --security-opt seccomp=unconfined --name Franzil-BOF -p 8080:8080 -p 8081:8081 --platform linux/arm64/v8 --mount type=bind,source="/Users/matte/OneDrive/Codice/github/unitn-m-ot/04-bof",target=/data ubuntu:18.04

docker exec -it Franzil-BOF-2 /bin/bash

# Once in: apt update && apt install make gcc iproute2 gdb netcat -y
