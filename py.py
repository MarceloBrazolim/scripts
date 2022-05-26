from subprocess import check_output
from time import sleep
import argparse
import json


# default values
firstIp = "127.0.0.1"
secondIp = "127.0.0.10"
logPath = "testMap.log"
configPath = "config.config"


# Argument Handler
parser = argparse.ArgumentParser(description='uses ICMP brute force to list connected devices in the local network')
parser.add_argument(nargs="?", default=f"{firstIp}", dest='firstIp', help="defines a custom initial IP")
parser.add_argument(nargs="?", default=f"{secondIp}", dest='secondIp',help="defines a custom IP limit")
parser.add_argument("-W", default=1, type=int, dest='wait', metavar='SECONDS', help="Time to wait for a response, in seconds.")
parser.add_argument("-c", default=1, type=int, dest='count', metavar='COUNT', help="Stop after sending COUNT packets.")
parser.add_argument('-d', '--debugg', dest='debugg', action='store_true', help=argparse.SUPPRESS)
parser.add_argument("-i", nargs=2, dest="ipIdentifier", required=False, metavar=("IP", "NAME"), help="Associates a Name to a IP address for each network.")
parser.add_argument("-s", '--self', action='store_true', help="Enable discovery mode")


# CRUD .. yes, in python
def crudGet(file):
    return [x.split("\n")[0] for x in open(file, "r").readlines()]

def crudGetJson(file):
    return json.load(open(file, "r"))

def crudPut(file, data, id, ip, name):
    data[id]['ip'] = ip
    data[id]['name'] = name
    with open(data, "w") as file:
        json.dump(data, file)


def checkElement(array, element):
    # checks weather or not IP is present in logPath
    # if exists return the element in the array equals to the parameter element
    try:
        return [x for x in array if x == element][0]
    except:
        return exit(1)


class IpRange:
    # constructor
    def __init__(self, firstIp, secondIp, count, wait):
        self.firstIp = firstIp
        self.secondIp = secondIp
        self.count = count
        self.wait = wait


    def mapIp(self):
        print(f"firstIp: {self.firstIp}\nsecondIp: {self.secondIp}")

        # converts str '192.168.0.1' to int array [192, 168, 0, 1]
        first = [int(x) for x in self.firstIp.split(".")]
        second = [int(x) for x in self.secondIp.split(".")]

        with open(logPath, "w") as file:
            mapped = []
            for d in range(first[0], second[0]+1):
                for c in range(first[1], second[1]+1):
                    for b in range(first[2], second[2]+1):
                        for a in range(first[3], second[3]+1):
                            command = ["ping", "-c", f"{self.count}", "-W", f"{self.wait}", f"{d}.{c}.{b}.{a}"]
                            try:
                                mapped += [str(check_output(command)).split('bytes from')[1].split(':')[0].strip()]
                            except:
                                pass
            with open(logPath, "w") as file:
                file.writelines(output+"\n" for output in mapped)
            # sleep(self.wait)


    def storeInfo(self, ip, name):
        try:
            # get the active network's bssid
            self.bssid = str(check_output(['iwgetid', '-ar'])).split("'")[1].split("\\")[0]
            print(self.bssid)  #### debugg
        except:
            print("Impossible to locate BSSID, make sure you are connected to a network.")
            exit(1)

        try:
            checkElement(crudGet(logPath), ip)
        except:
            print(f"impossible to locate {ip} in {logPath}")
            exit(1)

        # json model to be used on configPath
        dictionary = {
            "_id" : self.bssid,
            "user" : [
                {"ip" : ip, "name" : name}
            ]
        }

        crudPut(configPath, crudGetJson(configPath), self.bssid, ip, name)
        print(crudGetJson(configPath))
        print(crudGet(logPath))



def main():
    args = parser.parse_args()

    if args.debugg:
        print(f"args: {args}")

    mapping = IpRange(args.firstIp, args.secondIp, args.count, args.wait)

    if args.ipIdentifier != None:
        mapping.storeInfo(args.ipIdentifier[0], args.ipIdentifier[1])
    else:
        mapping.mapIp()


main()
