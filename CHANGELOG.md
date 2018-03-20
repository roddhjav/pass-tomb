# Changes By Release

All the releases are signed using the GPG key
[`06A26D531D56C42D66805049C5469996F0DF68EC`](https://pujol.io/keys/)

## 1.1 - 2017-12-10

* Add --force option, force operation (i.e. even if swap is active) #13.

## 1.0 - 2017-05-20

**This is the first stable release.**

**New features**
* New `-t` option automatically close the password store using a systemd timer.
* New `-p` option to create & open the password tomb in a subfolder of the password store.
* New `-n` option to create a password tomb but do not initialise the password store.

**Code Quality**
* The test suite has been changed from an handmade one to the [sharness](https://github.com/chriscool/sharness) test suite.
* Added code coverage using [kcov](https://github.com/SimonKagstrom/kcov).
* The new test suite and code coverage are at the origin of a lot of debugging.

## 0.5 - 2017-04-14

* Added `--no-init` or `-n` option. With this option, pass-tomb create a tomb but do not initialise the password store.
* Added a quiet mode using `-q`
* Various spelling corrections and code improvement.
* **Warning**: `pass-tomb 0.5` still requires `tomb` to be installed from the master branch:

## 0.2 - 2017-02-28

* Add support for password tomb named with extension. See #2
* Update the way to set ownership when mounting a tomb. See #1
* Support for the last version of tomb option using GPG key.

## 0.1 - 2017-02-21

* Initial release
