#!/bin/sh

execute_command() {
    # Function to execute a command, collect output, and detect errors
    
    # $1 is the command to execute
    command="$1"
    
    # Execute the command, redirect stderr to stdout, and capture both in a variable
    output=$(eval "$command" 2>&1)
    
    # Capture the exit status of the command
    exit_status=$?
    
    # Check if the command executed successfully (exit status 0)
    if [ $exit_status -eq 0 ]; then
        echo "Command executed successfully."
        echo "CMD_OUTPUT:"
        echo "$output"
        echo "ENDCMD_OUTPUT:"
    else
        echo "Command failed with exit status: $exit_status"
        echo "ERROR_OUTPUT:"
        echo "$output"
        echo "END_ERROR_OUTPUT:"
    fi
    
    # Return the exit status of the command
    return $exit_status
}
###########Begin Main body##########

echo "Turn on Swap"
echo "swapon /dev/sda2"
execute_command "swapon /dev/sda2"

echo "mount -t zfs zroot/local/root /mnt"
execute_command "mount -t zfs zroot/local/root /mnt"

echo "Mount the ESP partition to boot"
execute_command "mkdir /mnt/boot"
execute_command "mount /dev/sda1 /mnt/boot"

execute_command "mkdir /mnt/nix"
echo "mount -t zfs zroot/local/nix /mnt/nix"
execute_command "mount -t zfs zroot/local/nix /mnt/nix"

execute_command "mkdir /mnt/home"
echo "mount -t zfs zroot/safe/home /mnt/home"
execute_command "mount -t zfs zroot/safe/home /mnt/home"

execute_command "mkdir /mnt/persist"
echo "mount -t zfs zroot/safe/persist /mnt/persist"
execute_command "mount -t zfs zroot/safe/persist /mnt/persist"

