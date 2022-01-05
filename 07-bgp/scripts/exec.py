#!python3

import os, sys

hosts = [
    "client",
    "asn1",
    "asn2",
    "asn3",
    "asn4",
    "attacker",
    "server"
]


def attacker():
    while True:
        print("=======================================================================================")
        for index, host in zip(range(len(hosts)), hosts):
            print(f"{index}: {host}     ", end="")
        print("\n=======================================================================================")
        print("Choose the host to connect to: ", end='')
        host_index: int = int(input())
        if host_index not in range(len(hosts)):
            print("Bye")
            exit(0)
        host: str = f"{hosts[host_index]}.franzil-bgphijack.offtech"
        print(f"Connecting to {host} via otech2af@users.deterlab.net...")
        sys.stdout.flush()

        child_pid = os.fork()
        if child_pid == 0:
            # child process
            os.execl('/bin/bash', 'bash', '-c', f'ssh -J otech2af@users.deterlab.net otech2af@{host}')
            sys.exit(0)

        pid, status = os.waitpid(child_pid, 0)
        #print("wait returned, pid = %d, status = %d" % (pid, status))
        #jumpbox = paramiko.SSHClient()
        #jumpbox.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        #jumpbox.connect('users.deterlab.net', username='otech2af',
        #                key_filename="/Users/matte/.ssh/deter", passphrase="Ilmionomemegatronfabiomegatron")
#
        #jumpbox_transport = jumpbox.get_transport()
        #src_addr = ('users.deterlab.net', 22)
        #dest_addr = ("192.168.253.1", 22)
        #jumpbox_channel = jumpbox_transport.open_channel("direct-tcpip", dest_addr, src_addr)
#
        #target = paramiko.SSHClient()
        #target.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        #target.connect(host, username='otech2af', sock=jumpbox_channel)
        #channel = target.get_transport().open_session()
#
        ## Open interactive SSH session
        #channel.get_pty()
        #channel.invoke_shell()
        #channel.send('/bin/bash\n')
#
        #input()
        #target.close()
        #jumpbox.close()
        #exit(0)
        # ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(cmd_to_execute)

        # result = os.fork()
        # if result == 0:
        # commands.get("/bin/zsh", "zsh", "-c", f"ssh -J otech2af@users.deterlab.net otech2af@{host}")
        # else:
        #    input()


if __name__ == '__main__':
    attacker()
