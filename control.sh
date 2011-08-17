#!/bin/bash
 
enable () {

  if [ -e ~/.easy_php_dev_rc ]; then
    PORT=`cat ~/.easy_php_dev_rc`
    echo "- Loaded existing port number ($PORT) from ~/.easy_php_dev_rc"
  else
    PORT=$[ ( $RANDOM % 10000 )  + 10000 ]
    echo $PORT > ~/.easy_php_dev_rc
    echo "- Saved port number ($PORT) to ~/.easy_php_dev_rc"
  fi

  echo "- Setting up easy_php_dev_dns to start at boot"
  cp -f ~/.easy_php_dev/lib/ctcherry.easy_php_dev_dns.plist ~/Library/LaunchAgents/ > /dev/null 2>&1
  
  BIN_PATH="/Users/$USER/.easy_php_dev/bin/easy_php_dev_dns"
  
  sed -i '' "s,_BIN_PATH_,$BIN_PATH,g" ~/Library/LaunchAgents/ctcherry.easy_php_dev_dns.plist > /dev/null 2>&1
  sed -i '' "s,_PORT_,$PORT,g" ~/Library/LaunchAgents/ctcherry.easy_php_dev_dns.plist > /dev/null 2>&1
  
  launchctl unload -w ~/Library/LaunchAgents/ctcherry.easy_php_dev_dns.plist > /dev/null 2>&1
  launchctl load -w ~/Library/LaunchAgents/ctcherry.easy_php_dev_dns.plist > /dev/null 2>&1

  ########################
  # Apache

  # Enable PHP by uncommenting it
  echo "- Enabing PHP"
  echo "(When prompted please enter your sudo password so we can install)"
  echo "<IfModule !php5_module>" | sudo tee /etc/apache2/other/load_php.conf > /dev/null 2>&1
  echo "LoadModule php5_module     libexec/apache2/libphp5.so" | sudo tee -a /etc/apache2/other/load_php.conf > /dev/null 2>&1
  echo "</IfModule>" | sudo tee -a /etc/apache2/other/load_php.conf > /dev/null 2>&1

  # Setup vhost_alias for dynamic Virtual Hosts
  echo "- Setting up dynamic VirtualHosts in /Users/$USER/DevSites/ (config: /etc/apache2/other/${USER}_hosts.conf)"
  mkdir /Users/$USER/DevSites/ > /dev/null 2>&1
  echo "UseCanonicalName Off" | sudo tee /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "VirtualDocumentRoot /Users/$USER/DevSites/%0" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "<Directory \"/Users/$USER/DevSites/\">" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "    Options Indexes FollowSymLinks MultiViews" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "    AllowOverride All" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "    Order allow,deny" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "    Allow from all" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "</Directory>" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1

  # Start Apache
  echo "- Restarting Apache"
  sudo apachectl restart

  ########################
  # resolver system

  echo "- Setting up .dev resolver in /etc/resolver/dev"

  sudo mkdir /etc/resolver > /dev/null 2>&1
  
  RESOLVER_ORDER=$[ ( $RANDOM % 100 )  + 100 ]
  
  rm /tmp/resolver_dev > /dev/null 2>&1
  
  echo "nameserver 127.0.0.1" | tee /tmp/resolver_dev > /dev/null 2>&1
  echo "port $PORT" | tee -a /tmp/resolver_dev > /dev/null 2>&1
  echo "order $RESOLVER_ORDER" | tee -a /tmp/resolver_dev > /dev/null 2>&1
  echo "timeout 1" | tee -a /tmp/resolver_dev > /dev/null 2>&1
  
  sudo mv /tmp/resolver_dev /etc/resolver/dev > /dev/null 2>&1
  
  echo "- Creating test site test.dev"
  mkdir /Users/$USER/DevSites/test.dev > /dev/null 2>&1
  echo "<?php phpinfo(); ?>" > /Users/$USER/DevSites/test.dev/index.php
}

disable() {
  echo "- Removing .dev resolver /etc/resolver/dev"
  echo "(When prompted please enter your sudo password so we can uninstall)"
  sudo rm /etc/resolver/dev > /dev/null 2>&1
  
  echo "- Stopping easy_php_dns, and preventing from starting at boot"
  launchctl unload -w ~/Library/LaunchAgents/ctcherry.easy_php_dev_dns.plist > /dev/null 2>&1
  
  echo "- Removing dynamic virtual host config /etc/apache2/other/${USER}_hosts.conf"
  sudo rm /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  
  echo "- Disabing PHP"
  sudo rm /etc/apache2/other/load_php.conf > /dev/null 2>&1
  
  echo "- Restarting Apache"
  sudo apachectl restart
}

uninstall() {
  echo "- Removing ~/Library/LaunchAgents/ctcherry.easy_php_dns.plist"
  rm -Rf ~/Library/LaunchAgents/ctcherry.easy_php_dev_dns.plist > /dev/null 2>&1
  echo "- Removing ~/.easy_php_dev"
  rm -Rf ~/.easy_php_dev > /dev/null 2>&1
  echo "- Removing ~/.easy_php_dev_rc"
  rm -Rf ~/.easy_php_dev_rc > /dev/null 2>&1
}


if [ "$1" == "enable" ]; then
  enable
  echo "Done, easy_php_dev enabled. Go to http://test.dev to verify installation"
  exit 0
fi

if [ "$1" == "disable" ]; then
  disable
  echo "Done, easy_php_dev disabled. Your development sites remain in /Users/$USER/DevSites/"
  exit 0
fi

if [ "$1" == "uninstall" ]; then
  disable
  uninstall
  echo "Done, easy_php_dev is uninstalled. Your development sites remain in /Users/$USER/DevSites/"
  echo "If you would like to use it again please reinstall from https://github.com/ctcherry/easy_php_dev"
  exit 0
fi

echo "Usage: ~/.easy_php_dev/control.sh [enable|disable|uninstall]"
exit 0