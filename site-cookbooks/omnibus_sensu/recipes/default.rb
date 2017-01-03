#
# Cookbook Name:: omnibus_sensu
# Recipe:: default
#
# Copyright (c) 2016 Sensu, All Rights Reserved.

include_recipe 'chef-sugar'

if windows?
  node.default['ms_dotnet']['v4']['version'] = '4.5.2'
  include_recipe 'ms_dotnet::ms_dotnet4'

  # If this is an ephemeral vagrant/test-kitchen instance, we relax the password
  # so that the default password "vagrant" can be used.
  powershell_script 'Disable password complexity requirements' do
    code <<-EOH
      secedit /export /cfg $env:temp/export.cfg
      ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
      secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
    EOH
  end
end

if freebsd?
  package "git"
else
  include_recipe "git"

  git_config "user.email" do
    value "support@sensuapp.com"
    options "--global"
  end

  git_config "user.name" do
    value "Sensu Omnibus Builder"
    options "--global"
  end
end

include_recipe "omnibus::default"

case node["platform_family"]
when "rhel"
  package "gpg"
  package "pygpgme"
end

gem_package "ffi-yajl" do
  if windows?
    gem_binary "C:/opscode/omnibus-toolchain/embedded/bin/gem"
  else
    gem_binary "/opt/omnibus-toolchain/bin/gem"
  end
end

directory node["omnibus_sensu"]["project_dir"] do
  user node["omnibus"]["build_user"]
  group node["omnibus"]["build_user_group"]
  recursive true
  action :create
end

project_dir = windows? ? File.join("C:", node["omnibus_sensu"]["project_dir"]) : node["omnibus_sensu"]["project_dir"]

git project_dir do
  repository 'https://github.com/sensu/sensu-omnibus.git'
  revision node["omnibus_sensu"]["project_revision"]
  user node["omnibus"]["build_user"] unless windows?
  group node["omnibus"]["build_user_group"] unless windows?
  action :sync
end

template ::File.join(node["omnibus_sensu"]["project_dir"], "omnibus.rb") do
  source "omnibus.rb.erb"
  sensitive true
  user node["omnibus"]["build_user"] unless windows?
  group node["omnibus"]["build_user_group"] unless windows?
  variables(
    :aws_region => node["omnibus_sensu"]["publishers"]["s3"]["region"],
    :aws_access_key_id => node["omnibus_sensu"]["publishers"]["s3"]["access_key_id"],
    :aws_secret_access_key => node["omnibus_sensu"]["publishers"]["s3"]["secret_access_key"],
    :aws_s3_cache_bucket => node["omnibus_sensu"]["publishers"]["s3"]["cache_bucket"]
  )
end

shared_env = {
  "SENSU_VERSION" => node["omnibus_sensu"]["build_version"],
  "BUILD_NUMBER" => node["omnibus_sensu"]["build_iteration"],
  "GPG_PASSPHRASE" => node["omnibus_sensu"]["gpg_passphrase"],
  "OMNIBUS_WINDOWS_ARCH" => "x86"
}

omnibus_build "sensu" do
  project_dir node["omnibus_sensu"]["project_dir"]
  log_level :info
  build_user "root" unless windows?
  environment shared_env
  live_stream true
end

pkg_suffix_map = {
  [:ubuntu, :debian]                   => { :default => "deb" },
  [:redhat, :centos, :fedora, :suse]   => { :default => "rpm" },
  :solaris                             => { "5.10" => "solaris", "5.11" => "ips" },
  :aix                                 => { :default => "bff" },
  :freebsd                             => { :default => "txz" }
}

artifact_id = [ node["omnibus_sensu"]["build_version"], node["omnibus_sensu"]["build_iteration"] ].join("-")

execute "publish_sensu_#{artifact_id}_s3" do
  command(
    <<-CODE.gsub(/^ {10}/, '')
          . #{::File.join(build_user_home, 'load-omnibus-toolchain.sh')}
          bundle exec omnibus publish s3 #{node["omnibus_sensu"]["publishers"]["s3"]["artifact_bucket"]} "pkg/sensu*.#{value_for_platform(pkg_suffix_map)}"
        CODE
  )
  cwd node["omnibus_sensu"]["project_dir"]
  user node["omnibus"]["build_user"]
  environment shared_env.merge!({
    'USER' => node["omnibus"]["build_user"],
    'USERNAME' => node["omnibus"]["build_user"],
    'LOGNAME' => node["omnibus"]["build_user"]
  })
  not_if { node["omnibus_sensu"]["publishers"]["s3"].any? {|k,v| v.nil? } }
end
