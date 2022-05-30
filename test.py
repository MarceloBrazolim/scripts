from pysondb import db
import json

dataBase = db.getDb("mapDB.json")
logPath = "testMap.log"

def post(DB, bssid, ipv4, name=""):
    return DB.add({"bssid":str(bssid), "ipv4":str(ipv4), "name":str(name)})

def getAll(DB):
    return DB.getAll()

def get(DB, bssid, ipv4):
    return DB.getByQuery({"bssid":str(bssid), "ipv4":str(ipv4)})

def put(DB, bssid, ipv4, name):
    DB.updateByQuery({"bssid":str(bssid), "ipv4":str(ipv4)}, {"name":str(name)})


def main():
    bssid = "50:92:B9:BA:EF:74"
    ipv4 = "192.168.0.198"
    name = "hiro"
    # print(post(dataBase, bssid, ipv4, name))
    data = get(dataBase, bssid, ipv4)
    data

    # if data == []:
    print(data)
    # dataBase.deleteById(226318994488726764)
    # print(getAll(dataBase))
    # mapp=[]
    # mapp += [x for x in "put"]
    # print(mapp)


main()
