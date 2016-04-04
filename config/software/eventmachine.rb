name "eventmachine"

dependency "ruby"

source git: "git@github.com:eventmachine/eventmachine.git"

# TODO: use a proper version
default_version "master"

version "master" do
  source git: "git@github.com:eventmachine/eventmachine.git"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  ENV["CC"] = "gcc"
  ENV["CXX"] = "g++"

  patch_env = env.dup

  command "gem install rake-compiler", env: env

  command "rake clean", env: env
  command "rake compile", env: env
  command "rake gem", env: env

  command "gem install pkg/eventmachine-1.2.0.1.gem", env: env
end
