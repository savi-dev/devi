import sys,json;
data=json.loads(sys.stdin.read());
result=data["result"]

#print "Result: " + result["successful"];
if result["successful"] == "true":
    print data["location"]
else:
    print result["errorStr"]
