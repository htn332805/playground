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

echo "Turn off Swap"
execute_command " "
execute_command "rm -rvf /mnt/nix/*"
execute_command "rm -rvf /mnt/home/*"
execute_command "rm -rvf /mnt/persist/*"
execute_command "rm -rvf /mnt/lib"
execute_command "rm -rvf /mnt/bin"
execute_command "rm -rvf /mnt/usr"
execute_command "rm -rvf /mnt/root"
execute_command "rm -rvf /mnt/srv"
execute_command "rm -rvf /mnt/tmp"
execute_command "rm -rvf /mnt/var"
execute_command "rm -rvf /mnt/run"

