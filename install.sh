#!/bin/bash

if [ ! -f $1/QFirehose ]; then
    echo "[ERROR] Please specify a valid path to release directory as first argument"
    exit 255
fi

RELEASE_DIR=$(readlink -f $1)
SERIAL_MODULE_DIR="/lib/modules/$(uname -r)/kernel/drivers/usb/serial"

case $2 in
    "")
        echo "[INFO] Checking current version..." && autopi ec2x.query "at+qgmr"
        echo "[INFO] Clearing any active sleep timers..." && autopi power.sleep_timer enable=false
        echo "[INFO] Ensuring module 'qcserial' is absent..." && mv $SERIAL_MODULE_DIR/qcserial.ko $SERIAL_MODULE_DIR/qcserial.ko.orig

        echo "[INFO] Installing 'eg25g-update' service..." && cp $RELEASE_DIR/update.service /etc/systemd/system/eg25g-update.service && sed -i "s,@RELEASE_DIR,$RELEASE_DIR,g" /etc/systemd/system/eg25g-update.service && systemctl enable eg25g-update \
        && echo "[INFO] Ensuring 'qmi-manager' service is masked..." && systemctl mask qmi-manager \
        && echo "[INFO] Ensuring 'salt-minion' service is masked..." && systemctl mask salt-minion \
        && echo "[INFO] Scheduling system restart..." && autopi power.sleep interval=10 reason=eg25g_update confirm=true && sleep 3 \
        && echo "[INFO] Ensuring 'qmi-manager' service is stopped..." && systemctl stop qmi-manager \
        && echo "[INFO] Ensuring 'salt-minion' service is stopped..." && systemctl stop salt-minion \
        && echo "[INFO] Update continues after system restart, please wait..." && sleep 60

        ;;
    "fulfil")
        echo "[INFO] Ensuring 'qmi-manager' service is unmasked..." && systemctl unmask qmi-manager
        echo "[INFO] Ensuring 'salt-minion' service is unmasked..." && systemctl unmask salt-minion
        echo "[INFO] Uninstalling 'eg25g-update' service..." && systemctl disable eg25g-update && rm /etc/systemd/system/eg25g-update.service

        echo "[INFO] Ensuring amplifier is powered on..." && echo "6" > /sys/class/gpio/export && echo "out" > /sys/class/gpio/gpio6/direction && echo "1" > /sys/class/gpio/gpio6/value
        aplay $RELEASE_DIR/notification.wav
        $RELEASE_DIR/QFirehose -f $RELEASE_DIR
        if [ $? -eq 0 ]; then
            echo "[INFO] Successfully updated EG25-G module!" && aplay $RELEASE_DIR/success.wav
        else
            echo "[ERROR] Failed to update EG25-G module!" && aplay $RELEASE_DIR/failure.wav
        fi
        echo "[INFO] Rebooting in 10 seconds..." && sleep 10 && reboot

        ;;
    "test")
        echo "[INFO] Ensuring 'qmi-manager' service is unmasked..." && systemctl unmask qmi-manager
        echo "[INFO] Ensuring 'salt-minion' service is unmasked..." && systemctl unmask salt-minion
        echo "[INFO] Uninstalling 'eg25g-update' service..." && systemctl disable eg25g-update && rm /etc/systemd/system/eg25g-update.service

        echo "[INFO] Ensuring amplifier is powered on..." && echo "6" > /sys/class/gpio/export && echo "out" > /sys/class/gpio/gpio6/direction && echo "1" > /sys/class/gpio/gpio6/value
        aplay $RELEASE_DIR/notification.wav && sleep 1 && aplay $RELEASE_DIR/success.wav
        echo "[INFO] Test completed, rebooting in 10 seconds..." && sleep 10 && reboot

        ;;
esac
