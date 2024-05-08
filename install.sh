#!/bin/bash

. etc/raspiducky/raspiducky.conf

BIN_DIR=/usr/bin
ETC_DIR=/etc/raspiducky
FLASH_DISK_SIZE=100000 # 100MB
CONFIG_DISK_SIZE=10000 # 10MB

# DEPENDENCIES
sudo apt update
sudo apt install python3-bluez

# EXEC FILES
sudo gcc hid-gadget-test.c -o $BIN_DIR/hid-gadget
sudo cp scripts/hid.sh $BIN_DIR/
sudo cp scripts/run_payload.sh $BIN_DIR/

sudo chmod 777 $BIN_DIR/hid-gadget
sudo chmod 777 $BIN_DIR/hid.sh
sudo chmod 777 $BIN_DIR/run_payload.sh

# FIX BLUETOOTH FROM: https://gist.github.com/arrase/5ed707a3070ef527743d12c971dae6ef
grep bluetoothd\ --compat /lib/systemd/system/bluetooth.service || sudo sed 's/bluetooth\/bluetoothd/bluetooth\/bluetoothd\ --compat/' -i /lib/systemd/system/bluetooth.service

# APP CONFIG
[ -d $VAR_DIR ] || sudo mkdir $VAR_DIR

[ -f $CONFIG_DISK ] || (sudo dd if=/dev/zero of=$CONFIG_DISK bs=1024 count=$CONFIG_DISK_SIZE && sudo mkfs.vfat $CONFIG_DISK)

[ -d $ETC_DIR ] || sudo mkdir $ETC_DIR
(mount | grep $CONFIG_DISK) || sudo mount $CONFIG_DISK $ETC_DIR -o loop,rw

[ -f $ETC_DIR/raspiducky.conf ] || sudo cp etc/raspiducky/raspiducky.conf $ETC_DIR/raspiducky.conf
[ -f $ETC_DIR/bluetooth.conf ] || sudo cp etc/raspiducky/bluetooth.conf $ETC_DIR/bluetooth.conf
[ -d $ETC_DIR/payloads-db ] || sudo cp -r etc/raspiducky/payloads $ETC_DIR/payloads-db
[ -d $ETC_DIR/keyboard_layouts ] || sudo cp -r etc/raspiducky/keyboard_layouts $ETC_DIR/keyboard_layouts
[ -d $ETC_DIR/onboot_payload ] || sudo mkdir $ETC_DIR/onboot_payload

grep $CONFIG_DISK /etc/fstab || (echo "$CONFIG_DISK   $ETC_DIR    vfat    loop,rw          0       2" | sudo tee --append /etc/fstab)
[ -f $ETC_DIR/keyboard_layouts/current.py ] || sudo cp $ETC_DIR/keyboard_layouts/db/QWERTY-ES_es.py $ETC_DIR/keyboard_layouts/current.py

# BOOT CONFIG
grep "dtoverlay=dwc2" /boot/config.txt || (echo "dtoverlay=dwc2" | sudo tee --append /boot/config.txt)
grep "dwc2" /etc/modules || (echo "dwc2" | sudo tee --append /etc/modules)
grep "libcomposite" /etc/modules || (echo "libcomposite" | sudo tee --append /etc/modules)

grep "/usr/bin/run_payload.sh" /etc/rc.local || (awk '/exit\ 0/ && c == 0 {c = 0; print "\n/usr/bin/hid.sh\nsleep 3\n/usr/bin/run_payload.sh\n"}; {print}' /etc/rc.local | sudo tee /etc/rc.local)

# FLASH DRIVE
[ -f $STORAGE_FILE ] || (sudo dd if=/dev/zero of=$STORAGE_FILE bs=1024 count=$FLASH_DISK_SIZE && sudo mkfs.vfat $STORAGE_FILE)

# INSTALL RASPIDUCKY
cd ducky
[ -d /usr/local/lib/python3.11/dist-packages/RaspiDucky/ ] && sudo rm -rd /usr/local/lib/python3.11/dist-packages/RaspiDucky/*
sudo python setup.py build

