#!/bin/bash

EASY_PHP_DEV_ROOT="/Users/$USER/.easy_php_dev"
EASY_PHP_DEV_CFG="/Users/$USER/.easy_php_dev_rc"

RESOLVER_TLD="dev"

USER_AP_FORCE_CFG="/etc/apache2/other/${USER}_zforce.conf"
USER_AP_CFG="/etc/apache2/other/${USER}_hosts.conf"
USER_LAGENT_ROOT="/Users/$USER/Library/LaunchAgents"
LOAD_PHP_CFG="/etc/apache2/other/load_php.conf"

DNS_BIN_PATH="$EASY_PHP_DEV_ROOT/bin/easy_php_dev_dns"

DNS_PLIST_SRC="$EASY_PHP_DEV_ROOT/lib/ctcherry.easy_php_dev_dns.plist"
DNS_PLIST_DEST="$USER_LAGENT_ROOT/ctcherry.easy_php_dev_dns.plist"

SITE_ROOT="/Users/$USER/EasyPhpDev/sites"
PHP_LIB="/Users/$USER/EasyPhpDev/phplib"

TEST_DOMAIN="test.$RESOLVER_TLD"

RESOLVER_ORDER=$[ ( $RANDOM % 100 )  + 100 ]
RESOLVER_ROOT="/etc/resolver"
TMP_RESOLVER="/tmp/resolver_$RESOLVER_TLD"
RESOLVER_DEST="$RESOLVER_ROOT/$RESOLVER_TLD"

HOME_URL="https://github.com/ctcherry/easy_php_dev"

enable () {

  if [ -e $EASY_PHP_DEV_CFG ]; then
    PORT=`cat $EASY_PHP_DEV_CFG`
    echo "- Loaded existing port number ($PORT) from $EASY_PHP_DEV_CFG"
  else
    PORT=$[ ( $RANDOM % 10000 )  + 10000 ]
    echo $PORT > $EASY_PHP_DEV_CFG
    echo "- Saved port number ($PORT) to $EASY_PHP_DEV_CFG"
  fi

  echo "- Setting up easy_php_dev_dns to start at boot"
  mkdir -p $USER_LAGENT_ROOT
  cp -f $DNS_PLIST_SRC $USER_LAGENT_ROOT/ > /dev/null 2>&1
  
  sed -i '' "s,_BIN_PATH_,$DNS_BIN_PATH,g" $DNS_PLIST_DEST > /dev/null 2>&1
  sed -i '' "s,_PORT_,$PORT,g" $DNS_PLIST_DEST > /dev/null 2>&1
  
  launchctl unload -w $DNS_PLIST_DEST > /dev/null 2>&1
  launchctl load -w $DNS_PLIST_DEST > /dev/null 2>&1

  ########################
  # Apache

  # Enable PHP by uncommenting it
  echo "- Enabing PHP"
  echo "(If prompted, please enter your sudo password so we can install)"
  echo "<IfModule !php5_module>" | sudo tee $LOAD_PHP_CFG > /dev/null 2>&1
  echo "LoadModule php5_module     libexec/apache2/libphp5.so" | sudo tee -a $LOAD_PHP_CFG > /dev/null 2>&1
  echo "php_value include_path \".:$PHP_LIB\"" | sudo tee -a $LOAD_PHP_CFG > /dev/null 2>&1
  echo "php_flag short_open_tag on" | sudo tee -a $LOAD_PHP_CFG > /dev/null 2>&1
  echo "</IfModule>" | sudo tee -a $LOAD_PHP_CFG > /dev/null 2>&1

  # Setup vhost_alias for dynamic Virtual Hosts
  echo "- Setting up dynamic VirtualHosts in $SITE_ROOT/ (config: $USER_AP_CFG)"
  mkdir -p $SITE_ROOT > /dev/null 2>&1
  mkdir -p $PHP_LIB > /dev/null 2>&1
  echo "UseCanonicalName Off" | sudo tee $USER_AP_CFG > /dev/null 2>&1
  echo "VirtualDocumentRoot $SITE_ROOT/%0" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1
  echo "<Directory \"$SITE_ROOT/\">" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1
  echo "    Options ExecCGI Indexes FollowSymLinks MultiViews" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1
  echo "    AllowOverride All" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1
  echo "    Order allow,deny" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1
  echo "    Allow from all" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1
  echo "</Directory>" | sudo tee -a $USER_AP_CFG > /dev/null 2>&1

  # Start Apache
  echo "- Restarting Apache"
  sudo apachectl restart

  ########################
  # resolver system

  echo "- Setting up .dev resolver in $RESOLVER_DEST"

  sudo mkdir -p $RESOLVER_ROOT > /dev/null 2>&1
  
  rm $TMP_RESOLVER > /dev/null 2>&1
  
  echo "nameserver 127.0.0.1" | tee $TMP_RESOLVER > /dev/null 2>&1
  echo "port $PORT" | tee -a $TMP_RESOLVER > /dev/null 2>&1
  echo "order $RESOLVER_ORDER" | tee -a $TMP_RESOLVER > /dev/null 2>&1
  echo "timeout 1" | tee -a $TMP_RESOLVER > /dev/null 2>&1
  
  sudo mv $TMP_RESOLVER $RESOLVER_DEST > /dev/null 2>&1
  
  echo "- Creating test site $TEST_DOMAIN"
  mkdir $SITE_ROOT/$TEST_DOMAIN > /dev/null 2>&1
  echo "<?php phpinfo(); ?>" > $SITE_ROOT/$TEST_DOMAIN/index.php
}

