require 'pry'
require 'net/ssh'

@hostname = 'aix'
@username = 'root'
@pass     = ENV['AIX_PASSWORD']
@cmd      = "echo '[SSH] Connection established'"

@session = Net::SSH.start(@hostname, @username, :password => @pass, :verbose => :debug)

def execute_with_exit_code(command)
  exit_code = nil
  @session.open_channel do |channel|
    channel.request_pty

    channel.exec(command) do |_ch, _success|
      channel.on_data do |_ch, data|
        puts data
      end

      channel.on_extended_data do |_ch, _type, data|
        puts data
      end

      channel.on_request("exit-status") do |_ch, data|
        exit_code = data.read_long
      end
    end
  end
  @session.loop
  exit_code
end

binding.pry
