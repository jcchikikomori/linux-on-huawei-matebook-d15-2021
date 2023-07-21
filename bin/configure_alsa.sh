#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo:"
  echo "sudo $0"
  exit 1
fi

# Prompt the user to choose a configuration
echo "Choose a configuration option:"
echo "1. Default laptop audio with HDMI disabled (current audio kernel bug since 6.1+)"
echo "2. Only HDMI audio (disable laptop audio completely)"
read -p "Enter the number of your choice: " choice

# Validate the user's choice
case "$choice" in
  1)
    config_options="options snd-hda-intel model=alc255-acer,dell-headset-multi"
    ;;
  2)
    config_options="options snd-hda-intel dmic_detect=0"
    ;;
  *)
    echo "Invalid choice. Please choose either 1 or 2."
    exit 1
    ;;
esac

# Path to the alsa-base.conf file
alsa_base_conf="/etc/modprobe.d/alsa-base.conf"

# Backup the original alsa-base.conf file if it exists
if [ -f "$alsa_base_conf" ]; then
  backup_file="$alsa_base_conf.bak"
  echo "Backing up the original $alsa_base_conf to $backup_file"
  cp "$alsa_base_conf" "$backup_file"
fi

# Write the configuration options to the alsa-base.conf file
echo "Writing configuration options to $alsa_base_conf"
echo "$config_options" > "$alsa_base_conf"

# Reload the relevant kernel module to apply the changes
if [ "$choice" -eq 1 ]; then
  echo "Reloading snd-hda-intel module to apply the changes..."
  sudo modprobe -r snd-hda-intel
  sudo modprobe snd-hda-intel
elif [ "$choice" -eq 2 ]; then
  echo "Reloading snd-hda-intel module with dmic_detect=0 to apply the changes..."
  sudo modprobe -r snd-hda-intel
  sudo modprobe snd-hda-intel dmic_detect=0
fi

echo "Configuration completed."

# Prompt the user for a reboot
read -p "A reboot is required to apply the changes. Would you like to reboot now? (y/n): " reboot_choice

if [ "$reboot_choice" == "y" ] || [ "$reboot_choice" == "Y" ]; then
  echo "Rebooting..."
  sudo reboot
else
  echo "Please remember to reboot your system to apply the changes."
fi
