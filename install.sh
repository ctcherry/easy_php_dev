#!/bin/bash
 
install () {

  if [ ! -e ~/.easy_php_dev_rc ]; then
    PORT=$[ ( $RANDOM % 10000 )  + 10000 ]
    echo $PORT > ~/.easy_php_dev_rc
    echo "- Saved port number ($PORT) to ~/.easy_php_dev_rc"
  else
    PORT=`cat ~/.easy_php_dev_rc`
    echo "- Loaded existing port number ($PORT) from ~/.easy_php_dev_rc"
  fi

  echo "- Setting up easy_php_dev_dns to start at boot"
  echo "(When prompted please enter your sudo password so we can install)"
  cp -f ~/.easy_php_dev/lib/ctcherry.easy_php_dns.plist ~/Library/LaunchAgents/ > /dev/null 2>&1
  
  BIN_PATH="/Users/$USER/.easy_php_dev/bin/easy_php_dev_dns"
  
  sed -i '' "s,_BIN_PATH_,$BIN_PATH,g" ~/Library/LaunchAgents/ctcherry.easy_php_dns.plist > /dev/null 2>&1
  sed -i '' "s,_PORT_,$PORT,g" ~/Library/LaunchAgents/ctcherry.easy_php_dns.plist > /dev/null 2>&1
  
  launchctl unload -w ~/Library/LaunchAgents/ctcherry.easy_php_dns.plist > /dev/null 2>&1
  launchctl load -w ~/Library/LaunchAgents/ctcherry.easy_php_dns.plist > /dev/null 2>&1

  ########################
  # Apache

  # Enable PHP by uncommenting it
  echo "- Enabing PHP"
  echo "<IfModule !php5_module>" | sudo tee /etc/apache2/other/load_php.conf > /dev/null 2>&1
  echo "LoadModule php5_module     libexec/apache2/libphp5.so" | sudo tee -a /etc/apache2/other/load_php.conf > /dev/null 2>&1
  echo "</IfModule>" | sudo tee -a /etc/apache2/other/load_php.conf > /dev/null 2>&1

  # Setup vhost_alias for dynamic Virtual Hosts
  echo "- Setting up dynamic VirtualHosts in /Users/$USER/DevSites/ (config: /etc/apache2/other/${USER}_hosts.conf)"
  mkdir /Users/$USER/DevSites/ > /dev/null 2>&1
  echo "UseCanonicalName Off" | sudo tee /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "VirtualDocumentRoot /Users/$USER/DevSites/%0" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "<Directory \"/Users/$USER/DevSites/\">" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  echo "    Options Indexes MultiViews" | sudo tee -a /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
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
  
  echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/dev > /dev/null 2>&1
  echo "port $PORT" | sudo tee -a /etc/resolver/dev > /dev/null 2>&1
  echo "order 100" | sudo tee -a /etc/resolver/dev > /dev/null 2>&1
  echo "timeout 2" | sudo tee -a /etc/resolver/dev > /dev/null 2>&1
  
  # This part is kinda strange, OSX doesnt pickup the fact that the
  # file was put there, unless we wait, and then touch it
  sleep 2
  sudo touch /etc/resolver/dev
  
  echo "- Creating test site phpdevtest.dev"
  mkdir /Users/$USER/DevSites/phpdevtest.dev > /dev/null 2>&1
  echo "<?php phpinfo(); ?>" > /Users/$USER/DevSites/phpdevtest.dev/index.php
  
  echo "Done. Go to http://phpdevtest.dev to verify installation"
  
}

uninstall() {
  echo "- Removing .dev resolver /etc/resolver/dev"
  echo "(When prompted please enter your sudo password so we can uninstall)"
  sudo rm /etc/resolver/dev > /dev/null 2>&1
  
  echo "- Stopping dnsmasq, and preventing from starting at boot"
  launchctl unload -w ~/Library/LaunchAgents/ctcherry.easy_php_dns.plist > /dev/null 2>&1
  
  echo "- Removing dynamic virtual host config /etc/apache2/other/${USER}_hosts.conf"
  sudo rm /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  
  echo "- Disabing PHP"
  sudo rm /etc/apache2/other/load_php.conf > /dev/null 2>&1
  
  echo "- Restarting Apache"
  sudo apachectl restart
  
  echo "Done. Your development sites remain in /Users/$USER/DevSites/"
}


if [ "$1" == "install" ]; then
  install
  exit 0
fi

if [ "$1" == "uninstall" ]; then
  uninstall
  exit 0
fi

# Default action
install
exit 0