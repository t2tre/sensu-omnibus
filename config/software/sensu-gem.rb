name "sensu-gem"
default_version "0.22.2"

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "eventmachine"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CC'] = 'gcc'

  patch_env = env.dup

  files_dir = "#{project.files_path}/#{name}"

  gem "install sensu" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env

  patch_target = "#{install_dir}/embedded/lib/ruby/gems/2.3.0/gems/sensu-0.22.2/lib/sensu/daemon.rb"
  patch source: "pure-ruby.patch", plevel: 1, env: patch_env, target: patch_target

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
  copy("#{files_dir}/sensu-install", bin_dir)
  command("chmod +x #{bin_dir}/sensu-install")

  # make symlinks
  link("#{embedded_bin_dir}/sensu-client", "#{bin_dir}/sensu-client")
  link("#{embedded_bin_dir}/sensu-server", "#{bin_dir}/sensu-server")
  link("#{embedded_bin_dir}/sensu-api", "#{bin_dir}/sensu-api")
end
