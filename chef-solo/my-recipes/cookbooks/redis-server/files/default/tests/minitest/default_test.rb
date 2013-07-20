require File.expand_path('../support/helpers', __FILE__)

describe 'redis-server::default' do

  include Helpers::Redis_server

  it "installs redis" do
    package("redis-server").must_be_installed
  end

  it "creates the config file" do
    file("/etc/redis/redis.conf").must_exist
  end
end
