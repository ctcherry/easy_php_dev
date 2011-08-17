#!/bin/bash

DOWNLOAD=`curl -s https://raw.github.com/ctcherry/easy_php_dev/master/download.sh`
$DOWNLOAD > /dev/null 2>&1
~/.easy_php_dev/control.sh enable