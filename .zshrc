source .antigen/antigen.zsh

# Load oh-my-zsh library:
antigen use oh-my-zsh

# Bundle from default repo:
antigen bundle git

antigen bundle git-flow
antigen bundle mvn
antigen bundle docker

antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme robbyrussell

antigen apply
