easy_php_dev
============

Quickly setup a dynamic multi-site PHP/Apache development environment on OSX.

Requirements
------------

- OSX (Tested on Snow Leopard 10.6 and Lion 10.7)
- Perl (should already be installed on OSX)
- Bash (definitely already installed on OSX)

Install
-------

One-liner:

`$ bash < <(curl -s https://raw.github.com/ctcherry/easy_php_dev/master/install.sh)`

This script will download the latest code, install it into ~/.easy_php_dev and then run the `enable` command described in the Usage section below. Feel free to view the [install.sh](https://github.com/ctcherry/easy_php_dev/blob/master/install.sh) and [download.sh](https://github.com/ctcherry/easy_php_dev/blob/master/download.sh) scripts first to make sure they are safe.

Usage
-----

After you have run the installer above, you are good to go, the system is already enabled. In your home directory a new folder has been created: `~/EasyPhpDev/sites`. Inside of there you simply create a folder for each of the sites you want to work on, ending with a with a .dev domain (mysite.dev, or mysite.com.dev), and it becomes your document root. If you navigate to it in a browser on your local machine (http://mysite.dev) it will be immediately available.

Additionally, `~/EasyPhpDev/phplib` has been added to the PHP include_path so you can put any shared libraries in there. And `short_open_tag` is enabled.

Commands
--------

Enable dynamic environment and .dev domains:

`$ ~/.easy_php_dev/control.sh enable`

Disable dynamic environment and .dev domains:

`$ ~/.easy_php_dev/control.sh disable`

Set force mode. When enabled, all local web requests, no matter what domain or IP is used will resolve to the specified site. This is useful for viewing your dev site in VMs and from other computers:

`$ ~/.easy_php_dev/control.sh force domain.dev`

Disable force mode. This returns the environment to its normal state:

`$ ~/.easy_php_dev/control.sh force off`

Disable and uninstall everything (if you run this command you will have to reinstall):

`$ ~/.easy_php_dev/control.sh uninstall`