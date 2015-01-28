source ./antigen/antigen.zsh

# Load oh-my-zsh library:
antigen use oh-my-zsh

# Bundle from default repo:
antigen bundle git

#antigen bundle zsh-users/git-flow
antigen bundle zsh-users/mvn
antigen bundle zsh-users/docker
antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme robbyrussell

antigen apply
