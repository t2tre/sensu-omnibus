name "sensu-gem"
default_version "0.26.1"

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "rb-readline-gem"
dependency "eventmachine"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  patch_env = env.dup

  files_dir = "#{project.files_path}/#{name}"

  gem "install sensu" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.2.0'" \
      " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.4.4'" \
      " --no-ri --no-rdoc", env: env

  share_dir = File.join(install_dir, "embedded", "share", "sensu")
  bin_dir = File.join(install_dir, "bin")
  embedded_bin_dir = File.join(install_dir, "embedded", "bin")

  if freebsd?
    etc_dir = "/usr/local/etc"
    usr_bin_dir = "/usr/local/bin"
  else
    etc_dir = "/etc"
    usr_bin_dir = "/usr/bin"
  end

  # make directories
  mkdir("#{install_dir}/bin")
  mkdir("#{etc_dir}/sensu")
  mkdir("#{etc_dir}/sensu/conf.d")
  mkdir("#{etc_dir}/sensu/extensions")
  mkdir("#{etc_dir}/sensu/plugins")
  mkdir("/var/log/sensu")
  mkdir("/var/run/sensu")
  mkdir("/var/cache/sensu")
  mkdir("#{etc_dir}/logrotate.d")
  mkdir("/lib/svc/manifest/site") if solaris?
  mkdir("#{etc_dir}/default") unless rhel? || debian? # if directory doesn't exist would be better

  # .keep files to ensure all directories have at least one file
  touch("#{etc_dir}/sensu/conf.d/.keep")
  touch("#{etc_dir}/sensu/extensions/.keep")
  touch("#{etc_dir}/sensu/plugins/.keep")
  touch("/var/log/sensu/.keep")
  touch("/var/run/sensu/.keep")
  touch("/var/cache/sensu/.keep")

  # sensu-install (in omnibus bin dir)
  copy("#{files_dir}/bin/sensu-install", bin_dir)
  copy("#{files_dir}/bin/sensu-install", "#{usr_bin_dir}/sensu-install")
  command("chmod +x #{bin_dir}/sensu-install")
  command("chmod +x #{usr_bin_dir}/sensu-install")

  # misc files
  copy("#{files_dir}/config.json.example", "#{etc_dir}/sensu/config.json.example")
  copy("#{files_dir}/default/sensu", "#{etc_dir}/default/sensu")
  copy("#{files_dir}/logrotate.d/sensu", "#{etc_dir}/logrotate.d/sensu")

  # add extra package files (files outside of /opt/sensu)
  project.extra_package_file("#{etc_dir}/sensu/config.json.example")
  project.extra_package_file("#{etc_dir}/default/sensu")
  project.extra_package_file("#{etc_dir}/logrotate.d/sensu")
  project.extra_package_file("#{usr_bin_dir}/sensu-install")
  project.extra_package_file("#{etc_dir}/sensu/conf.d/.keep")
  project.extra_package_file("#{etc_dir}/sensu/extensions/.keep")
  project.extra_package_file("#{etc_dir}/sensu/plugins/.keep")
  project.extra_package_file("/var/log/sensu/.keep")
  project.extra_package_file("/var/run/sensu/.keep")
  project.extra_package_file("/var/cache/sensu/.keep")

  # sensu-service
  copy("#{files_dir}/bin/sensu-service", bin_dir)
  command("chmod +x #{bin_dir}/sensu-service")

  # determine which service manager to use
  platform = ohai["platform"]
  platform_family = ohai["platform_family"]
  platform_version = ohai["platform_version"]
  service_manager = Helpers::service_manager_for(platform, platform_version)

  # service wrappers
  service_dir = Helpers::directory_for_service(platform_family, service_manager)

  # render the sensu service templates to their destination
  Helpers::services(service_manager).each do |sensu_service|
    filename = Helpers::filename_for_service(service_manager, sensu_service)
    destination = File.join(service_dir, filename)
    options = {
      source: "#{service_manager}/sensu-service.erb",
      dest: destination,
      vars: {
        :service_name => sensu_service,
        :service_shortname => sensu_service.gsub(/sensu[-_]/, "")
      },
      mode: 0755
    }
    erb(options)
    project.extra_package_file(destination)
  end

  # make symlinks
  link("#{embedded_bin_dir}/sensu-client", "#{bin_dir}/sensu-client")
  link("#{embedded_bin_dir}/sensu-server", "#{bin_dir}/sensu-server")
  link("#{embedded_bin_dir}/sensu-api", "#{bin_dir}/sensu-api")
end
