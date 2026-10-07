#!/bin/sh
# agent-state.sh — sett per-vindu @agent_state for tmux-glance.
# Kalles fra Claude Code-hooks. Idempotent, feil-safe, no-op utenfor tmux.
# Bruk: agent-state.sh <running|waiting|done|error|stale>
LOG="$HOME/.cache/tmux-agent-state.log"
state="$1"
[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0
case "$state" in running|waiting|done|error|stale) ;; *) exit 0 ;; esac
win=$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>>"$LOG") || exit 0
[ -n "$win" ] || exit 0
now=$(date +%s)
tmux set-option -w -t "$win" @agent_state "$state" 2>>"$LOG" || exit 0
tmux set-option -w -t "$win" @agent_pane "$TMUX_PANE" 2>>"$LOG" || true
case "$state" in
  running|waiting) tmux set-option -w -t "$win" @agent_state_since "$now" 2>>"$LOG" || true ;;
esac
printf '%s win=%s state=%s\n' "$now" "$win" "$state" >> "$LOG" 2>/dev/null || true
exit 0
