#!/bin/bash

# Description :
#   This script is used to start, kill, or restart tmux sessions for the PX development workflow.

# Usage :
#   to start work sessions   : ./tmux.px.sh start   or ./tmux.px.sh s
#   to cleanup work sessions : ./tmux.px.sh kill    or ./tmux.px.sh k
#   to restart work sessions : ./tmux.px.sh restart or ./tmux.px.sh r


# Set the path to the repo you want to work on
cd_to_repo=cdx
cd_to_repo_mocks=cdxm

# Function to create a tmux session for "work"
start_work_sessions() {
    echo "Starting sessions..."

    # Start main session and run neovim
    session_name="px"
    tmux has-session -t $session_name 2>/dev/null
    if [ $? != 0 ];
    then
        tmux new-session -d -s $session_name
        tmux send-keys -t $session_name:1 "$cd_to_repo;nvim" C-m

        tmux new-window -t $session_name
        tmux send-keys -t $session_name:2 "$cd_to_repo;cd ../;nvim work-notes.md" C-m
    else 
        echo "session:$session_name already exist"
    fi

    # Start scratch-work session
    session_name="scratch-px"
    tmux has-session -t $session_name 2>/dev/null
    if [ $? != 0 ];
    then
        # Create the session and the first window and run lazygit
        tmux new-session -d -s $session_name
        tmux send-keys -t "$session_name:1" "$cd_to_repo;lazygit" C-m
        
        # Create the second window with 2 panes
        tmux new-window -t $session_name
        tmux split-window -h -t "$session_name:2"
        
        # Setup commands for the second window's panes to run the dev project and its mocks
        tmux send-keys -t "$session_name:2.0" "$cd_to_repo;npm run start" C-m
        tmux send-keys -t "$session_name:2.1" "$cd_to_repo_mocks;npm run start" C-m
    else
        echo "session:$session_name already exist"
    fi

    echo "Sessions started. Switching tmux session to px..."

    # Switch or attach to the main session
    if [ $TMUX ];
    then tmux switch -t px
    else tmux attach -t px
    fi
}

kill_work_sessions() {
    echo "Closing sessions..."
    tmux kill-session -t px
    tmux kill-session -t scratch-px
    echo "Sessions closed"
}

# Main script logic based on command line argument
case "$1" in
    r|restart)
        kill_work_sessions
        echo ""
        start_work_sessions
        ;;
    s|start)
        start_work_sessions
        ;;
    k|kill)
        kill_work_sessions
        ;;
    *)
        echo ""
        echo "Invalid input. Please use one of the following options:"
        echo ""
        echo "   start or s   : start the PX workflow"
        echo "   kill or k    : kill the PX workflow"
        echo "   restart or r : kill and then start the PX workflow"
        echo ""
        exit 1
        ;;
esac

