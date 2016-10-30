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
      services << "sensu-service-init"
    when :rcd
      services.map! do |service|
        service.gsub("-", "_")
      end
    end
    services
  end

  def self.directory_for_service(service_manager)
    case service_manager
    when :systemd
      "/etc/systemd/system"
    when :sysvinit
      "/etc/init.d"
    when :rcd
      "/usr/local/etc/rc.d"
    end
  end

  def self.filename_for_service(service_manager, service)
    case service_manager
    when :systemd
      "#{service}.service"
    when :sysvinit
      service
    when :rcd
      service.gsub("_", "-")
    end
  end
end
