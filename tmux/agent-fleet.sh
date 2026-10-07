#!/bin/sh
# Fleet-oversikt: teller @agent_state på tvers av ALLE sesjoner → modultekst.
# Side-effekt: setter @fleet_worst (error|waiting|ok) som modulfargen leser.
# Kjøres som #() i status-right hvert status-interval.
run=0; wtg=0; err=0; fin=0; stl=0
for s in $(tmux list-windows -a -F '#{@agent_state}' 2>/dev/null); do
  case "$s" in
    running) run=$((run+1));;
    waiting) wtg=$((wtg+1));;
    error)   err=$((err+1));;
    "done")  fin=$((fin+1));;
    stale)   stl=$((stl+1));;
  esac
done
if [ "$err" -gt 0 ]; then worst=error
elif [ "$wtg" -gt 0 ]; then worst=waiting
else worst=ok
fi
tmux set -g @fleet_worst "$worst" 2>/dev/null || true
out=""
[ "$run" -gt 0 ] && out="${out}▶${run} "
[ "$stl" -gt 0 ] && out="${out}·${stl} "
[ "$wtg" -gt 0 ] && out="${out}⏸${wtg} "
[ "$err" -gt 0 ] && out="${out}✖${err} "
[ "$fin" -gt 0 ] && out="${out}✔${fin} "
[ -n "$out" ] || out="idle "
printf '%s' "${out% }"
