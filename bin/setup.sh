#!/bin/bash

if ! grep w1-gpio /etc/modules; then
   sudo bash -c "echo 'w1-gpio' >> /etc/modules"
   sudo modprobe w1-gpio
fi

if ! grep w1-therm /etc/modules; then
   sudo bash -c "echo 'w1-therm' >> /etc/modules"
   sudo modprobe w1-therm
fi


