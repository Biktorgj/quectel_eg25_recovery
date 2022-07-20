# Stock firmware recovery for Quectel EG25-G
This repo contains all the firmware versions we have found for the Quectel EG25-G Modem.

There are two ways of flashing these:
1. Via fastboot, if the modem is working correctly.
2. With EDL, if the modem doesn't boot, or if you want to make sure *everything* in the package is installed.

## Flashing with fastboot:
1. Make sure you have `fastboot` installed in your host system
2. Unpack or clone this repo
3. Open a root terminal, and in the folder where you extracted the firmware, run: `./flashstock`

## Flashing with qfirehose in EDL mode

### Entering EDL Mode
In order to flash the stock firmware to your modem, you will need to enter EDL mode.
### Enter EDL with ADB
If your modem is currently functioning and able to boot into its firmware, you can enter EDL mode by issuing a command over ADB.

If your modem is currently running the stock firmware, you will need to [unlock adb access](https://xnux.eu/devices/feature/modem-pp.html#toc-unlock-adb-access).

If you are running biktor's firmware, you can simply run `sudo mmcli -m any --command="AT+ADBON"` to enable ADB.

Once ADB access is enabled, execute `adb reboot edl`.
If adb exits with `adb: insufficient permissions for device`, run `adb kill-server` and then run `sudo adb reboot edl`.
### Enter EDL with test points
If your modem is not able to boot, you will need to open your PinePhone to expose the rear of the PCB in order to short two test points. This will require you to remove the screws under the rear cover.
![Pinephone Mainboard](https://raw.githubusercontent.com/biktorgj/quectel_eg25_recovery/EG25GGBR07A08M2G_01.002.01.002/board.jpg)

Once you have exposed the PCB, you must short the two test points highlighted above in red and power on the PinePhone. The battery must also be installed, otherwise the modem will not power on (even if the PinePhone itself does!). Keep the test points shorted until the PinePhone is fully booted (which can usually be confirmed by hearing the camera click a few times).

To check if you're currently booted in EDL mode, run `lsusb` and inspect the output. You should see the following device listed:
`Bus 003 Device 003: ID 05c6:9008 Qualcomm, Inc. Gobi Wireless Modem (QDL mode)`

## Flashing the firmware
It should be noted that if you entered EDL with ADB and qfirehose fails during flashing, you may break your firmware and need to enter EDL by shorting the test points! Be prepared for this possibility.

Once in EDL mode, open a terminal and go to the root directory of this repository to execute qfirehose.

If you use an ARM64 distro (most likely), run:

`sudo ./qfirehose -f ./`

If you use an ARMHF distro (confirm with `uname -m`), run:

`sudo ./qfirehose_armhf -f ./`

Once it finishes, it will reboot the modem and after about 30 seconds you should be back up and running!

It should be noted that qfirehose often fails flashing. In this event, you can try re-running qfirehose. However, you may also need to reboot the modem by either rebooting the PinePhone, or toggling the modem killswitch and running `sudo systemctl restart eg25-manager`.
## Quirks
It has been noted that there can be issues running qfirehose on certain distributions. If qfirehose fails repeatedly, try to stop ModemManager before attempting the update:
* If using systemd based distros (Mobian, Manjaro, Arch...): 
  
  `sudo systemctl stop ModemManager && sudo ./qfirehose -f . && sudo systemctl start ModemManager`
* If using openrc based distros (postmarketOS for example): 
  
  `sudo rc-service modemmanager stop && sudo ./qfirehose -f ./ && sudo rc-service modemmanager start`

If you are still unable to flash it, [Mobian](https://mobian-project.org/) and [postmarketOS](http://postmarketos.org/download/) have been tested to work without issues
