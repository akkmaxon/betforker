#!/bin/bash

echo 'alias forker="cd ~/forker/; bin/f"' >> ~/.bashrc
echo 'alias forker_log="cd ~/forker/; tail -f forker_log"' >> ~/.bashrc
cp config.yml.template config.yml
source ~/.bashrc

ruby -v

if [ "$?" != 0 ]; then
    sudo pacman -S ruby
    if [ "$?" != 0 ]; then
	echo "Use Arch Linux, please, or install ruby manually"
	exit 1
    else
	echo "Ok, we installed ruby"
    fi
fi

phantomjs -v

if [ "$?" != 0 ]; then
    sudo pacman -S phantomjs
    if [ "$?" != 0 ]; then
	echo "Use Arch Linux, please, or install phantomjs manually"
	exit 1
    else
	echo "Ok, we installed phantomjs"
    fi
fi

gem install nokogiri capybara poltergeist mechanize

echo "We are ready!"

forker
if [ "$?" != 0 ]; then
    echo "Close terminal and open it again"
fi
