#!/bin/bash
cp config.yml.template config.yml

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

echo 'alias forker="cd ~/forker/; bin/f"' >> ~/.bashrc
echo 'alias forker_log="cd ~/forker/; tail -f forker_log"' >> ~/.bashrc

source ~/.bashrc

echo "Type 'forker' for beginning"
