#!/bin/bash

sudo apt-get update
sudo apt-get install -y libsqlite3-dev ruby ruby1.9.1-dev sqlite3

if ! grep no-ri /etc/gemrc &> /dev/null; then
   sudo bash -c "echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc"
fi

if ! grep w1-gpio /etc/modules &> /dev/null; then
   sudo bash -c "echo 'w1-gpio' >> /etc/modules"
   sudo modprobe w1-gpio
fi

if ! grep w1-therm /etc/modules &> /dev/null; then
   sudo bash -c "echo 'w1-therm' >> /etc/modules"
   sudo modprobe w1-therm
fi

bundle
ruby ./bin/create_database.rb
