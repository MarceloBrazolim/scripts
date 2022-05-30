from subprocess import check_output
from pysondb import db
import json
# from time import sleeps
import argparse


# default values
firstIp = "127.0.0.1"
secondIp = "127.0.0.10"
logPath = "testMap.log"
dataBase = db.getDb("mapDb.json")


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
def getAll(DB):
    return DB.getAll()

def get(DB, bssid, ipv4):
    return DB.getByQuery({"bssid":str(bssid), "ipv4":str(ipv4)})

def post(DB, bssid, ipv4, name=""):
    return DB.add({"bssid":str(bssid), "ipv4":str(ipv4), "name":str(name)})

def put(DB, bssid, ipv4, name):
    DB.updateByQuery({"bssid":str(bssid), "ipv4":str(ipv4)}, {"name":str(name)})

def getBssid():
    try:
        return str(check_output(['iwgetid', '-ar'])).split("'")[1].split("\\")[0]
    except:
        print("Impossible to locate BSSID, make sure you are connected to a network")
        exit(1)

class IpRange:
    # constructor
    def __init__(self, firstIp, secondIp, count, wait):
        self.firstIp = firstIp
        self.secondIp = secondIp
        self.count = count
        self.wait = wait

    def mapIp(self):
        bssid = getBssid()

        print(f"---- Parameters:\n  firstIp: {self.firstIp}\n  secondIp: {self.secondIp}")

        # converts str '192.168.0.1' to int array [192, 168, 0, 1]
        first = [int(x) for x in self.firstIp.split(".")]
        second = [int(x) for x in self.secondIp.split(".")]

        mapped = []
        for d in range(first[0], second[0]+1):
            for c in range(first[1], second[1]+1):
                for b in range(first[2], second[2]+1):
                    for a in range(first[3], second[3]+1):
                        command = ["ping", "-c", f"{self.count}", "-W", f"{self.wait}", f"{d}.{c}.{b}.{a}"]
                        try:
                            ipv4 = [str(check_output(command)).split('bytes from')[1].split(':')[0].strip()]
                            try:
                                print(dataBase)
                                print(bssid)
                                print(ipv4)
                                print("get: {}".format(get(dataBase, bssid, ipv4)))
                                # entry = json.loads(get(dataBase, bssid, ipv4))
                                entry = json.loads(get(dataBase, bssid, str(ipv4)))
                            except:
                                entry = ""
                            print("entry:" + entry)
                            mapped += [f"{ipv4}    {entry}"]
                        except:
                            pass
        with open(logPath, "w") as file:
            file.writelines(output+"\n" for output in mapped)
            print("---- Mapped IP addresses:")
            for x in mapped:
                print(x)
        # sleep(self.wait)


    def storeInfo(self, ipv4, name=""):
        bssid = getBssid()

        if get(dataBase, bssid, ipv4) == []:
            print(f"No registry for {bssid} : {ipv4}")
            print(f"Entry created:\n  bssid: {bssid}, ipv4: {ipv4}, name: {name}")
            post(dataBase, bssid, ipv4, name)
        else:
            put(dataBase, bssid, ipv4, name)
            print(f"Registry updated:\n  bssid: {bssid}, ipv4: {ipv4}, name: {name}")


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
