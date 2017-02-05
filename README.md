# pass tomb

A [pass](https://www.passwordstore.org/) extension allowing you to put and
manage your password repository in a tomb.

## Usage

		Usage:
		    pass tomb gpg-id...
		    	Create and initialise a new password tomb.
		    	Use gpg-id for encryption of both tomb and passwords
		    pass tomb help
		    	Print this help
		    pass open
		    	Open a password tomb
		    pass close
		    	Close a password tomb

		More information may be found in the pass-tomb(1) man page.


See `man pass-tomb` for more information on import process


## Installation

**ArchLinux**

		pacaur -S pass-tomb

**Other linux**

		git clone https://github.com/alexandrepujol/pass-tomb/
		cd pass-tomb
		sudo make install

**Requirments**

In order to use extension with `pass`, you need:
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

