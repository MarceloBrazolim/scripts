from time import sleep
import argparse
import os


# default values
firstIp = "127.0.0.1"
secondIp = "127.0.0.10"
logPath = "testMap.log"


# Argument Handler
parser = argparse.ArgumentParser(description='uses ICMP brute force to list connected devices in the local network')
parser.add_argument(nargs="?", default=f"{firstIp}", dest='firstIp', help="defines a custom initial IP")
parser.add_argument(nargs="?", default=f"{secondIp}", dest='secondIp',help="defines a custom IP limit")
parser.add_argument("-W", default=1, type=int, dest='wait', metavar='SECONDS', help="Time to wait for a response, in seconds.")
parser.add_argument("-c", default=1, type=int, dest='count', metavar='COUNT', help="Stop after sending COUNT packets.")
parser.add_argument('-d', '--debugg', dest='debugg', action='store_true', help=argparse.SUPPRESS)
parser.add_argument("-s", '--self', action='store_true', help="Enable discovery mode")


class IpRange:
    # constructor
    def __init__(self, firstIp, secondIp, count, wait):
        self.firstIp = firstIp
        self.secondIp = secondIp
        self.count = count
        self.wait = wait


    def mapIp(self):
        # converts str '192.168.0.1' to str array ['192', '168', '0', '1']
        self.firstIp = self.firstIp.split(".")
        self.secondIp = self.secondIp.split(".")
        print(f"firstIp: {self.firstIp}\nsecondIp: {self.secondIp}")

        # converts str array to int array
        first = [int(x) for x in self.firstIp]
        second = [int(x) for x in self.secondIp]

        os.remove(logPath)
        for d in range(first[0], second[0]+1):
            for c in range(first[1], second[1]+1):
                for b in range(first[2], second[2]+1):
                    for a in range(first[3], second[3]+1):
                        os.system(f"ping {d}.{c}.{b}.{a} -c {self.count} -W {self.wait} | grep -e 'bytes from' | cut -d ' ' -f 4 | cut -d ':' -f 1 >> {logPath} 2>&- &")
        sleep(self.wait)

    # def identifyIp():
    #     logFile = open(logPath, "a+")
    #     logFile.close()


def main():
    args = parser.parse_args()

    if args.debugg:
        print(f"args: {args}")


    mapping = IpRange(args.firstIp, args.secondIp, args.count, args.wait)
    mapping.mapIp()
    # mapping.identifyIp()


main()