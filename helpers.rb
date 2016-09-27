module Helpers
  SERVICE_MANAGERS = [
    :systemd,
    :upstart,
    :sysvinit
  ].freeze

  def self.directory_for_service(service_manager)
    case service_manager
    when :systemd
      "/etc/systemd/system"
    when :upstart
      "/etc/init"
    when :sysvinit
      "/etc/init.d"
    end
  end

  def self.filename_for_service(service_manager, service)
    case service_manager
    when :systemd
      "sensu-#{service}.service"
    when :upstart
      "sensu-#{service}.conf"
    when :sysvinit
      "sensu-#{service}"
    end
  end
end
