# pass tomb [![build status](https://gitlab.com/roddhjav/pass-tomb/badges/master/build.svg)][1]

A [pass](https://www.passwordstore.org/) extension allowing you to put and
manage your password repository in a tomb.

## Description

Due to the structure of `pass`, files and directories names are not encrypted in
the password store. `pass-tomb` provides a convenient solution to put you password
repository in a [tomb](https://github.com/dyne/Tomb) and then keep your password
tree encrypted when you are not using it.

It uses the same GPG key to encrypt passwords and tomb.

The new workflow is the following:
* Create a password tomb with `pass tomb`
 - Create a new tomb and open it in ~/.password-store
 - Initialize the password repository with the same GPG key.
* Use tomb as usual
* When finished close the password tomb: `pass close`
* To use pass again, you need to open the password tomb: `pass open`

## Examples

**Create a new password tomb**
```
$ pass tomb <gpg-id>
 (*) Your password tomb as been created and openned in ~/.password-store.
 (*) Password store initialized for <gpg-id>
  .  Your tomb is: ~/password
  .  Your tomb key is: ~/password.key
  .  You can now use pass as usual
  .  When finished, close the password tomb using 'pass close'
```

**Open a password tomb**
```
$ pass open
 (*) Your password tomb as been closed
  .  Your passwords remain present in ~/password
```

**Close a password tomb**
```
$ pass close
 (*) Your password tomb as been openned in ~/.password-store.
  .  You can now use pass as usual
  .  When finished, close the password tomb using 'pass close'
```

## Usage

		Usage:
		    pass tomb [--path=subfolder,-p subfolder] gpg-id...
		        Create and initialise a new password tomb.
		        Use gpg-id for encryption of both tomb and passwords
		    pass open
		        Open a password tomb
		    pass close
		        Close a password tomb

		Options:
		    -v, --verbose  Print tomb message
		    -d, --debug    Print tomb debug message
		        --unsafe   Speed up tomb creation (for test only)
		    -V, --version  Show version information.
		    -h, --help	   Print this help message and exit.

		More information may be found in the pass-tomb(1) man page.


See `man pass-tomb` for more information on import process

## Environment Variables

* `PASSWORD_STORE_TOMB`: Path to `tomb`
* `PASSWORD_STORE_TOMB_FILE`: Path to the password tomb. (default: `~/password`)
* `PASSWORD_STORE_TOMB_KEY`: Path to the password tomb key file. (default: `~/password.key`)
* `PASSWORD_STORE_TOMB_SIZE`: Password tomb size in MB (default: `10`)

## Installation

**ArchLinux**

		pacaur -S pass-tomb

**Other linux**

		git clone https://gitlab.com/roddhjav/pass-tomb/
		cd pass-tomb
		sudo make install

**Requirments**

* `tomb` with [GnuPG Key Support](https://github.com/dyne/Tomb/pull/244).
As of today this version has not been released yet. Therefore you need to
install it by hand:

		git clone https://github.com/roddhjav/Tomb.git -b gnupg-key-support
		cd Tomb
		sudo make install

* `pass 1.7.0` or greater. As of today this version has not been released yet.
Therefore you need to install it by hand from zx2c4.com:

		git clone https://git.zx2c4.com/password-store
		cd password-store
		sudo make install

* You need to enable the extensions in pass: `PASSWORD_STORE_ENABLE_EXTENSIONS=true pass`.
You can create an alias in `.bashrc`: `alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'`


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

[1]: https://gitlab.com/roddhjav/pass-tomb/commits/master
