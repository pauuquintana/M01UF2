#!/bin/bash

CLIENT="localhost"
PORT="3333"
TIMEOUT="1"

echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(3) Test & Send"

PREFIX=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`

if [ "$PREFIX" != "EFTP" ]
then
echo "ERROR 1: BAD HEADER"
sleep 1
#echo "KO_HEADER" | nc $CLIENT $PORT 
exit 1
fi

if [ "$VERSION" != "1.0" ]
then
echo "ERROR 1: BAD HEADER"
sleep 1
#echo "KO_HEADER" | nc $CLIENT $PORT 
exit 1
fi

CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$CLIENT" == " " ]
then 
echo "ERROR: NO IP"
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


echo "(7a) Listen NUM_FILES"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(7b) Send OK/KO_NUM_FILES"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "NUM_FILES" ]
then 
	echo "ERROR 3: WRONG NUM_FILES PREFIX"
	sleep 1
	echo "KO_NUM_FILES" | nc $CLIENT $PORT
	exit 3
fi

echo "OK_FILE_NUM" | nc $CLIENT $PORT

NUM_FILES=`echo $DATA | cut -d " " -f 2`

for N in `seq $NUM_FILES`
do

echo "Archivo número $N"

echo "(8b) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA	
echo "(12b) Test & Store & Send"

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

MD5_CLIENT=`echo $DATA | cut -d " " -f 3`
MD5_TEST=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$MD5" != "$MD5_TEST" ]
then
echo "ERROR 5: BAD MD5"
sleep 1
echo "KO_MD5" | nc $CLIENT $PORT
fi

echo "OK_MD5"
sleep 1
echo "OK_MD5" | nc $CLIENT $PORT

echo "(13) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(16) Store & Send"

echo $FILE_NAME

INFO_FILE=`cat $FILE_NAME`

if [ "$INFO_FILE" == "" ]
then
	echo "ERROR 4: EMPTY DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi

echo $DATA > inbox/$FILE_NAME

sleep 1
echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(20) Test & Send"
echo $DATA
PREFIX=`echo $DATA | cut -d " " -f 1`

echo $PREFIX
if [ "$PREFIX" != "FILE_MD5" ]
then
    echo "ERROR: BAD_PREFIX"
    sleep 1
    echo "KO_PREFIX" | nc $CLIENT $PORT
fi

sleep 1
echo "OK_PREFIX" | nc $CLIENT $PORT

FILE_MD5_CLIENT=`echo $DATA | cut -d " " -f 2`
FILE_MD5_SERVER=`cat $INFO_FILE | md5sum | cut -d " " -f 1`

if [ $FILE_MD5_CLIENT != $FILE_MD5_SERVER ]
then
    echo "KO_FILE_MD5"
    sleep 1
    echo "KO_FILE_MD5" | nc $CLIENT $PORT
fi

echo "OK_FILE_MD5"
sleep 1
echo "OK_FILE_MD5" | nc $CLIENT $PORT

done

echo "FIN"
exit 0
