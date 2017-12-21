#!/bin/bash
#archives ports log  for month of xxx

cat ports.log | grep "$1" >> "ports.log-$1"
sed -i /$1/d ports.log
sed -i /killing/d ports.log
