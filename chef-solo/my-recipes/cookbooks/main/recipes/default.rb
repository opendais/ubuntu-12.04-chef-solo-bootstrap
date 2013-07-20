# Designed for Ubuntu 12.04 LTS

#################################################
# WARNING:
# DO NOT EXPOSE TO INTERNET!!!!!!!!!!!!!!!!!!!!!!
# Replace SSL cert, keys, etc first.
#################################################

# public ip - grabs the first address in /etc/network/interfaces - probably bad but ohai doesn't work reliably for me so f it. Not worth sorting out.
public_ip=`grep "addr" /etc/network/interfaces | sed -e 's/^[ ]*address //g'`

group "www" do
  action :create
end

user "www" do
  gid "www"
  home "/var/www"
  system true
  shell "/bin/false"
end


include_recipe "openssl" 		#https://github.com/opscode-cookbooks/openssl
include_recipe "apt"			#https://github.com/opscode-cookbooks/apt && cd apt && git checkout 1.7.0
include_recipe "git"			#https://github.com/opscode-cookbooks/git
include_recipe "redis-server"		#https://github.com/teamsnap/redis-server

# debconf
bash "debconf" do
  user "root"
  cwd "/tmp"
  code <<-EOH
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant'
  EOH
end

# install packages
#execute "debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant'"
#execute "debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant'"
package "mysql-server-5.5"
package "nginx"
package "php5-cli"
package "php5-fpm"
package "php5-mysqlnd"
package "php5-pspell"
package "php5-enchant"
package "php-xml-parser"
package "php5-gd"
package "php5-geoip"
package "python-setuptools"

# update
execute "apt-get update && apt-get upgrade -y"

# install customizations
package "vim"
package "nmap"
package "zsh"


###
# begin security hole block
# If this was a real production environment, replace a publicly avaiable version of oh-my-zsh with something local and specific to be scp'd over or installed via chef. DO NOT INCLUDE THINGS FROM REMOTE URLS DIRECTLY LIKE THIS DOES!!!!!!!!!!!!!!!!!!!!!!!!
# Also, disable automatic updates if you use oh-my-zsh

# install as root
execute "git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
execute "cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc"
execute "chsh -s /bin/zsh"

# NOTE: This is a base recipe for a vagrant install for local development, not intended for production. As such, vagrant is present. If you need to disable this, comment out below:
# install as vagrant
#execute "git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh"
#execute "cp ~/.oh-my-zsh/templates/zshrc.zsh-template /home/vagrant/.zshrc"
#execute "chsh -s /bin/zsh vagrant"

# end security hole block
# #


# setup htdocs
execute "rm /etc/nginx/sites-enabled/default"
execute "mkdir -p /var/www/dev.local/htdocs"
execute "echo '<?php phpinfo(); ?>' > /var/www/dev.local/htdocs/index.php"

###############
# Harden Box  #
###############
package "ufw"

# install firewall, enable ssh & http ports
execute "ufw allow 12345" # ufw allow ssh, adjusted for ourt port # change
execute "ufw allow http"
execute "ufw allow https"
execute "ufw status verbose" # to show you the end result of the firewall configuration
execute "ufw --force enable"

# chef doesn't dump useful output :/ bah
#execute "nmap -v -sT localhost" # independently confirm firewall
#execute "nmap -v -sT "+public_ip
#execute "nmap -v -sS localhost"
#execute "nmap -v -sS "+public_ip

# secure fstab
execute "echo 'tmpfs     /dev/shm     tmpfs     defaults,noexec,nosuid     0     0' >> /etc/fstab"

#denyhosts - because you shouldn't be using ftp and such anyway
package "denyhosts"

# automatically install security updates
package "unattended-upgrades"

# install tiger 'cause y'know, tiger. RAWR
package "tiger"

# setup the configuration files

# unattended-upgrades
cookbook_file "/etc/apt/apt.conf.d/10periodic" do
        source "etc/unattended-upgrades"
        mode 0644
        owner "root"
        group "root"
end

# denyhosts 
cookbook_file "/etc/denyhosts.conf" do
        source "etc/denyhosts.conf"
        mode 0644
        owner "root"
        group "root"
end


# be sure to read: http://wiki.nginx.org/Pitfalls
# this is the www directory in the vagrant root folder
cookbook_file "/etc/nginx/sites-available/dev.local" do
        source "nginx/dev.local"
        mode 0644
        owner "root"
        group "root"
end

execute "ln -s /etc/nginx/sites-available/dev.local /etc/nginx/sites-enabled/dev.local" #symlink as per the debian standard methodology

# change sysctl to more secure defaults & reload
cookbook_file "/etc/sysctl.conf" do
        source "etc/sysctl.conf"
        mode 0644
        owner "root"
        group "root"
end

execute "sysctl -p"

# update hosts
cookbook_file "/etc/hosts" do
        source "etc/hosts"
        mode 0644
        owner "root"
        group "root"
end

# update sshd 
cookbook_file "/etc/ssh/sshd_config" do
        source "etc/sshd_config"
        mode 0644
        owner "root"
        group "root"
end


#php5 config
remote_directory "/etc/php5" do
	source "php5"
	mode 0644
	owner "root"
	group "root"
end


# NOTE: This SSL is insecure. It is distributed through git for testing purposes for a development repository. Replace with a real certificate later. - insecure SSL key vagrant
remote_directory "/etc/ssl" do
        source "ssl"
        mode 0644
        owner "root"
        group "root"
end


#run this last
#restart services to confirm everything was reloaded
execute "service nginx restart"
execute "service php5-fpm restart"
execute "service mysql restart"
execute "service denyhosts restart"
execute "service ssh restart"
