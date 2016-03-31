name "eventmachine"

dependency "ruby"

source git: "git@github.com:portertech/eventmachine.git"

default_version "hotfix/aix-compile-backport"

version "hotfix/aix-compile-backport" do
  source git: "git@github.com:portertech/eventmachine.git"
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

  command "gem install pkg/eventmachine-1.0.9.1.gem", env: env

  command "cd #{install_dir}/embedded/lib/ruby/gems/2.3.0/gems/eventmachine-1.0.9.1"

  patch_target = "#{install_dir}/embedded/lib/ruby/gems/2.3.0/gems/eventmachine-1.0.9.1/lib/em/pure_ruby.rb"
  patch source: "pure-ruby-fixes.patch", plevel: 1, env: patch_env, target: patch_target
end
