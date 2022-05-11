#!/usr/bin/env bash

echo "installing KOTS application"

APP="navidrome-lemming"

curl -LO https://k8s.kurl.sh/$APP 
mv $APP $APP.sh
chmod 744 $APP.sh

sudo su
/bin/bash -x ./$APP.sh > /tmp/install.txt
