# pass tomb [![build][build-img]][build-url] [![coverage][cover-img]][cover-url] [![climate][clima-img]][clima-url]

A [pass](https://www.passwordstore.org/) extension that helps to keep the whole tree of password encrypted inside a tomb.

## Description

Due to the structure of `pass`, file- and directory names are not encrypted in the password store. `pass-tomb` provides a convenient solution to put your password store in a [tomb][github-tomb] and then keep your password tree encrypted when you are not using it.

It uses the same GPG key to encrypt passwords and tomb, therefore you don't need to manage more key or secret. Moreover, you can ask pass-tomb to automatically close your store after a given time.

**The new workflow is the following:**
* Create a password tomb with `pass tomb`
 - Create a new tomb and open it in `~/.password-store`
 - Initialise the password store with the same GPG key
* Use tomb as usual
* When finished, close the password tomb: `pass close`
* To use pass again, you need to open the password tomb: `pass open`

## Examples

**Create a new password tomb**
```
$ pass tomb <gpg-id>
 (*) Your password tomb has been created and opened in ~/.password-store.
 (*) Password store initialized for <gpg-id>
  .  Your tomb is: ~/.password.tomb
  .  Your tomb key is: ~/.password.key.tomb
  .  You can now use pass as usual.
  .  When finished, close the password tomb using 'pass close'.
```

**Open a password tomb**
```
$ pass open
 (*) Your password tomb has been opened in ~/.password-store.
  .  You can now use pass as usual.
  .  When finished, close the password tomb using 'pass close'.
```

**Close a password tomb**
```
$ pass close
 (*) Your password tomb has been closed.
  .  Your passwords remain present in ~/.password.tomb.
```

**Create a new password tomb and set a timer**
```
$ pass tomb <gpg-id> --timer=1h
 (*) Your password tomb has been created and opened in ~/.password-store.
 (*) Password store initialized for <gpg-id>
  .  Your tomb is: ~/.password.tomb
  .  Your tomb key is: ~/.password.key.tomb
  .  You can now use pass as usual.
  .  This password store will be closed in 1h
```

```
$ pass open
(*) Your password tomb has been opened in ~/.password-store.
 .  You can now use pass as usual.
 .  This password store will be closed in 1h
```

**Open a password store and set a timer**
```
$ pass open --timer=10min
 (*) Your password tomb has been opened in ~/.password-store.
  .  You can now use pass as usual.
  .  This password store will be closed in 10min
```

## Usage

```
pass tomb 1.0 - A pass extension that helps to keep the whole tree of
                password encrypted inside a tomb.

Usage:
    pass tomb [-n] [-t time] [-p subfolder] gpg-id...
        Create and initialise a new password tomb
        Use gpg-id for encryption of both tomb and passwords

    pass open [subfolder] [-t time]
        Open a password tomb

    pass close [store]
        Close a password tomb

Options:
    -n, --no-init  Do not initialise the password store
    -t, --timer    Close the store after a given time
    -p, --path     Create the store for that specific subfolder
    -q, --quiet    Be quiet
    -v, --verbose  Be verbose
    -d, --debug    Print tomb debug messages
        --unsafe   Speed up tomb creation (for testing only)
    -V, --version  Show version information.
    -h, --help     Print this help message and exit.

More information may be found in the pass-tomb(1) man page.
```

See `man pass-tomb` for more information.

## Environment Variables

* `PASSWORD_STORE_TOMB`: path to `tomb` executable
* `PASSWORD_STORE_TOMB_FILE`: path to the password tomb (default: `~/.password.tomb`)
* `PASSWORD_STORE_TOMB_KEY`: path to the password tomb key file (default: `~/.password.key.tomb`)
* `PASSWORD_STORE_TOMB_SIZE`: password tomb size in MB (default: `10`)

## Installation

**From git**
```sh
git clone https://github.com/roddhjav/pass-tomb/
cd pass-tomb
sudo make install
```

**Generic Linux**
```sh
wget https://github.com/roddhjav/pass-tomb/archive/v1.0.tar.gz
tar xzf v1.0.tar.gz
cd pass-tomb-1.0
sudo make install
```

**ArchLinux**

`pass-tomb` is available in the [Arch User Repository][aur].
```sh
pacaur -S pass-tomb
```

**Requirments**

* `tomb 2.4` or greater.

* A `systemd` linux distribution is required to use the timer feature.

* `pass 1.7.0` or greater.

* If you do not want to install this extension as system extension, you need to
enable user extension with `PASSWORD_STORE_ENABLE_EXTENSIONS=true pass`. You can
create an alias in `.bashrc`: `alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'`


## Contribution
Feedback, contributors, pull requests are all very welcome.


## License

    Copyright (C) 2017  Alexandre PUJOL

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

[build-img]: https://travis-ci.org/roddhjav/pass-tomb.svg?branch=master
[build-url]: https://travis-ci.org/roddhjav/pass-tomb
[cover-img]: https://coveralls.io/repos/github/roddhjav/pass-tomb/badge.svg?branch=master
[cover-url]: https://coveralls.io/github/roddhjav/pass-tomb?branch=master
[clima-img]: https://codeclimate.com/github/roddhjav/pass-tomb/badges/gpa.svg
[clima-url]: https://codeclimate.com/github/roddhjav/pass-tomb

[github-tomb]: https://github.com/dyne/Tomb
[aur]: https://aur.archlinux.org/packages/pass-tomb
