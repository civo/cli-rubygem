require "civo_cli/version"

require "thor"
require "terminal-table"
require 'colorize'
Dir[File.join(__dir__, '*.rb')].each { |file| require file }

module CivoCLI
  class Error < StandardError; end

  class Main < Thor
    desc "apikey SUBCOMMAND ...ARGS", "manage API keys stored in the client"
    subcommand "apikey", CivoCLI::APIKey
    map apikeys: :apikey

    desc "domain SUBCOMMAND ...ARGS", "manage DNS domains"
    subcommand "domain", CivoCLI::Domain
    map domains: :domain

    desc "firewall SUBCOMMAND ...ARGS", "manage firewalls"
    subcommand "firewall", CivoCLI::Firewall
    map firewalls: :firewall

    desc "instance SUBCOMMAND ...ARGS", "manage instances"
    subcommand "instance", CivoCLI::Instance
    map instances: :instance

    desc "ip SUBCOMMAND ...ARGS", "manage IP addresses"
    subcommand "ip", CivoCLI::IP
    map ips: :ip

    desc "network SUBCOMMAND ...ARGS", "manage networks"
    subcommand "network", CivoCLI::Network
    map networks: :network

    desc "quota SUBCOMMAND ...ARGS", "view the quota"
    subcommand "quota", CivoCLI::Quota
    map quotas: :quota

    desc "region SUBCOMMAND ...ARGS", "manage regions"
    subcommand "region", CivoCLI::Region
    map regions: :region

    desc "size SUBCOMMAND ...ARGS", "manage sizes"
    subcommand "size", CivoCLI::Size
    map sizes: :size

    desc "snapshot SUBCOMMAND ...ARGS", "manage snapshots"
    subcommand "snapshot", CivoCLI::Snapshot
    map snapshots: :snapshot

    desc "sshkey SUBCOMMAND ...ARGS", "manage uploaded SSH keys"
    subcommand "sshkey", CivoCLI::SSHKey
    map sshkeys: :sshkey

    desc "template SUBCOMMAND ...ARGS", "manage templates"
    subcommand "template", CivoCLI::Template
    map templates: :template

    desc "volume SUBCOMMAND ...ARGS", "manage volumes"
    subcommand "volume", CivoCLI::Volume
    map volumes: :volume
  end
end
