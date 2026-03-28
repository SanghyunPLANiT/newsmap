#!/bin/bash
cd "$(dirname "$0")"
PORT=8080
PROXY_PORT=8081
# Kill anything already on those ports
lsof -ti tcp:$PORT | xargs kill -9 2>/dev/null
lsof -ti tcp:$PROXY_PORT | xargs kill -9 2>/dev/null
# Start local CORS proxy for Google News
python3 proxy.py $PROXY_PORT &
PROXY_PID=$!
# Start HTTP server
python3 -m http.server $PORT &
SERVER_PID=$!
sleep 0.5
open "http://localhost:$PORT"
echo ""
echo "  GLOBAL PULSE running at http://localhost:$PORT"
echo "  Local proxy running at http://localhost:$PROXY_PORT"
echo "  Press Ctrl-C to stop."
echo ""
trap "kill $SERVER_PID $PROXY_PID 2>/dev/null" EXIT
wait $SERVER_PID
