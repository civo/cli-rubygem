require "civo_cli/version"
require "civo"
require "json"
require "thor"
require "terminal-table"
require 'colorize'
require 'config'
require 'namegenerator'
Dir[File.join(__dir__, '*.rb')].each { |file| require file }

module CivoCLI
  class Error < StandardError; end

  class Main < Thor
    check_unknown_options!

    desc "apikey", "manage API keys stored in the client"
    subcommand "apikey", CivoCLI::APIKey
    map "apikeys" => "apikey"

    desc "blueprint", "manage blueprints"
    subcommand "blueprint", CivoCLI::Blueprint
    map "blueprints" => "blueprint"

    desc "domain", "manage DNS domains"
    subcommand "domain", CivoCLI::Domain
    map "domains" => "domain"

    desc "domainrecord", "manage domain name DNS records for a domain"
    subcommand "domainrecord", CivoCLI::DomainRecord
    map "domainrecords" => "domainrecord"

    desc "firewall", "manage firewalls"
    subcommand "firewall", CivoCLI::Firewall
    map "firewalls" => "firewall"

    desc "instance", "manage instances"
    subcommand "instance", CivoCLI::Instance
    map "instances" => "instance"

    desc "kubernetes", "manage Kubernetes. Aliases: k8s, k3s"
    subcommand "kubernetes", CivoCLI::Kubernetes
    map "k8s" => "kubernetes", "k3s" => "kubernetes"

    desc "applications", "list and add marketplace applications to Kubernetes clusters. Alias: apps, addons, marketplace, k8s-apps, k3s-apps"
    subcommand "applications", CivoCLI::KubernetesApplications
    map "apps" => "applications", "app" => "applications", "application" => "applications",
      "addon" => "applications", "addons" => "applications", "marketplace" => "applications",
      "k8s-apps" => "applications", "k8s-app" => "applications",
      "k3s-apps" => "applications", "k3s-app" => "applications"

    desc "loadbalancer", "manage load balancers"
    subcommand "loadbalancer", CivoCLI::LoadBalancer
    map "loadbalancers" => "loadbalancer"

    desc "network", "manage networks"
    subcommand "network", CivoCLI::Network
    map "networks" => "network"

    desc "quota", "view the quota for the active account"
    subcommand "quota", CivoCLI::Quota
    map "quotas" => "quota"

    desc "region", "manage regions"
    subcommand "region", CivoCLI::Region
    map "regions" => "region"

    desc "size", "manage sizes"
    subcommand "size", CivoCLI::Size
    map "sizes" => "size"

    desc "snapshot", "manage snapshots"
    subcommand "snapshot", CivoCLI::Snapshot
    map "snapshots" => "snapshot"

    desc "sshkey", "manage uploaded SSH keys"
    subcommand "sshkey", CivoCLI::SSHKey
    map "sshkeys" => "sshkey"

    desc "template", "manage templates"
    subcommand "template", CivoCLI::Template
    map "templates" => "template"

    desc "update", "update to the latest Civo CLI"
    def update
      output = `gem update civo_cli 2>&1`
      if output["You don't have write permissions"]
        puts "Updating Civo CLI with sudo permissions (unable to do it without)"
        `sudo gem update civo_cli 2>&1`
      end
      version
    end

    desc "version", "show the version of Civo CLI used"
    def version
      gem_details = Civo::Base._request("https://rubygems.org/api/v1/gems/civo_cli.json")
      gem_version = Gem::Version.new(gem_details.version)
      this_version = Gem::Version.new(CivoCLI::VERSION)
      if this_version > gem_version
        puts "You are running an #{"unreleased v#{CivoCLI::VERSION}".colorize(:green)} of Civo CLI"
      elsif this_version == gem_version
        puts "You are running the #{"current".colorize(:green)} v#{CivoCLI::VERSION} of Civo CLI"
      else
        puts "You are running v#{CivoCLI::VERSION} of Civo CLI, but are out of date because #{"v#{gem_details.version}".colorize(:red)} is available"

      end
    end

    desc "volume", "manage volumes"
    subcommand "volume", CivoCLI::Volume
    map "volumes" => "volume"

  end
end
