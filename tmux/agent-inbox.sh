#!/bin/sh
# agent-inbox.sh — prioritetssortert agent-oversikt på tvers av sesjoner.
# Modi: (default) fzf-popup via prefix+a | --list sortert rådata | --preview <window_id>
# Spec: docs/superpowers/specs/2026-07-09-agent-inbox-design.md
# NB: farge/prioritet MÅ holdes i synk med window-status-format i status.conf.
TAB=$(printf '\t')

# Rader: prio ⇥ sortsince ⇥ window_id ⇥ state ⇥ rawsince ⇥ session ⇥ index ⇥ navn
# Ugyldig/fremtidig since → 99999999999 (sist). Display-felt saniteres (kontrolltegn).
collect() {
  now=$(date +%s)
  tmux list-windows -a -F "#{window_id}${TAB}#{@agent_state}${TAB}#{@agent_state_since}${TAB}#{session_name}${TAB}#{window_index}${TAB}#{window_name}" 2>/dev/null |
  awk -F '\t' -v OFS='\t' -v now="$now" '
    $2 == "" { next }
    {
      prio = 5
      if ($2 == "error")        prio = 0
      else if ($2 == "waiting") prio = 1
      else if ($2 == "stale")   prio = 2
      else if ($2 == "running") prio = 3
      else if ($2 == "done")    prio = 4
      sortsince = $3
      if (sortsince !~ /^[0-9]+$/ || sortsince + 0 > now) sortsince = 99999999999
      name = $6
      for (i = 7; i <= NF; i++) name = name " " $i   # tab i vindusnavn → flatt ut
      gsub(/[[:cntrl:]]/, "", $4)
      gsub(/[[:cntrl:]]/, "", name)
      print prio, sortsince, $1, $2, $3, $4, $5, name
    }' | sort -t "$TAB" -k1,1n -k2,2n -k6,6 -k7,7n
}

# fzf-linjer: window_id ⇥ farget display. Farger = Mocha-hex fra status.conf.
render() {
  now=$(date +%s)
  awk -F '\t' -v now="$now" '
    {
      state = $4; rawsince = $5
      color = "\033[38;2;108;112;134m"; icon = "·"          # overlay_0 (stale/ukjent)
      if (state == "error")        { color = "\033[38;2;243;139;168m"; icon = "✖" }
      else if (state == "waiting") { color = "\033[38;2;249;226;175m"; icon = "⏸" }
      else if (state == "running") { color = "\033[38;2;166;227;161m"; icon = "▶" }
      else if (state == "done")    { color = "\033[38;2;148;226;213m"; icon = "✔" }
      age = ""
      if (state == "waiting" || state == "stale" || state == "running") {
        if (rawsince ~ /^[0-9]+$/ && rawsince + 0 <= now) {
          s = now - rawsince
          if (s >= 3600)     age = sprintf(" %dh%02dm", s / 3600, (s % 3600) / 60)
          else if (s >= 60)  age = sprintf(" %dm", s / 60)
          else               age = sprintf(" %ds", s)
        } else age = " ?"
      }
      printf "%s\t%s%s %-7s\033[0m %s:%s %s%s%s\033[0m\n", \
        $3, color, icon, state, $6, $7, $8, color, age
    }'
}

case "$1" in
  --list)
    collect
    exit 0
    ;;
  --preview)
    win="$2"
    [ -n "$win" ] || exit 0
    pane=$(tmux show-options -w -t "$win" -v @agent_pane 2>/dev/null)
    target="$win"
    if [ -n "$pane" ] && tmux display-message -p -t "$pane" '' >/dev/null 2>&1; then
      target="$pane"
    fi
    tmux capture-pane -e -p -t "$target" 2>/dev/null | tail -40
    exit 0
    ;;
esac

# Interaktiv modus (default) — kjøres via bind a run-shell.
[ -n "$TMUX" ] || exit 0
command -v fzf-tmux >/dev/null 2>&1 || { tmux display-message "inbox: fzf-tmux mangler i PATH"; exit 0; }

rows=$(collect)
[ -n "$rows" ] || { tmux display-message "inbox: ingen agentvinduer"; exit 0; }

sel=$(printf '%s\n' "$rows" | render | fzf-tmux -p 80%,70% \
  --ansi --no-sort --delimiter "$TAB" --with-nth 2 --prompt 'inbox ' \
  --preview "$HOME/.config/tmux/agent-inbox.sh --preview {1}" \
  --preview-window 'right,60%')
[ -n "$sel" ] || exit 0
win=${sel%%"$TAB"*}

sess=$(tmux display-message -p -t "$win" '#{session_name}' 2>/dev/null)
if [ -z "$sess" ]; then
  tmux display-message "inbox: vinduet finnes ikke lenger"
  exit 0
fi
tmux select-window -t "$win" 2>/dev/null || { tmux display-message "inbox: vinduet finnes ikke lenger"; exit 0; }
tmux switch-client -t "$sess" 2>/dev/null || true

# Betinget ack: kun done/error kvitteres ut; running/waiting røres aldri.
# (Ingen ekte CAS i tmux — ms-restrisiko akseptert i spec.)
cur=$(tmux show-options -w -t "$win" -v @agent_state 2>/dev/null)
case "$cur" in
  done|error)
    tmux set-option -wu -t "$win" @agent_state ';' set-option -wu -t "$win" @agent_state_since 2>/dev/null || true
    ;;
esac
exit 0
