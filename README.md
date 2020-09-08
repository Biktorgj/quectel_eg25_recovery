# Firmware restore for Quectel EG25G

## Howto recover the Quectel EG25 Modem inside the Pinephone
Use this repository to recover your Pinephone's Modem to a stock state.
For this you will either need:
- ADB Access to the modem, to be able to reboot into edl mode by running `adb reboot edl` (Please, refer to megi's instructions at https://xnux.eu/devices/feature/modem-pp.html#toc-unlock-adb-access on how to unlock ADB mode)
- Access to the test points in the Pinephone board:
![Pinephone Mainboard](https://raw.githubusercontent.com/Biktorgj/quectel_eg25_recovery/master/board.jpg)
You will need to fully shutdown the pinephone and start it with the test points shorted at least until you hear the camera clicking noise

To check if you're currently booted in EDL mode, run `lsusb` and inspect the output. You should see the following device listed:
`Bus 003 Device 003: ID 05c6:9008 Qualcomm, Inc. Gobi Wireless Modem (QDL mode)`

Once in EDL mode, open a terminal and go to the root directory of this repository, and run:

If you use an ARM64 distro (most likely)
./qfirehose_arm64 -f ./

If you use an ARMHF (32 bit) distro:
./qfirehose_armhf -f ./

After it finishes, it will reboot the modem and after about 30 seconds it will get back up and running 

