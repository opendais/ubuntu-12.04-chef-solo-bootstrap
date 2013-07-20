#!/usr/bin/env bash
# Ubuntu 12.04 LTS - Bootstrap default, install better text editor, nmap, and chef-solo :P
# Refer to bootstrap-chef.sh for what is installed with chef as part of the bootstrapping process.
# Requires: you to already be in the root directory of this repository, the ssh key to already be deployed to the target server && bootstrap-chef.sh which will be copied to the target then executed.
# Chef-Repo: chef-solo.rb needs to define the cookbook_path and such [~/$chef_repo/my-recipes/cookbooks is my usual]. chef-solo.json should hold the usual

# NOTE THIS WILL DELETE THE EXISTING KEY AND RE-ADD

# CUSTOMIZE THIS BEFORE RUNNING!!!!!
# SSH
ip="192.168.33.10" #dev.local vagrant
ssh_pre="-o StrictHostKeyChecking=no root@"
ssh_add=$ssh_pre$ssh
ssh="root@$ip"

#Chef
chef_binary="/usr/local/bin/chef-solo"
install_flag="~/completed-install"
chef_repo="chef-solo"
log="debug"

# END CUSTOMIZE SECTION
ssh-keygen -f ~/.ssh/known_hosts -R $ip
ssh-keyscan -H $ip >> ~/.ssh/known_hosts

# check if the install has already been completed on the target, if so, abort.
if ssh "$ssh" "test -f $install_flag"; then
        echo "Chef run is already completed ref:"
        echo "ssh \"$ssh\" \"ls $install_flag\""
	echo "If you wish to override, please run the following command:"
	echo "ssh \"$ssh\" \"rm $install_flag\""
	exit 2
fi


# install if the remote server does not have chef installed
if ! ssh "$ssh" "test -f $chef_binary"; then
	scp "./bootstrap-chef.sh" "$ssh:~/"
	ssh "$ssh" "~/bootstrap-chef.sh"
else
	echo "Chef is already installed ref:"
	echo "ssh \"$ssh\" \"ls $chef_binary\""
fi

# copy the ./chef directory with your install instructions and execute them.
ssh "$ssh" "rm -rf ~/$chef_repo"
scp -r "./$chef_repo" "$ssh:~/"
ssh "$ssh" "$chef_binary -l $log" -c "~/$chef_repo/chef-solo.rb" -j "~/$chef_repo/chef-solo.json" > ./install.log
echo "$chef_binary" -c "~/$chef_repo/chef-solo.rb" -j "~/$chef_repo/chef-solo.json"

# completed flag
ssh "$ssh" "touch $install_flag"
echo "To login to the new VM:"
echo "ssh root@$ip -p 12345"
