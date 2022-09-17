#!/bin/bash
#
# $ sudo usermod -aG disk,storage mikl
#
_the_icon="/home/mikl/programs/flashdrive-png.png"
SYSTEM=$(uname -s)
VERSION=$(uname -r)
ARCHI=$(uname -m)
usb_name=""
for i in /dev/disk/by-path/*usb* ; do
	if [[ $i != *part* ]]; then
		devpoint=$(readlink -f $i | cut -d '/' -f3-9)
		usb_name="${usb_name} $devpoint"
	fi
done
name_usb=( $usb_name )
unset usb_name
for i in ${name_usb[*]}; do
	m_point=$(lsblk -o NAME,MOUNTPOINT | grep -Ei "$i" | grep -Ei "run|media|mnt|/" | grep -Ei "/" | awk '{print $2,$3,$4,$5}' | sed -r 's/^ *| *$//g' | tr ' ' '_')
	if [[ ${m_point[*]} != "" ]]; then
		usb_size=$(lsblk -o NAME,SIZE | grep -Ei "^$i" | awk '{print $2}' | tr ' ' '_')
		usb_name=$(lsblk -o NAME,MOUNTPOINT | grep -Ei "$i" | grep -Ei "run|media|mnt|/" | rev | cut -d '/' -f1 | rev | tr ' ' '_')
		usb_model=$(lsblk -o  NAME,MODEL | grep -Ei "^$i" | awk '{print $2}' | tr ' ' '_')
		if [[ ${usb_model[*]} != "" ]]; then
			usb_info="${usb_size[*]}_${usb_name[*]}_${usb_model[*]}"
		else
			usb_info="${usb_size[*]}_${usb_name[*]}"
		fi	
		dev_usb=$(lsblk -ro  NAME,MOUNTPOINT | grep -Ei "$i" | grep -Ei "run|media|mnt" | awk '{print $1}' | sed -r 's/^ *| *$//g')
		menu_usb_dev="${menu_usb_dev} ${dev_usb[*]} $usb_info"
	fi
done
wait
declare -a dev_menu_usb
wait
dev_menu_usb=( $menu_usb_dev )
wait
unset menu_usb_dev
wait
if [[ "${dev_menu_usb[*]}" != "" ]]; then
	variables=$(zenity --title="звлечение флешек" --text="\nМеню выбора флешки для извлечения\n" --width=256 --height=256 --list --column="Device" --column="Info"  "${dev_menu_usb[@]}")
	if [[ "${variables[*]}" != "" ]]; then
		udisksctl unmount --block-device /dev/"${variables[*]}"
		wait
		udisksctl power-off --block-device /dev/"${variables[*]}"
		wait
		notify-send --urgency normal --expire-time=10000 -i "$_the_icon" "Извлечение USB устройства." "Ваше USB устройство <b>/dev/${variables}</b> может быть извлечено!"
	fi
fi
exit 0
