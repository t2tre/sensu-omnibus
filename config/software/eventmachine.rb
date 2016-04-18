name "eventmachine"

dependency "ruby"

source git: "https://github.com/portertech/eventmachine.git"

default_version "feature/pure_ruby_tls"

version "feature/pure_ruby_tls" do
  source git: "https://github.com/portertech/eventmachine.git"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # these are needed to get eventmachine to compile on Solaris
  # but eventmachine segfaults at runtime :(
  #env['CXX'] = "g++ -m64"
  #env['cppflags'] = "-D_XOPEN_SOURCE=700"

  command "gem install rake-compiler", env: env
  command "rake clean", env: env

  # disable C++ extensions so we don't need to compile them on platforms
  # we're only using pure_ruby with
  if aix? || solaris?
    patch source: "disable-extensions.patch", plevel: 1, env: env
  else
    command "rake compile", env: env
  end

  command "rake gem", env: env

  command "gem install pkg/eventmachine-1.2.0.1.gem", env: env
end
