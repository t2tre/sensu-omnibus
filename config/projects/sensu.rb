#
# Copyright 2016 Heavy Water Operations, LLC.
#
# All Rights Reserved.
#

unless ENV.key?("SENSU_VERSION")
  puts "SENSU_VERSION must be set"
  exit 2
end

unless ENV.key?("BUILD_NUMBER")
  puts "BUILD_NUMBER must be set"
  exit 2
end

name "sensu"
maintainer "support@sensuapp.com"
homepage "https://sensuapp.org"
license "MIT"
description "A monitoring framework that aims to be simple, malleable, and scaleable."

vendor = "Sensu <support@sensuapp.com>"

# Defaults to C:/sensu on Windows
# and /opt/sensu on all other platforms
install_dir "#{default_root}/#{name}"

version = ENV["SENSU_VERSION"]
build_version version
build_iteration ENV["BUILD_NUMBER"]

override "sensu-gem", version: version
override "ruby", version: "2.3.0"
override "rubygems", version: "2.6.6"

package :deb do
  section "Monitoring"
  vendor vendor
end

package :rpm do
  category "Monitoring"
  vendor vendor
  signing_passphrase ENV["GPG_PASSPHRASE"] unless (ENV["GPG_PASSPHRASE"].nil? || ENV["GPG_PASSPHRASE"].empty?)
end

# TODO: config files are removed during actions such as dpkg --purge
#if linux?
#  config_file "/etc/sensu/config.json.example"
#  config_file "/etc/sensu/conf.d/README.md"
#  config_file "/etc/logrotate.d/sensu"
#  config_file "/etc/default/sensu"
#end

# Creates required build directories
dependency "preparation"

# package scripts erb templates
dependency "package-scripts" unless windows?

# sensu dependencies/components
dependency "sensu-gem"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

# Our package scripts are generated from .erb files,
# so we will grab them from an excluded folder
package_scripts_path "#{install_dir}/.package_util/package-scripts"
exclude '.package_util'
