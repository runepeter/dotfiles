source ${0:a:h}/.antigen/antigen.zsh

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
