name "sensu-gem"
default_version "0.26.1"

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "eventmachine"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  #env['CC'] = 'gcc'
  #env['CXX'] = "g++ -m64"
  #env['cppflags'] = "-std=c99"

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
      " --version '1.4.2'" \
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

  # service wrappers
  Helpers::SERVICE_MANAGERS.each do |service_manager|
    service_dir = Helpers::directory_for_service(service_manager)

    # create share dir for service manager
    service_share_dir = File.join(share_dir, service_dir)
    mkdir(service_share_dir)

    # copy the sensu service files to the share directory
    sensu_services = %w[api client server]
    sensu_services << "service-init" if service_manager == :sysvinit

    sensu_services.each do |sensu_service|
      filename = Helpers::filename_for_service(service_manager, sensu_service)
      source = File.join(files_dir, service_manager.to_s, filename)
      destination = File.join(service_share_dir, filename)
      copy(source, destination)
    end
  end

  # sensu rc script
  copy("#{files_dir}/sensu-client", "#{share_dir}/etc/rc.d")
  command("chmod +x #{share_dir}/etc/rc.d/sensu-client")

  # sensu manifest (solaris)
  copy("#{files_dir}/smf/sensu-client.xml", "#{share_dir}/lib/svc/manifest/site")

  # make symlinks
  link("#{embedded_bin_dir}/sensu-client", "#{bin_dir}/sensu-client")
  link("#{embedded_bin_dir}/sensu-server", "#{bin_dir}/sensu-server")
  link("#{embedded_bin_dir}/sensu-api", "#{bin_dir}/sensu-api")
end
