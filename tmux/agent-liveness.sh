#!/bin/sh
# Nedgrader vinduer som henger i 'running' uten ny aktivitet > terskel → 'stale'.
# Kun 'running' rammes; 'waiting' er en legitim hviletilstand.
# Echoer tom streng (egnet som status-interval #()-sidekjør).
STALE_AFTER=${AGENT_STALE_AFTER:-90}
now=$(date +%s)
tmux list-windows -a -F '#{window_id} #{@agent_state} #{@agent_state_since}' 2>/dev/null | \
while read -r win state since; do
  [ "$state" = "running" ] || continue
  [ -n "$since" ] || continue
  [ $((now - since)) -ge "$STALE_AFTER" ] || continue
  tmux set-option -w -t "$win" @agent_state stale 2>/dev/null || true
done
printf ''
