name "sensu-gem"
default_version "0.22.2"

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "eventmachine"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CC'] = 'gcc'

  files_dir = "#{project.files_path}/#{name}"

  gem "install sensu" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.2.0'" \
      " --no-ri --no-rdoc", env: env

  share_dir = File.join(install_dir, "embedded", "share", "sensu")
  bin_dir = File.join(install_dir, "bin")
  embedded_bin_dir = File.join(install_dir, "embedded", "bin")

  # make directories
  mkdir("#{install_dir}/bin")
  mkdir("#{share_dir}/etc/sensu")

  # config.json.example
  copy("#{files_dir}/config.json.example", "#{share_dir}/etc/sensu")

  # sensu-install
  copy("#{files_dir}/sensu-install", embedded_bin_dir)

  # make symlinks
  link("#{bin_dir}/sensu-client", "#{embedded_bin_dir}/sensu-client")
  link("#{bin_dir}/sensu-server", "#{embedded_bin_dir}/sensu-server")
  link("#{bin_dir}/sensu-api", "#{embedded_bin_dir}/sensu-api")
  link("#{bin_dir}/sensu-install", "#{embedded_bin_dir}/sensu-install")
end
