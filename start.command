#!/bin/bash
cd "$(dirname "$0")"
PORT=8080
# Kill anything already on that port
lsof -ti tcp:$PORT | xargs kill -9 2>/dev/null
# Start server in background
python3 -m http.server $PORT &
SERVER_PID=$!
sleep 0.5
open "http://localhost:$PORT"
# Keep terminal open so server stays alive; Ctrl-C to stop
echo ""
echo "  GLOBALPULSE running at http://localhost:$PORT"
echo "  Press Ctrl-C to stop."
echo ""
wait $SERVER_PID
