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

echo "Setting up zroot"
echo "zpool create -f -O mountpoint=none -O atime=off -o ashift=12 -O acltype=posixacl -O xattr=sa -O compression=zstd -O dnodesize=auto -O normalization=formD zroot /dev/sda3"
echo ""
execute_command "zpool create -f -O mountpoint=none -O atime=off -o ashift=12 -O acltype=posixacl -O xattr=sa -O compression=zstd -O dnodesize=auto -O normalization=formD zroot /dev/sda3"
echo "zfs create -o refreservation=1G -o mountpoint=none zroot/reserved"
execute_command "zfs create -o refreservation=1G -o mountpoint=none zroot/reserved"
echo ""
echo "Create some datasets inside the zroot pool"
echo "zfs create -p -o mountpoint=legacy zroot/local/root"
execute_command "zfs create -p -o mountpoint=legacy zroot/local/root"
echo "Creating a snapshot while it is totally blank"
echo "zfs snapshot zroot/local/root@blank"
execute_command "zfs snapshot zroot/local/root@blank"
echo "zfs create -p -o mountpoint=legacy zroot/local/nix"
execute_command "zfs create -p -o mountpoint=legacy zroot/local/nix"
echo "zfs create -p -o mountpoint=legacy zroot/safe/home"
execute_command "zfs create -p -o mountpoint=legacy zroot/safe/home"
echo "zfs create -p -o mountpoint=legacy zroot/safe/persist"
execute_command  "zfs create -p -o mountpoint=legacy zroot/safe/persist"

