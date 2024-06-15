#!/bin/bash

# Get the current tmux session name
CURRENT_SESSION_NAME=$(tmux display-message -p '#S')

# Construct the new session name with "scratch-" prefix
NEW_SESSION_NAME="scratch-${CURRENT_SESSION_NAME}"

# Check if the new session exists
tmux has-session -t "${NEW_SESSION_NAME}" 2>/dev/null

if [ $? != 0 ]; then
  # The session does not exist, create it
  tmux new-session -d -s "${NEW_SESSION_NAME}"
fi

# Open the new session in a tmux popup
tmux display-popup -E -h 90% -w 80% "tmux attach-session -t ${NEW_SESSION_NAME}"

