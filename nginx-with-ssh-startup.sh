#! /bin/bash
rm /etc/nginx/sites-available/default
cp /default /etc/nginx/sites-available/default
/usr/sbin/nginx
/usr/sbin/sshd -D