disable() {
  echo "- Removing .$RESOLVER_TLD resolver $RESOLVER_DEST"
  echo "(If prompted, please enter your sudo password so we can uninstall)"
  sudo rm $RESOLVER_DEST > /dev/null 2>&1
  
  echo "- Stopping easy_php_dns, and preventing from starting at boot"
  launchctl unload -w $DNS_PLIST_DEST > /dev/null 2>&1
  
  echo "- Removing dynamic virtual host config $USER_AP_CFG"
  sudo rm $USER_AP_CFG > /dev/null 2>&1
  
  echo "- Removing force virtual host config $USER_AP_FORCE_CFG"
  sudo rm $USER_AP_FORCE_CFG > /dev/null 2>&1
  
  echo "- Disabing PHP"
  sudo rm $LOAD_PHP_CFG > /dev/null 2>&1
  
  echo "- Restarting Apache"
  sudo apachectl restart
}

uninstall() {
  echo "- Removing $DNS_PLIST_DEST"
  rm $DNS_PLIST_DEST > /dev/null 2>&1
  echo "- Removing $EASY_PHP_DEV_ROOT"
  rm -Rf $EASY_PHP_DEV_ROOT > /dev/null 2>&1
  echo "- Removing $EASY_PHP_DEV_CFG"
  rm $EASY_PHP_DEV_CFG > /dev/null 2>&1
}

set_ip_vhost() {
  local domain=$1
  if [ -e $SITE_ROOT/$domain ]; then
    echo "(If prompted, please enter your sudo password so we can configure)"
    echo "VirtualDocumentRootIP $SITE_ROOT/$domain" | sudo tee $USER_AP_FORCE_CFG > /dev/null 2>&1
    sudo apachectl restart
    echo "Force site mode enabled. All web requests (using any domain or IP) to this computer will resolve to $domain"
  else
    echo "$domain does not exist, Force mode not set"
  fi
}

unset_ip_vhost() {
  echo "(If prompted, please enter your sudo password so we can configure)"
  sudo rm $USER_AP_FORCE_CFG > /dev/null 2>&1
  sudo apachectl restart
  echo "Force site mode disabled"
}

if [ "$1" == "enable" ]; then
  enable
  echo "Done, easy_php_dev enabled. Go to http://$TEST_DOMAIN to verify installation"
  exit 0
fi

if [ "$1" == "force" ]; then
  if [ "$2" == "" ]; then
    echo "Usage: control.sh force [domain.dev|off]"
    exit 0
  fi
  
  if [ "$2" == "off" ]; then
    unset_ip_vhost
    exit 0
  fi
  
  set_ip_vhost $2
  exit 0
fi

if [ "$1" == "disable" ]; then
  disable
  echo "Done, easy_php_dev disabled. Your development sites remain in $SITE_ROOT/"
  exit 0
fi

if [ "$1" == "uninstall" ]; then
  disable
  uninstall
  echo "Done, easy_php_dev is uninstalled. Your development sites remain in $SITE_ROOT/"
  echo "If you would like to use it again please reinstall from $HOME_URL"
  exit 0
fi

# This is really only meant to be used while developing this package
if [ "$1" == "dev_reset" ]; then
  if [ -e $EASY_PHP_DEV_ROOT ]; then
    disable
    uninstall
  fi
  CURRENT_DIR="$( cd -P "$( dirname "$0" )" && pwd )"
  cp -R $CURRENT_DIR $EASY_PHP_DEV_ROOT > /dev/null 2>&1
  chmod +x $EASY_PHP_DEV_ROOT/control.sh
  exec ~/.easy_php_dev/control.sh enable
fi

echo "Usage: control.sh [enable|disable|force|uninstall]"
exit 0