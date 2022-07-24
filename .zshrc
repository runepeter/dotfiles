# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ${0:a:h}/.antigen/antigen.zsh

# Load oh-my-zsh library:
antigen use oh-my-zsh

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# aliases
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias myip="curl http://ipecho.net/plain; echo"
