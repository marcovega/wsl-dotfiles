#!/usr/bin/env zsh

sudo apt update && sudo apt install -y \
  apt-transport-https \
  unzip \
  ca-certificates \
  curl \
  software-properties-common \
  git \
  make \
  tig \
  tree \
  stow \
  zsh

# install oh-my-zsh (non-interactive)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# install fnm
curl -fsSL https://fnm.vercel.app/install | bash

# inject fnm to .zshrc if missing
FNM_BLOCK='export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"'
grep -q 'fnm env' ~/.zshrc || echo "$FNM_BLOCK" >> ~/.zshrc

# install zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# install powerlevel10k
[[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# stow dotfiles
for dir in *(/); do
  [[ $dir =~ ^(vscode|windows)$ ]] && continue

  if read -q "choice?do you want to symlink $dir using stow? (y/n) "; then
    stow -v -t ~/ -S $dir
    echo " - $dir installed."
  else
    echo " - skipping $dir."
  fi
done

NEWLINE=$'\n'

# vscode ext install
if read -q "choice?${NEWLINE}do you want to install the visual studio code extensions listed below?${NEWLINE}$(cat vscode/extensions.linux)?${NEWLINE}(y/n): "; then
  echo $NEWLINE

  cat vscode/extensions.linux | while read extension || [[ -n $extension ]]; do
    code --install-extension $extension --force
  done
else
  echo " skipping."
fi
