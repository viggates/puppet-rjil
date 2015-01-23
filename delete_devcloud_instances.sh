#!/bin/bash
if [ $# -ne 1 ]
then
echo "Enter timestamp as an argument"
exit
fi
nova delete `nova list | grep $1 | awk {' print $4'}`

