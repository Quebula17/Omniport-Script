#!/bin/bash

FRONTEND_PATH="$HOME/Desktop/omniport-docker/codebase/omniport-frontend"
BACKEND_PATH="$HOME/Desktop/omniport-docker/codebase/omniport-backend"
BACKEND_PORT=60000
FRONTEND_PORT=61000

# Function to check if a port is in use
is_port_in_use() {
  lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null
}

# Function to stop a server
stop_server() {
  tmux send-keys -t omniport:$1 C-c
}

# Function to start a server
start_server() {
  tmux send-keys -t omniport:$1 "$2" C-m
  echo "$3"
}

if [ "$1" == "delete" ]; then
  if tmux has-session -t omniport 2>/dev/null; then
    stop_server 0.0
    stop_server 0.1
    sleep 2
    tmux kill-session -t omniport
    echo "Omniport has shut down successfully"
  else
    echo "No such tmux session found"
  fi
  exit 0
fi

if ! tmux has-session -t omniport 2>/dev/null; then
  tmux new-session -d -s omniport -c "$BACKEND_PATH"
  tmux split-window -t omniport -h -c "$FRONTEND_PATH"
fi

if is_port_in_use $BACKEND_PORT; then
  echo "Backend server is already running"
else
  start_server 0.0 './scripts/start/django.sh' "Starting backend server..."
  sleep 5
fi

if is_port_in_use $FRONTEND_PORT; then
  echo -e "Frontend server is already running\n"
else
  echo "Starting frontend server..."
  start_server 0.1 'sudo ./scripts/start/react.sh -d 60000'
  sleep 10
fi

echo -e "You can access:\n1. Omniport Backend: http://localhost:$BACKEND_PORT\n2. Omniport Frontend: http://localhost:$FRONTEND_PORT"
