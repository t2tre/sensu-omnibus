name "eventmachine"

dependency "ruby"

source git: "git@github.com:portertech/eventmachine.git"

default_version "hotfix/aix-compile-backport"

version "hotfix/aix-compile-backport" do
  source git: "git@github.com:portertech/eventmachine.git"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "gem install rake-compiler", env: env

  command "rake clean", env: env
  command "rake compile", env: env
  command "rake gem", env: env

  command "gem install pkg/eventmachine-1.0.9.1.gem", env: env
end
