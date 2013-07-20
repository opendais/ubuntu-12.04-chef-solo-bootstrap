# redis-server cookbook

This cookbook installs and configures redis.

This cookbook was written for TeamSnap's particular requirements. If you're
not at TeamSnap, one of the cookbooks on the
[community site](http://community.opscode.com/) is almost certainly a better
choice for you.

If the node is running on Rackspace, redis will be configured to listen
on the servicenet interface (i.e. eth1.) If not, it will be configured to
listen on 127.0.0.1.

# Requirements

* Ubuntu

# Usage

`include_recipe "redis-server::default"`

# Attributes

none

# Recipes

* default.rb - installs and configures redis

# Author

Author:: TeamSnap (<ops@teamsnap.com>)
