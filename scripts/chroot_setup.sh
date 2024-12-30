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
execute_command "echo Begin"
execute_command "mount -o bind /dev /mnt/dev" 
execute_command "mount -o bind /proc /mnt/proc" 
execute_command "mount -o bind /sys /mnt/sys"
execute_command " "
execute_command "chroot /mnt /nix/var/nix/profiles/system/activate"
execute_command "chroot /mnt /run/current-system/sw/bin/bash"


