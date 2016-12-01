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
      " --version '1.4.3'" \
      " --no-ri --no-rdoc", env: env

  share_dir = File.join(install_dir, "embedded", "share", "sensu")
  bin_dir = File.join(install_dir, "bin")
  embedded_bin_dir = File.join(install_dir, "embedded", "bin")

  # make directories
  mkdir("#{install_dir}/bin")
  mkdir("#{share_dir}/etc/sensu")
  mkdir("#{share_dir}/etc/default")
  mkdir("#{share_dir}/etc/logrotate.d")
  mkdir("#{share_dir}/etc/rc.d")
  mkdir("#{share_dir}/lib/svc/manifest/site")

  # config.json.example
  copy("#{files_dir}/config.json.example", "#{share_dir}/etc/sensu")

  # default file
  copy("#{files_dir}/default/sensu", "#{share_dir}/etc/default")

  # sensu-install
  copy("#{files_dir}/bin/sensu-install", bin_dir)
  command("chmod +x #{bin_dir}/sensu-install")

  # sensu-service
  copy("#{files_dir}/bin/sensu-service", bin_dir)
  command("chmod +x #{bin_dir}/sensu-service")

  # logrotate.d config
  copy("#{files_dir}/logrotate.d/sensu", "#{share_dir}/etc/logrotate.d")

  # determine which service manager to use
  platform = ohai["platform"]
  platform_family = ohai["platform_family"]
  platform_version = ohai["platform_version"]
  service_manager = Helpers::service_manager_for(platform, platform_version)

  # service wrappers
  service_dir = Helpers::directory_for_service(platform_family, service_manager)

  # copy the sensu service files to their destination
  Helpers::services(service_manager).each do |sensu_service|
    filename = Helpers::filename_for_service(service_manager, sensu_service)
    destination = File.join(service_dir, filename)
    options = {
      source: "#{service_manager}/sensu-service.erb",
      dest: destination,
      vars: {
        :service_name => sensu_service,
        :service_shortname => sensu_service.gsub("/sensu[-_]/", "")
      },
      mode: 0755
    }
    erb(options)
    project.extra_package_file(destination)
  end

  # sensu manifest (solaris)
  copy("#{files_dir}/smf/sensu-client.xml", "#{share_dir}/lib/svc/manifest/site")

  # make symlinks
  link("#{embedded_bin_dir}/sensu-client", "#{bin_dir}/sensu-client")
  link("#{embedded_bin_dir}/sensu-server", "#{bin_dir}/sensu-server")
  link("#{embedded_bin_dir}/sensu-api", "#{bin_dir}/sensu-api")
end
