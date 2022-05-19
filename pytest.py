from time import sleep
from os import system
try:
    import argparse
except:
    dep_not_met = "argparse"
    print(f"## Dependencies not satisfied: {dep_not_met}")
    exit(1)

parser = argparse.ArgumentParser(description='uses ICMP brute force to list connected ' +
                                                                            'devices in the local network')

parser.add_argument("--ipInitial", default='127.0.0.1', dest='__ipInitial', required=False, help="defines a custom initial IP")
parser.add_argument("--ipLimit", default='127.0.0.10', dest='__ipLimit', required=False, help="defines a custom IP limit")

parser.add_argument("-W", default=1, type=int, dest='wait', metavar='SECONDS', help="Time to wait for a response, in seconds.")
parser.add_argument("-c", default=1, type=int, dest='count', metavar='COUNT', help="Stop after sending COUNT packets.")
parser.add_argument("-s", '--self', action='store_true', help="Enable discovery mode")

parser.add_argument('-d', '--debugg', dest='d', action='store_true', help=argparse.SUPPRESS)


##### Global Variables
__ipInitial = [127, 0, 0, 1]
__ipLimit = [__ipInitial[0], __ipInitial[1], __ipInitial[2]+0, 40]



def initialInput(__ipInitial, __ipLimit):
    print("-----Enter initial and final IP to map:")
    ipInitial = ''
    ipLimit = ''
    ipInitial = str(input(f'Initial IP value (std. {__ipInitial[0]}.{__ipInitial[1]}.{__ipInitial[2]}.{__ipInitial[3]}) --> ')).split('.')
    ipLimit = str(input(f'Limit IP value (std. {__ipLimit[0]}.{__ipLimit[1]}.{__ipLimit[2]}.{__ipLimit[3]}) --> ')).split('.')

    if ipInitial[0] != '':
        for index in range(len(ipInitial)):
            __ipInitial[index] = ipInitial[index]
        __ipInitial = [int(x) for x in __ipInitial]
    if ipLimit[0] != '':
        for index in range(len(ipLimit)):
            __ipLimit[index] = ipLimit[index]
        __ipLimit = [int(x) for x in __ipLimit]

    return [__ipInitial, __ipLimit]


def myIp():
    myIpList=str(system("ip address | grep -e 'inet ' | cut -d '.' -f 1,2,3,4 | cut -c1-4 --complement | cut -d ' ' -f 2")).split('\n')
    return myIpList


def pingNet(R, wait, count):    # receives R[ [192, 168, 0, 1], [192, 168, 0, 255] ]
    print(f"Mapping... ({R[0][0]}.{R[0][1]}.{R[0][2]}.{R[0][3]} - {R[1][0]}.{R[1][1]}.{R[1][2]}.{R[1][3]})")
    pingNetList=[]
    for d in range(R[0][0], R[1][0]+1):
        for c in range(R[0][1], R[1][1]+1):
            for b in range(R[0][2], R[1][2]+1):
                for a in range(R[0][3], R[1][3]+1):
                    # pingNetList+=str(system(f'(ping -W {wait} -c {count} {d}.{c}.{b}.{a} | grep "bytes from" | cut -d " " -f 4 | cut -d ":" -f 1 &) 2>&-'))
                    try:
                        command = system(f'ping {d}.{c}.{b}.{a} -c {count} -W {wait} | grep -e "bytes from" &')
                        if command != 0:
                            pingNetList += str(command)
                    except:
                        pass

    sleep(2)
    return pingNetList


def main():
    args = parser.parse_args()
    if args.d:
        print(f"args: {args}")

    print("-----Your IP address is:")
    myIp()

    ranges = initialInput(__ipInitial, __ipLimit)

    print("-----Mapped IP addresses:")
    print(pingNet(ranges, args.wait, args.count))

main()
