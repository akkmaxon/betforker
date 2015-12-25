#!/bin/bash
# - Installing this terrible app in your Manjaro Linux system.

ruby -v 2>/dev/null

if [ "$?" != 0 ]; then
    sudo pacman -S --noconfirm ruby
    if [ "$?" != 0 ]; then
	echo "Use Manjaro Linux, please, or install ruby manually"
	exit 1
    else
	echo "Ok, we installed ruby"
    fi
fi

phantomjs -v 2>/dev/null

if [ "$?" != 0 ]; then
    sudo pacman -S --noconfirm phantomjs
    if [ "$?" != 0 ]; then
	echo "Use Manjaro Linux, please, or install phantomjs manually"
	exit 1
    else
	echo "Ok, we installed phantomjs"
    fi
fi

bundle --version 2>/dev/null

if [ "$?" != 0 ]; then
    gem install bundler
    if [ "$?" != 0 ]; then
	echo "You should install bundle gem manually"
	exit 1
    else
	echo "Ok, we installed bundler"
    fi
fi

export PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin
bundle install
if [ "$?" != 0 ]; then
  echo "Some gems are not installed. Try to understand what happened and retype ./install.sh"
fi

cp config.yml.template config.yml
echo 'export PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin' >> ~/.bashrc
echo 'alias forker="cd ~/forker/; bin/f"' >> ~/.bashrc
echo 'alias forker_log="cd ~/forker/; tail -f forker_log"' >> ~/.bashrc

echo "Installation completed. Change forker/config.yml and type 'forker' for beginning"
exec bash
