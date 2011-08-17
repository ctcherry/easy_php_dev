#!/bin/bash

curl -o /tmp/download_easy_php_dev.sh https://raw.github.com/ctcherry/easy_php_dev/master/download.sh > /dev/null 2>&1
. /tmp/download_easy_php_dev.sh > /dev/null 2>&1
~/.easy_php_dev/control.sh enable
rm /tmp/download_easy_php_dev.sh