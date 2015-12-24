#!/bin/bash
# if you understand this script, then you should install next things manually:
# - ruby and phantomjs
# - bundler for install all necessary gems
# - after all add gems path to $PATH for using bundle and install gems
# - copy config.yml.example to config.yml and change config.yml as you want
# - bin/f - is executable file

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

gem install bundler

cp config.yml.template config.yml

echo 'export PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin' >> ~/.bashrc
echo 'alias forker="cd ~/forker/; bin/f"' >> ~/.bashrc
echo 'alias forker_log="cd ~/forker/; tail -f forker_log"' >> ~/.bashrc

exec bash
bundle install

echo "If you see that gems are not installed, you should install them(nokogiri, capybara, poltergeist, mechanize) manually, and after run 'bundle install'. NOT RUN THIS SCRIPT ANYMORE."
echo "Change forker/config.yml and type 'forker' for beginning"
