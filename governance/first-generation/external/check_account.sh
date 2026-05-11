#!/bin/bash
# Copyright IBM Corp. 2017, 2026


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
