# Felles for alle maskiner. ~/.zshrc på hver maskin leser denne med source (ikke lenke: ${0:a:h}
# er bare stien hit når fila source-es), og har bare det som er maskinspesifikt.
DOTFILES=${0:a:h}

[[ -d ${PWD:A} ]] || cd ~

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if (( $+commands[nvim] )); then export EDITOR=nvim; else export EDITOR=vim; fi
export VISUAL=$EDITOR

source $DOTFILES/.antigen/antigen.zsh

# Bundle from default repo:
antigen bundle git

antigen bundle git-flow
antigen bundle mvn
antigen bundle docker

export NVM_NO_USE=true
antigen bundle lukechilds/zsh-nvm

antigen bundle zsh-users/zsh-syntax-highlighting

#antigen theme robbyrussell
#antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship
#antigen theme agnoster
antigen theme romkatv/powerlevel10k

antigen apply

# aliases
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias myip="curl http://ipecho.net/plain; echo"

alias clauda='claude --enable-auto-mode --permission-mode auto'
alias claudy="claude --dangerously-skip-permissions"
alias claudx="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true && claude"
alias rezsh='exec zsh'

# Modulær init i eksplisitt rekkefølge (00→10→20→30): felles i zsh/, maskinens egne (hemmeligheter)
# i ~/.config/zsh/conf.d
for _f in $DOTFILES/zsh/[0-9]*.zsh(N) ~/.config/zsh/conf.d/[0-9]*.zsh(N); do source "$_f"; done
unset _f

# ~/.p10k.zsh er en lenke til .p10k.zsh her, eller maskinens egen (Mac-en)
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completions
(( $+commands[ng] )) && source <(ng completion script)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
if [ -f "$HOME/.local/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/.local/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/.local/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/.local/google-cloud-sdk/completion.zsh.inc"
fi

# NTM - Named Tmux Manager
(( $+commands[ntm] )) && eval "$(ntm shell zsh)"

# dcg: warn if hook was silently removed from Claude Code settings
if command -v dcg &>/dev/null && command -v jq &>/dev/null; then
  if [ -f "$HOME/.claude/settings.json" ] &&      ! jq -e '.hooks.PreToolUse[]? | select(.hooks[]?.command | test("dcg$"))'        "$HOME/.claude/settings.json" &>/dev/null; then
    printf '\033[1;33m[dcg] Hook missing from ~/.claude/settings.json — run: dcg install\033[0m\n'
  fi
fi
