#!/bin/bash
clear

echo "I'm starting the EES Upgrade Now"
git stash
git pull https://github.com/SteffanPerry/FunPass.git master
chown apache.root ./ -R
chmod 755 ./ -R
rake tmp:cache:clear
rake tmp:sockets:clear
rake tmp:pids:clear
rake tmp:sessions:clear
touch tmp/restart.txt

echo "Ok EES Has Been Upgraded"