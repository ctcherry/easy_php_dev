easy_php_dev
============

This script sets up a PHP/Apache development environment on OSX.

In your home directory a `DevSites` folder will be created. Inside of there you simply create a folder for each of the sites you want to work on, ending with a with a .dev domain (mysite.dev, or mysite.com.dev), and it becomes your document root. If you navigate to it in a browser on your local machine (http://mysite.dev) it will be immediately available.

Requirements
------------

- OSX (Tested on Snow Leopard 10.6 and Lion 10.7)
- Perl (should already be installed on OSX)
- Bash (definitely already installed on OSX)

Install
-------

One-liner:

`$ bash < <(curl -s https://raw.github.com/ctcherry/easy_php_dev/master/install.sh)`

This script will download the latest code, install it into ~/.easy_php_dev and then enable it.

Usage
-----

After you have run the installer above, you are good to go, the system is already enabled. Create a folder for your site in ~/DevSites and check it out in a browser, and get to work!

Enable dynamic environment and .dev domains:

`$ ~/.easy_php_dev/control.sh enable`

Disable dynamic environment and .dev domains:

`$ ~/.easy_php_dev/control.sh disable`

Disable and uninstall everything (if you run this command you will have to reinstall):

`$ ~/.easy_php_dev/control.sh uninstall`