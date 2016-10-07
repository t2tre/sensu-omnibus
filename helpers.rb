module Helpers
  SERVICE_MANAGERS = [
    :systemd,
    :sysvinit
  ].freeze

  def self.services(service_manager)
    services = [
      "sensu-api",
      "sensu-client",
      "sensu-server",
    ]
    case service_manager
    when :sysvinit
      services << "service-init"
    end
    services
  end

  def self.directory_for_service(service_manager)
    case service_manager
    when :systemd
      "/etc/systemd/system"
    when :sysvinit
      "/etc/init.d"
    end
  end

  def self.filename_for_service(service_manager, service)
    case service_manager
    when :systemd
      "sensu-#{service}.service"
    when :sysvinit
      "sensu-#{service}"
    end
  end
end
