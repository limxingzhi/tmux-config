#!/bin/bash

# Script to renumber TMux sessions in sequential order

sessions=$(tmux list-sessions -F '#S' | grep '^[0-9]\+$' | sort -n)

new=1 # Start numbering at 0 or 1, based on your preference
for old in $sessions; do
    if [ "$old" -ne "$new" ]; then
        # Check if the target session name already exists to avoid conflicts
        if ! tmux has-session -t $new 2>/dev/null; then
            tmux rename-session -t $old $new
        fi
    fi
    new=$((new+1))
done

