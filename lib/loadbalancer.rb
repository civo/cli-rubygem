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
      \x5--port=<n> - Port to listen on. Defaults to 80 to match default protocol
      \x5--max_request_size=<nn> - Maximum request content size, in MB
      \x5--policy=<least_conn | random | round_robin | ip_hash> - Balancing policy to choose backends
      \x5--health_check_path=<URL> - Which URL to use to determine if backend status is OK (2xx/3xx status)
      \x5--fail_timeout=<seconds> - Backend timeout in seconds
      \x5--max_conns=<connections> - Maximum concurrent connections to each backend
      \x5--ignore_invalid_backend_tls=<true | false> - Should self-signed/invalid certificates be ignored from the backend servers?
      \x5--backend=<instance_id:instance_id protocol:http | https port:number> - A backend instance, with the instance ID, desired protocol and port number specified.
      LONGDESC
    def create(*args)
      CivoCLI::Config.set_api_auth
      backends = {}
      options[:backend].each do | key, value |
        backends[key] = value
      end
      backendarray = []
      backendarray << backends
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
        backends: backendarray)
      
      puts "Created a new Load Balancer with hostname #{loadbalancer.hostname.colorize(:green)}"
      
    rescue Flexirest::HTTPException => e
      puts e.result.reason.colorize(:red)
      exit 1
    end
    map "new" => "create"

    desc "update ID [OPTIONS]", "update the load balancer ID with options provided"
    option :hostname, banner: 'hostname', aliases: '--name'
    option :protocol, default: 'http', banner: 'http | https'
    option :tls_certificate, banner: 'base64 PEM'
    option :tls_key, banner: 'base64 PEM'
    option :port, lazy_default: 80, type: :numeric, banner: 'listen port'
    option :max_request_size, lazy_default: 20, type: :numeric, banner: 'MegaBytes'
    option :policy, lazy_default: 'random', banner: 'least_conn | random | round_robin | ip_hash'
    option :health_check_path, lazy_default: '/', banner: 'URL', alias: 'healthpath'
    option :fail_timeout, lazy_default: 30, type: :numeric, banner: 'seconds'
    option :max_conns, lazy_default: 10, type: :numeric, banner: 'connections'
    option :ignore_invalid_backend_tls, lazy_default: true, type: :boolean
    option :backend, default: {}, type: :hash
    long_desc <<-LONGDESC
      Update a load balancer with ID provided, and any of the following options:
      \x5--hostname=<hostname> - New hostname
      \x5--protocol=<http | https> - Either http or https. If you specify https then you must also provide the next two fields
      \x5--tls_certificate=<base64 PEM> - TLS certificate in Base64-encoded PEM. Required if --protocol is https
      \x5--tls_key=<base64 PEM> - TLS key in Base64-encoded PEM. Required if --protocol is https
      \x5--port=<n> - Port to listen on. Defaults to 80 to match default protocol
      \x5--max_request_size=<nn> - Maximum request content size, in MB
      \x5--policy=<least_conn | random | round_robin | ip_hash> - Balancing policy to choose backends
      \x5--health_check_path=<URL> - Which URL to use to determine if backend status is OK (2xx/3xx status)
      \x5--fail_timeout=<seconds> - Backend timeout in seconds
      \x5--max_conns=<connections> - Maximum concurrent connections to each backend
      \x5--ignore_invalid_backend_tls=<true | false> - Should self-signed/invalid certificates be ignored from the backend servers?
      \x5--backend=<instance_id:instance_id protocol:http | https port:number> - A backend instance, with the instance ID, desired protocol and port number specified.
      LONGDESC
    def update(id, hostname = nil, protocol = nil, tls_certificate = nil, tls_key = nil, port = nil, max_request_size = nil, policy = nil, health_check_path = nil, fail_timeout = nil, max_conns = nil, ignore_invalid_backend_tls = nil, backend = nil)
      CivoCLI::Config.set_api_auth
      loadbalancer = Civo::LoadBalancer.all.items.detect {|key| key.id == id}
      if options[:backend]
        backends = {}
        options[:backend].each do | key, value |
          backends[key] = value
      end
      backendarray = []
      backendarray << backends
      end
      Civo::LoadBalancer.update(id: loadbalancer.id, 
        hostname: options[:hostname] || loadbalancer.hostname, 
        protocol: options[:protocol] || loadbalancer.protocol, 
        tls_certificate: options[:tls_certificate] || loadbalancer.tls_certificate,
        tls_key: options[:tls_key] || loadbalancer.tls_key,
        port: options[:port] || loadbalancer.port,
        max_request_size: options[:max_request_size] || loadbalancer.max_request_size,
        policy: options[:policy] || loadbalancer.policy,
        health_check_path: options[:health_check_path] || loadbalancer.health_check_path,
        fail_timeout: options[:fail_timeout] || loadbalancer.fail_timeout,
        max_conns: options[:max_conns] || loadbalancer.max_conns, 
        ignore_invalid_backend_tls: options[:ignore_invalid_backend_tls] || loadbalancer.ignore_invalid_backend_tls,
        backends: backendarray || loadbalancer.backends
      )
      puts "Updated Load Balancer #{loadbalancer.hostname.colorize(:green)}"
    end
    map "change" => "update"

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
