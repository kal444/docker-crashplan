#!/bin/bash

set -e

# SIGTERM-handler
term_handler() {
  # Stop crashplan
  /etc/init.d/crashplan stop
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'kill "$tail_pid"; term_handler' INT QUIT KILL TERM

/etc/init.d/crashplan start

LOGS_FILES="/data/log/service.log.0"
for file in $LOGS_FILES; do
  [[ ! -f "$file" ]] && touch $file
done

Xvfb :1 -screen 0 1024x768x24 -ac -bs -pn -dpi 100 &
DISPLAY=:1 /usr/local/crashplan/bin/CrashPlanDesktop
DISPLAY=:1 x11vnc  -bg -forever -desktop CrashPlan -listen 0.0.0.0 -rfbport 5900 -rfbwait 30000 -passwd crashplan

tail -n0 -F $LOGS_FILES &
tail_pid=$!

# wait "indefinitely"
while [[ -e /proc/$tail_pid ]]; do
  wait $tail_pid # Wait for any signals or end of execution of tail
done

# Stop container properly
term_handler
