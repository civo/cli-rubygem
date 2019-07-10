# Changelog
All notable changes to the Civo CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
