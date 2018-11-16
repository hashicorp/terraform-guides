#!/bin/bash

#set -e

CODE=$1

case $CODE in
     1)
        BALANCE=100
        ;;
     2)
        BALANCE=0
        ;;
     *)
        BALANCE=0
        ;;
esac

echo "{ \"balance\": \"$BALANCE\" }"
