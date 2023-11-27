#!/bin/bash
##IP=`ip address | grep inet | grep -i enp0s3 | cut -d " " -f 6| cut -d "/" -f 1`

SERVER="localhost"
PORT="3333"
TIMEOUT="1"

echo "Cliente de EFTP"

echo "(1) Send"

echo "EFTP 1.0" | nc $SERVER $PORT

echo "(2) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(5) Test & Send"
if [ "$DATA" != "OK_HEADER" ]
then
echo "ERROR 1: BAD HEADER"
exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT

echo "(6) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then 
	echo "ERROR 2: BAD HANDSHAKE"
	exit 2
fi

echo "(10) Send"

sleep 1
echo "FILE_NAME fary1.txt" | nc $SERVER $PORT

echo "(11) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(14) Test & Send"
if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "ERROR 3: WRONG FILE NAME"
	exit 3
fi
sleep 1

cat imgs/fary1.txt | nc $SERVER $PORT
echo "(15) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then 
	echo "ERROR 4: BAD DATA"
	exit 4
fi

echo "FIN"
exit 0
