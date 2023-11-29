#!/bin/bash

CLIENT="localhost"
PORT="3333"
TIMEOUT="1"

echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA 

echo "(3) Test & Send"

if [ "$DATA" != "EFTP 1.0" ]
then
sleep 1
echo "ERROR 1: BAD HEADER"
sleep 1
echo "KO_HEADER" | nc $CLIENT $PORT 
exit 1
fi

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(7) Test & Send"

if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 2: BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(8) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(12) Test & Store & Send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "OK_FILE_NAME"
sleep 1
echo "OK_FILE_NAME" | nc $CLIENT $PORT
echo $FILE_NAME


echo "(13) Listen"

nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME

echo "(16) Store & Send"

DATA=`cat inbox/$FILE_NAME`

INFO_FILE=`cat $FILE_NAME |wc -w`


if [ "$DATA" == "" ]
then
	echo "ERROR 4: EMPTY DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi

sleep 1
echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(20) Test & Send"

PREFIX=echo $DATA | cut -d " " -f 1

if [ "$PREFIX" != "FILE_MD5" ]
then
    echo "BAD_PREFIX"
    sleep 1
    echo "KO_PREFIX" | nc $CLIENT $PORT
fi

sleep 1
echo "OK_PREFIX" | nc $CLIENT $PORT

FILE_MD5_CLIENT=echo $DATA | cut -d " " -f 2
FILE_MD5_SERVER=cat $DATA_FILE | md5sum | cut -d " " -f 1

if [ $FILE_MD5_CLIENT != $FILE_MD5_SERVER ]
then
    echo "KO_FILE_MD5"
    sleep 1
    echo "KO_FILE_MD5" | nc $CLIENT $PORT
fi

echo "FIN"
exit 0
