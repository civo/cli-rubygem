require "civo_cli/version"

require "civo"
require "json"
require "thor"
require "terminal-table"
require 'colorize'
Dir[File.join(__dir__, '*.rb')].each { |file| require file }

module CivoCLI
  class Error < StandardError; end

  class Main < Thor
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

    desc "kubernetes", "manage kubernetess"
    subcommand "kubernetes", CivoCLI::Kubernetes
    map "k8s" => "kubernetes"

    desc "network", "manage networks"
    subcommand "network", CivoCLI::Network
    map "networks" => "network"

    desc "quota", "view the quota"
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

    desc "volume", "manage volumes"
    subcommand "volume", CivoCLI::Volume
    map "volumes" => "volume"

  end
end
