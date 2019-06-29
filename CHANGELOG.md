# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][keep-changelog].

## [1.2] - 2019-06-29
### Added
* Ensure the GPG keys used are trusted before tomb creation.
* Add a systemd pass-close service unit, allowing more than one timer. [#24](https://github.com/roddhjav/pass-tomb/issues/24)
* Add completion for bash and zsh.

### Changed
* Compatibility with Tomb 2.6
* Simplify test setup

### Fixed
* Do not set password tomb permission, only ownership. [#23](https://github.com/roddhjav/pass-tomb/issues/23)
* Use relative path for systemd-run [#18](https://github.com/roddhjav/pass-tomb/pull/18)
* The systemd based timer now works properly


## [1.1] - 2017-12-10
### Added
* Add --force option, force operation (i.e. even if swap is active) [#13](https://github.com/roddhjav/pass-tomb/issues/13).


## [1.0] - 2017-05-20
### Added
* This is the first stable release.
* New `-t` option automatically close the password store using a systemd timer.
* New `-p` option to create & open the password tomb in a subfolder of the password store.
* New `-n` option to create a password tomb but do not initialise the password store.
* Added code coverage using [kcov](https://github.com/SimonKagstrom/kcov).

### Changed
* The test suite has been changed from an handmade one to the [sharness](https://github.com/chriscool/sharness) test suite.
* The new test suite and code coverage are at the origin of a lot of debugging.


## [0.5] - 2017-04-14
### Added
* Added `--no-init` or `-n` option. With this option, pass-tomb create a tomb but do not initialise the password store.
* Added a quiet mode using `-q`

### Fixed
* Various spelling corrections and code improvement.


## [0.2] - 2017-02-28
### Added
* Support for password tomb named with extension. [#2](https://github.com/roddhjav/pass-tomb/issues/2)
* Support for the last version of tomb option using GPG key.

### Changed
* Update the way to set ownership when mounting a tomb. [#1](https://github.com/roddhjav/pass-tomb/issues/1)


## [0.1] - 2017-02-21

* Initial release


[1.2]: https://github.com/roddhjav/pass-tomb/releases/tag/v1.2
[1.1]: https://github.com/roddhjav/pass-tomb/releases/tag/v1.1
[1.0]: https://github.com/roddhjav/pass-tomb/releases/tag/v1.0
[0.5]: https://github.com/roddhjav/pass-tomb/releases/tag/v0.5
[0.2]: https://github.com/roddhjav/pass-tomb/releases/tag/v0.2
[0.1]: https://github.com/roddhjav/pass-tomb/releases/tag/v0.1

[keep-changelog]: https://keepachangelog.com/en/1.0.0/
