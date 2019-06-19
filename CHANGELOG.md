# Changelog
All notable changes to the Civo CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2019-06.19
### Fixes
- Fixes .json file check and removes file check at runtime ("if __FILE__ == $0
").

## [0.2.1] - 2019-06-19
### Added
- Kai Hoffman as author

## [0.2.0] - 2019-06-19
### Added
- Implemented commands for APIkey, Blueprint, Domain, Domainrecord, Firewall, Instance, Network, Quota, Region, Size, Snapshot, SSHKey, Template and Volume management

## [0.12.0] - 2017-06-20
### Rewrote
- Written new version in Ruby for ease of maintenance that replaces the old [Go-based CLI](https://github.com/civo/cli-legacy)

[1.0.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.0...v1.0.0
