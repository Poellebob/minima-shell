# ---------------------------
# Components
# ---------------------------
source ~/.zsh-defer/zsh-defer.plugin.zsh

# ---------------------------
# Aliases
# ---------------------------
alias newtexdoc = git clone https://github.com/Poellebob/latex-template.git 

# ---------------------------
# Environment
# ---------------------------

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

export PATH=~/.npm-global/bin:$PATH

zsh-defer source /usr/share/nvm/init-nvm.sh

# ---------------------------
# Start Fetch
# ---------------------------
afetch

# ---------------------------
# Powerlevel10k Instant Prompt
# ---------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------------------------
# Oh My Zsh
# ---------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git themes)

source $ZSH/oh-my-zsh.sh

# ---------------------------
# Powerlevel10k Config
# ---------------------------
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
