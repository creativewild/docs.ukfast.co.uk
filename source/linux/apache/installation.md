# Installation/Configuration of Apache


## Install Apache

First things first, your server may not even have apache installed on it.

Install the latest version with yum, like so:

`yum install httpd`

```eval_rst
.. note::
   As with all centos/redhat packages, 'latest' usually won't mean the current stable version that could be found on the project website, but rather than latest package provided by centos/redhat.

   These typically include backported security patches, see the page on PCI for further information. :doc:`/linux/misc/pci`
```

Most people will want their webserver to start on boot, use chkconfig to make it so:

`chkconfig httpd on`

## Configure Virtual Hosts

Virtual Hosts are apaches way of pointing different sites to different directories whilst still allowing them to share the same IP. If you're familiar with IIS parlance, then they'd be called bindings.

All config files ending in `.conf` in the `/etc/httpd/conf.d` directory will be parsed as apache configuration files at the end of the main `/etc/httpd/conf/httpd.conf` file.

The following content, if added to a file called `/etc/httpd/conf.d/vhosts.conf` will enable multiple Virtual Hosts on one IP and then set up two sites, one called firstdomain.com and the other called seconddomain.org.

```apacheconf
   NameVirtualHost *:80

   <VirtualHost *:80>
        ServerName firstdomain.com
        ServerAlias www.firstdomain.com
        DocumentRoot /var/www/vhosts/firstdomain.com/public_html/
        ErrorLog /var/www/vhosts/firstdomain.com/logs/error.log
        CustomLog /var/www/vhosts/firstdomain.com/logs/access.log combined
   </VirtualHost>

   <VirtualHost *:80>
        ServerName seconddomain.org
        ServerAlias www.seconddomain.org
        DocumentRoot /var/www/vhosts/seconddomain.org/public_html/
        ErrorLog /var/www/vhosts/seconddomain.org/logs/error.log
        CustomLog /var/www/vhosts/seconddomain.org/logs/access.log combined
   </VirtualHost>
```

The paths involved in that config likely don't exist, so you'll need to create them with the mkdir command.

```console

   mkdir -p  /var/www/vhosts/firstdomain.com/public_html
   mkdir -p  /var/www/vhosts/firstdomain.com/logs
   mkdir -p  /var/www/vhosts/seconddomain.org/public_html
   mkdir -p  /var/www/vhosts/seconddomain.org/logs
```

You'll also want to create the log files that you specified:

```console

   touch /var/www/vhosts/firstdomain.com/logs/error.log /var/www/vhosts/firstdomain.com/logs/access.log /var/www/vhosts/seconddomain.org/logs/error.log /var/www/vhosts/seconddomain.org/logs/access.log
```

With a standard setup like this, the files will need to be owned by the apache user and group:

`chown -R  apache:apache /var/www/vhosts/firstdomain.com /var/www/vhosts/seconddomain.org`

You're nearly good to go, the only thing you need now is some content. The apache directive `DirectoryIndex` specifies which file is used as the default index file in a directory, and by default this will be `index.html` or `index.htm`

By that logic, if you create a file in `/var/www/vhosts/firstdomain.com/public_html/` called `index.html` with some content, then that's what will display on `www.firstdomain.com`

```eval_rst
.. note::
   Don't forget to chown any website files to apache:apache as well
```

### Start it all up

All that remains now is to test your apache configuration and then start the webserver up.

Testing can be done with the command `httpd -t` and if all is well, it should spit out the following message:

`Syntax OK`

To start apache, the following command can be used:

`service httpd start`

Or if it's already running, you can restart it:

`service httpd restart`

### Going forward

Most sites now need more that just basic html, often using php to generate their dynamic content and some kind of database to store information.

The following documents carry on the setup for those particular elements:

[PHP Installation](/linux/php/installation.html)

[MySQL Installation](/linux/mysql/installation.html)
