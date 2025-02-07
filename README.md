# What?

Basically just a clone of some of the important stuff from my `~/.config` folder. To use you just need to clone this directly into your .config and most of it should almost work.

Also, I decided to copy my configuration.nix into here for funzies, plus a cute little github hook at `.git/hooks/pre-commit` that copies a file and stuff. I dunno, thought it was fun.

# Install guide

Wait, you really wanna install this? Sure I guess...

First clone the repo into your `~/.config` directory
```
cd
git clone https://github.com/python151/nix-dotfiles.git .config
```

Then copy all the files that are stored elsewhere
```
sudo cp configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
cp .zshrc ~/.zshrc
```
