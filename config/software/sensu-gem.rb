name "sensu-gem"
default_version "0.22.1"

dependency "ruby"
dependency "rubygems"
dependency "libffi"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CC'] = 'gcc'

  gem "install sensu" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env
end