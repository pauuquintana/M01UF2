#!/bin/bash

SERVER="localhost"
PORT="3333"

echo "Cliente de EFTP"

echo "(1) Send"

echo "EFTP 1.0" | nc $SERVER $PORT

echo "(2) Listen"

DATA=`nc -l -p $PORT -w 0`

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

DATA=`nc -l -p $PORT -w 0`

echo $DATA



