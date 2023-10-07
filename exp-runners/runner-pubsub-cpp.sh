#!/bin/bash

_start=1
_end=100

echo "label,timestamp,cpu,mem" > ../data/resource-pubsub-cpp1.csv

for i in $(seq ${_start} ${_end})
do
    ./progress-bar.sh ${_start} ${_end} ${i}
 
    python3 ../energy-mon.py -p simple_pub_sub_cpp -a talker -i pub_cpp1 &> ./log/talker-cpp.log &
    TALKER_PID=$!
    echo $TALKER_PID
    python3 ../energy-mon.py -p simple_pub_sub_cpp -a listener -i sub_cpp1 &> ./log/listener-cpp.log & 
    LISTENER_PID=$!
    echo $LISTENER_PID
    
    sleep 1
    timestamp=$(date +%s)
    mem1=`./mem.sh $TALKER_PID`
    mem2=`./mem.sh $LISTENER_PID`
    cpu1=`./cpu.sh $TALKER_PID`
    cpu2=`./cpu.sh $LISTENER_PID`
    talker="talker_cpp,$timestamp,$cpu1,$mem1"
    listener="listener_cpp,$timestamp,$cpu2,$mem2"
    echo $talker >> ../data/resource-pubsub-cpp1.csv
    echo $listener >> ../data/resource-pubsub-cpp1.csv

    while kill -0 $LISTENER_PID 2> /dev/null; do
        sleep 1
    done 
done