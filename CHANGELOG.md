# Changelog
All notable changes to the Civo CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.12] - 2019-08-28
### Added
- Support for Kubernetes marketplace applications

## [0.3.11] - 2019-08-19
### Changed
- Updated `civo` gem dependency for correct Kubernetes endpoints.
- Aliased `k8s`/`kubernetes` command to be `k3s`

## [0.3.10] - 2019-08-19
### Added
- Alias for `instance public_ip` method as `instance ip`

### Fixed
- File require issues on Debian Jessie preventing gem from running

## [0.3.9] - 2019-08-12
### Added
- Time taken for a `create` command appended with `--wait`.
### Fixed
- Kubernetes cluster `--wait` command to correctly detect ready state to output time.
- Issue with file requires preventing Ubuntu machines from running the gem.
- Error in parsing `instance create` without other switches to create default instance with generated name.

## [0.3.8] - 2019-07-26
### Fixed
- Kubernetes cluster launches now wait for the master to be ready, not necessarily all nodes.

## [0.3.7] - 2019-07-26
### Fixed
- runtime dependency on `civo` gem updated to latest version due to changes in how it functions.

## [0.3.6] - 2019-07-25
### Added
- `kubernetes config --save` option to save a named cluster's configuration file to `~/.kube/config` (requires `kubectl` to be installed)
- `kubernetes create --wait --save` option to save a new cluster's configuration to `~/.kube/config` (requires `kubectl` to be installed)
- Aliases for `show` and `list` in methods where they are available.

### Changed
- Make `help` the default method when base / subcommand is called with no options/arguments.

## [0.3.5] - 2019-07-11
### Removed
- Removed password from output of `instance show`

### Added
- `instance password` method to show initial user password for specific instance. Accepts --quiet (-q) to output single-line.
- `--quiet (-q)` switch to `instance public_ip` to display output on single line.

## [0.3.4] - 2019-07-10
### Fixed
- Template ID in `instance create` default wasn't working nicely, now defaults to Ubuntu if not provided and no snapshot specified
### Added
- Verbose mode switch `-v` / `--verbose` to `template list`
- `public_ip` method to `instance` to output public IP of the chosen instance

## [0.3.3] - 2019-07-08
### Fixed
- Instances list was only showing first twenty servers, now shows all

## [0.3.2] - 2019-07-05
### Fixed
- CLI was always hiding the cursor, requiring a `reset` afterwards

## [0.3.1] - 2019-07-05
### Fixed
- Verbose option to blueprint show was ignored and it was always verbose

## [0.3.0] - 2019-07-05
### Added
- Verbose option to blueprint show

## [0.2.9] - 2019-07-04
### Added
- Version command that tells you your current version and checks if you're out of date

## [0.2.8] - 2019-07-04
### Fixed
- Forced rebuild of a blueprint didn't work

## [0.2.7] - 2019-07-04
### Fixed
- Broken display after updating a blueprint if you use a name instead of an ID

## [0.2.6] - 2019-07-04
### Fixed
- Slightly badly named method caused confusion, clarified by renaming the method and correcting usage of it

## [0.2.5] - 2019-07-04
### Added
- Added support for using part of an ID instead of a whole ID

### Fixed
- Trapping of error message when a non-administrator tries to update blueprints

## [0.2.4] - 2019-06-28
### Added
- Added Kubernetes endpoints for when the service launches

## [0.2.3] - 2019-06-21
### Added
- Instance name generator
- Ability to start instances with default options and generated name

### Changed
- README.md to reflect new scope of commands and abilities
- Help texts in instance methods to display long descriptions where appropriate

## [0.2.2] - 2019-06-19
### Fixes
- Fixes .json file check and removes file check at runtime ("if __FILE__ == $0").

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
