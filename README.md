
# Some notes
* This is a basic LEMP stack w/ Chef 11 that assumes a key exchange has occured already. Once it completes, your ssh server will not accept password authentication and restart to enable the new configuration.
* Intended for Ubuntu 12.04 LTS only. I'll probably continue to use this repository personally until 5/14 when I replace it with Ubuntu 14.04 LTS.
* Intended as a single VM test environment
* This is available under the MIT license. http://opensource.org/licenses/MIT
	* In other words, I make no guarentees of any kind...it is "AS IS" and you do as you like with it.

# Installation
* git clone git@github.com:opendais/ubuntu-12.04-chef-solo-bootstrap.git
* cd ubuntu-12.04-chef-solo-bootstrap
* change install.sh to match your target ip/hostname
* ./install.sh
