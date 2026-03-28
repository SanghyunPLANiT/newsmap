#!/bin/bash
# Double-click this file to launch Global Pulse in your browser.

DIR="$(cd "$(dirname "$0")" && pwd)"
PORT=8080

# Kill anything already on that port
lsof -ti tcp:$PORT | xargs kill -9 2>/dev/null

# Start the HTTP server in the background
cd "$DIR"
python3 -m http.server $PORT &>/dev/null &
SERVER_PID=$!

# Wait a moment then open browser
sleep 0.8
open "http://localhost:$PORT/index.html"

echo "Global Pulse running at http://localhost:$PORT"
echo "Press Ctrl-C to stop."
wait $SERVER_PID
