<h1 align="center">pass tomb</h1>
<p align="center">
    <a href="https://travis-ci.org/roddhjav/pass-tomb">
        <img src="https://img.shields.io/travis/roddhjav/pass-tomb/master.svg"
             alt="Build Status" /></a>
    <a href="https://coveralls.io/github/roddhjav/pass-tomb">
        <img src="https://img.shields.io/coveralls/roddhjav/pass-tomb/master.svg"
             alt="Code Coverage" /></a>
    <a href="https://www.codacy.com/app/roddhjav/pass-tomb">
        <img src="https://img.shields.io/codacy/grade/1c58ea63487a4b82874b05220d500c60/master.svg"
             alt="Code Quality" /></a>
    <a href="https://github.com/roddhjav/pass-tomb/releases/latest">
        <img src="https://img.shields.io/github/release/roddhjav/pass-tomb.svg?maxAge=600"
             alt="Last Release" /></a>
</p>
<p align="center">
A <a href="https://www.passwordstore.org/">pass</a> extension that helps to
keep the whole tree of password encrypted inside a
<a href="https://www.dyne.org/software/tomb/">tomb</a>.
</p>

## Description

Due to the structure of `pass`, file- and directory names are not encrypted in
the password store. `pass-tomb` provides a convenient solution to put your
password store in a [tomb][github-tomb] and then keep your password tree
encrypted when you are not using it.

It uses the same GPG key to encrypt passwords and tomb, therefore you don't need
to manage more key or secret. Moreover, you can ask pass-tomb to automatically
close your store after a given time.

**The new workflow is the following:**
* Create a password tomb with `pass tomb`
 - Create a new tomb and open it in `~/.password-store`
 - Initialise the password store with the same GPG key
* Use tomb as usual
* When finished, close the password tomb: `pass close`
* To use pass again, you need to open the password tomb: `pass open`

## Usage

```
pass tomb 1.1 - A pass extension that helps to keep the whole tree of
                password encrypted inside a tomb.

Usage:
    pass tomb [-n] [-t time] [-f] [-p subfolder] gpg-id...
        Create and initialise a new password tomb
        Use gpg-id for encryption of both tomb and passwords

    pass open [subfolder] [-t time] [-f]
        Open a password tomb

    pass close [store]
        Close a password tomb

Options:
    -n, --no-init  Do not initialise the password store
    -t, --timer    Close the store after a given time
    -p, --path     Create the store for that specific subfolder
    -f, --force    Force operation (i.e. even if swap is active)
    -q, --quiet    Be quiet
    -v, --verbose  Be verbose
    -d, --debug    Print tomb debug messages
        --unsafe   Speed up tomb creation (for testing only)
    -V, --version  Show version information.
    -h, --help     Print this help message and exit.

More information may be found in the pass-tomb(1) man page.
```

See `man pass-tomb` for more information.

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

## Environment Variables

* `PASSWORD_STORE_TOMB`: path to `tomb` executable
* `PASSWORD_STORE_TOMB_FILE`: path to the password tomb (default: `~/.password.tomb`)
* `PASSWORD_STORE_TOMB_KEY`: path to the password tomb key file (default: `~/.password.key.tomb`)
* `PASSWORD_STORE_TOMB_SIZE`: password tomb size in MB (default: `10`)

## Multiple password tombs
It is possible to create multiple pass tomb and open them separately. You only
need to set the tomb file, key and the password store directory manually using
the environment variables:

**Create a tomb**
```sh
PASSWORD_STORE_TOMB_FILE=<tomb_path> PASSWORD_STORE_TOMB_KEY=<key_path> PASSWORD_STORE_DIR=<dir_path> pass tomb <gpgid>
```

**Open/Close a tomb**
```sh
PASSWORD_STORE_TOMB_FILE=<tomb_path> PASSWORD_STORE_TOMB_KEY=<key_path> PASSWORD_STORE_DIR=<dir_path> pass open
PASSWORD_STORE_TOMB_FILE=<tomb_path> PASSWORD_STORE_TOMB_KEY=<key_path> PASSWORD_STORE_DIR=<dir_path> pass close
```

If you always need a second password store, you can create a pass alias, `pass2` that will manage the second store with in `.bashrc`:
```sh
alias pass2='PASSWORD_STORE_TOMB_FILE=<tomb_path> PASSWORD_STORE_TOMB_KEY=<key_path> PASSWORD_STORE_DIR=<dir_path> pass'
```

## Advanced use
Using `tomb` to store your password repository, you can take advantage of the
tomb advanced feature like *steganography* and *private cloud storage*. The
[tomb website][tomb] provide a good presentation of the features available with
Tomb. Moreover, you can read my guide on how to use [Tomb with GPG keys][pujol.io-tomb].

## Installation

**Requirements**
* `pass 1.7.0` or greater.
* `tomb 2.4` or greater.
* A `systemd` linux distribution is required to use the timer feature.

**From git**
```sh
git clone https://github.com/roddhjav/pass-tomb/
cd pass-tomb
sudo make install  # Add: PREFIX=/usr/local for OS X
```

**ArchLinux**

`pass-tomb` is available in the [Arch User Repository][aur].
```sh
pacaur -S pass-tomb  # or your preferred AUR install method
```

**Stable version**
```
wget https://github.com/roddhjav/pass-tomb/releases/download/v1.1/pass-tomb-1.1.tar.gz
tar xzf pass-tomb-1.1.tar.gz
cd pass-tomb-1.1
sudo make install
```

[Releases][releases] and commits are signed using [`06A26D531D56C42D66805049C5469996F0DF68EC`][keys].
You should check the key's fingerprint and verify the signature:
```sh
wget https://github.com/roddhjav/pass-tomb/releases/download/v1.1/pass-tomb-1.1.tar.gz.asc
gpg --recv-keys 06A26D531D56C42D66805049C5469996F0DF68EC
gpg --verify pass-tomb-1.1.tar.gz.asc
```


## Contribution
Feedback, contributors, pull requests are all very welcome.


## Donations
If you really like this software and would like to donate, you can send donations using one of the following currencies:
* In Bitcoin: `1HQaENhbThLHYzgjzmRpVMT7ErTSGzHEzq` (see [proof][keybase])
* In Ethereum: `0x4296ee83cd0d66e1cb3e0622c8f8fef82532c968`
* In Zcash: `t1StE9pbFvep296pdQmKVdaBaRkvnXBKkR1` (see [proof][keybase])
* In Litecoin: `LTjxtZhkYHT31aveumozMd7bCKJ5uymMAC`
* In Bitcoin Cash: `1FCEjKXUGXYctHt53EYifSm4XeQgC1piis`


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

[tomb]: https://www.dyne.org/software/tomb/
[github-tomb]: https://github.com/dyne/Tomb
[pujol.io-tomb]: https://pujol.io/blog/tomb-with-gpg-keys/
[keys]: https://pujol.io/keys
[aur]: https://aur.archlinux.org/packages/pass-tomb
[releases]: https://github.com/roddhjav/pass-tomb/releases
[keybase]: https://keybase.io/roddhjav
