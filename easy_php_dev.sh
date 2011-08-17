#!/bin/bash

hash brew 2>&- || { echo >&2 "Homebrew neds to be installed, get it from https://github.com/mxcl/homebrew/wiki/installation"; exit 1; }
  
install () {
  ########################
  # dnsmasq

  if [ -e /usr/local/sbin/dnsmasq ]; then
    echo "- dnsmasq is already installed, skipping install"
  else
    echo "- Installing dnsmasq via homebrew"
    brew install dnsmasq > /dev/null 2>&1
  fi

  echo "- Creating dnsmasq config in /usr/local/etc/dnsmasq.conf"
  echo "(When prompted please enter your sudo password so we can create the configs)"
  sudo echo "" > /usr/local/etc/dnsmasq.conf
  sudo echo "address=/.dev/127.0.0.1" >> /usr/local/etc/dnsmasq.conf
  sudo echo "port=4253" >> /usr/local/etc/dnsmasq.conf
  sudo echo "local=/local/" >> /usr/local/etc/dnsmasq.conf
  sudo echo "no-resolv" >> /usr/local/etc/dnsmasq.conf
  sudo echo "no-negcache" >> /usr/local/etc/dnsmasq.conf

  echo "- Setting up dnsmasq to start at boot"
  sudo cp /usr/local/Cellar/dnsmasq/2.55/uk.org.thekelleys.dnsmasq.plist ~/Library/LaunchAgents/
  sudo launchctl unload -w ~/Library/LaunchAgents/uk.org.thekelleys.dnsmasq.plist > /dev/null 2>&1
  sudo launchctl load -w ~/Library/LaunchAgents/uk.org.thekelleys.dnsmasq.plist > /dev/null 2>&1

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
  echo "port 4253" | sudo tee -a /etc/resolver/dev > /dev/null 2>&1
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
  sudo launchctl unload -w ~/Library/LaunchAgents/uk.org.thekelleys.dnsmasq.plist > /dev/null 2>&1
  
  echo "- Removing dynamic virtual host config /etc/apache2/other/${USER}_hosts.conf"
  sudo rm /etc/apache2/other/${USER}_hosts.conf > /dev/null 2>&1
  
  echo "- Disabing PHP"
  sudo rm /etc/apache2/other/load_php.conf > /dev/null 2>&1
  
  echo "- Restarting Apache"
  sudo apachectl restart
  
  echo "- Uninstalling dnsmasq"
  brew uninstall dnsmasq > /dev/null 2>&1
  
  echo "- Removing dnsmasq config /usr/local/etc/dnsmasq.conf"
  sudo rm /usr/local/etc/dnsmasq.conf > /dev/null 2>&1
  
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