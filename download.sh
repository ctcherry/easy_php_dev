#!/bin/bash

curl -o /tmp/easy_php_dev.tar.gz -L https://github.com/ctcherry/easy_php_dev/tarball/master > /dev/null 2>&1

TAR_DIR_NAME=`tar -tf /tmp/easy_php_dev.tar.gz | head -n 1 | sed "s,\(ctcherry[^/]*\).*,\1,"`

if [ "$TAR_DIR_NAME" == "" ]; then
  echo "There was a problem with the download"
  exit 1
fi

# Cleanup extraction destination incase its already there
rm -Rf /tmp/$TAR_DIR_NAME > /dev/null 2>&1

# Extract download
tar -zxf /tmp/easy_php_dev.tar.gz > /dev/null 2>&1

# Cleanup existing installed location
rm -Rf ~/.easy_php_dev > /dev/null 2>&1

# Move extracted folder to final location
mv /tmp/$TAR_DIR_NAME ~/.easy_php_dev > /dev/null 2>&1

# Cleanup downloaded tar.gz
rm -Rf /tmp/easy_php_dev.tar.gz > /dev/null 2>&1

echo "easy_php_dev has been downloaded into ~/.easy_php_dev"
echo "To enable: ~/.easy_php_dev/control.sh enable"
exit 0
