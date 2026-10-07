#!/bin/sh
# Resolve agent name: $AGENT_NAME > worktree dir name > fallback
path="$1"
if [ -n "$AGENT_NAME" ]; then
  echo "$AGENT_NAME"
elif echo "$path" | grep -q '/worktrees/'; then
  echo "$path" | sed 's|.*/worktrees/[^/]*/||' | cut -d/ -f1
else
  echo "-"
fi
