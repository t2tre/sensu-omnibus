#
# Cookbook Name:: omnibus_sensu
# Recipe:: default
#
# Copyright (c) 2016 Sensu, All Rights Reserved.

include_recipe "omnibus::default"

case node["platform_family"]
when "rhel"
  package "gpg"
  package "pygpgme"
end

gem_package "ffi-yajl" do
  gem_binary "/opt/omnibus-toolchain/bin/gem"
end

omnibus_build "sensu" do
  project_dir "/home/vagrant/sensu"
  log_level :internal
  build_user "root"
  environment({
    "SENSU_VERSION" => node["omnibus_sensu"]["build_version"],
    "BUILD_NUMBER" => node["omnibus_sensu"]["build_iteration"],
    "GPG_PASSPHRASE" => node["omnibus_sensu"]["gpg_passphrase"]
  })
end
