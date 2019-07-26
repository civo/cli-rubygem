module CivoCLI
  class LoadBalancer < Thor
    desc "list", "list all load balancers"
    def list
      CivoCLI::Config.set_api_auth
      rows = []
      Civo::LoadBalancer.all.items.each do |loadbalancer|
        rows << [loadbalancer.id, loadbalancer.hostname, loadbalancer.protocol, loadbalancer.port, loadbalancer.tls_certificate, loadbalancer.tls_key, loadbalancer.policy, loadbalancer.health_check_path, loadbalancer.fail_timeout, loadbalancer.max_conns, loadbalancer.ignore_invalid_backend_tls, loadbalancer.backends.items.map(&:instance_id).join(", ")]
      end
      
      puts Terminal::Table.new headings: ['ID', 'Hostname', 'Protocol', 'Port', "TLS\nCert", 'TLS key', 'Policy', "Health Check\nPath", "Fail\nTimeout", "Max.\nConnections", "Ignore Invalid\nBackend TLS?", 'Backends'], rows: rows
    end
    map "ls" => "list", "all" => "list"


    desc "create [OPTIONS]", "create a new load balancer with options"
    option :hostname, banner: 'hostname', aliases: '--name'
    option :protocol, default: 'http', banner: 'http | https'
    option :tls_certificate, banner: 'base64 PEM'
    option :tls_key, banner: 'base64 PEM'
    option :port, default: 80, type: :numeric, banner: 'listen port'
    option :max_request_size, default: 20, type: :numeric, banner: 'MegaBytes'
    option :policy, default: 'random', banner: 'least_conn | random | round_robin | ip_hash'
    option :health_check_path, default: '/', banner: 'URL', alias: 'healthpath'
    option :fail_timeout, default: 30, type: :numeric, banner: 'seconds'
    option :max_conns, default: 10, type: :numeric, banner: 'connections'
    option :ignore_invalid_backend_tls, default: true, type: :boolean
    option :backend, default: {}, type: :hash
    long_desc <<-LONGDESC
      Create a new load balancer with hostname (randomly assigned if blank), and supplied options:
      \x5--hostname=<hostname> - If not supplied, will be in format loadbalancer-uuid.civo.com
      \x5--protocol=<http | https> - Either http or https. If you specify https then you must also provide the next two fields
      \x5--tls_certificate=<base64 PEM> - TLS certificate in Base64-encoded PEM. Required if --protocol is https
      \x5--tls_key=<base64 PEM> - TLS key in Base64-encoded PEM. Required if --protocol is https
      \x5--max_request_size=<nn> - Maximum request content size, in MB
      \x5--policy=least_conn | random | round_robin | ip_hash - Balancing policy to choose backends
      \x5--health_check_path=<URL> - Which URL to use to determine if backend status is OK (2xx/3xx status)
      \x5--fail_timeout=<seconds> - Backend timeout in seconds
      \x5--max_conns=<connections> - Maximum concurrent connections to each backend
      \x5--ignore_invalid_backend_tls=<true | false> - should self-signed/invalid certificates be ignored from the backend servers?
      \x5--backend=<instance:instance_id protocol:http|https port:number> - A backend instance, with the instance ID, desired protocol and port number specified.
      LONGDESC
    def create(*args)
      CivoCLI::Config.set_api_auth
      loadbalancer = Civo::LoadBalancer.create(hostname: options[:hostname] ||= nil, 
        protocol: options[:protocol], 
        tls_certificate: options[:tls_certificate], 
        tls_key: options[:tls_key], 
        port: options[:port], 
        max_request_size: options[:max_request_size], 
        policy: options[:policy], 
        health_check_path: options[:health_check_path], 
        fail_timeout: options[:fail_timeout], 
        max_conns: options[:max_conns], 
        ignore_invalid_backend_tls: options[:ignore_invalid_backend_tls], 
        backend: {options[:backend]})
      puts "Created a new Load Balancer with hostname"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "remove ID", "remove the load balancer with ID"
    def remove(id)
      CivoCLI::Config.set_api_auth
      loadbalancer = Civo::LoadBalancer.all.items.detect {|key| key.id == id}
      Civo::LoadBalancer.remove(id: id)
      puts "Removed the load balancer #{loadbalancer.hostname.colorize(:green)} with ID #{loadbalancer.id.colorize(:green)}"
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "delete" => "remove", "rm" => "remove"

    default_task :help

  end
end
