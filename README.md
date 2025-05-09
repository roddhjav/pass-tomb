[<img src="https://gitlab.com/uploads/-/system/project/avatar/3157196/logo.png" align="right" height="110"/>][github-link]

# pass tomb

[![][workflow]][action] [![][gitlab]][gitlab-link] [![][coverage]][coverage-link] [![][quality]][quality-link] [![
][release]][release-link]

**A [pass] extension that helps you keep the whole tree of passwords encrypted inside a [Tomb].**


## Description

Due to the structure of `pass`, file- and directory names are not encrypted in the password store. `pass-tomb` provides a convenient solution to put your password store in a [Tomb][github-tomb] and then keep your password tree encrypted when you are not using it.

It uses the same GPG key to encrypt passwords and tomb, therefore you don't need to manage more key or secret. Moreover, you can ask pass-tomb to automatically close your store after a given time.

**The new workflow is the following:**
* Create a password tomb with `pass tomb`
 - Create a new tomb and open it in `~/.password-store`
 - Initialize the password store with the same GPG key
* Use pass as usual
* When finished, close the password tomb: `pass close`
* To use pass again, you need to open the password tomb: `pass open`

## Usage

```
pass tomb 1.3 - A pass extension that helps to keep the whole tree of
                password encrypted inside a tomb.

Usage:
    pass tomb [-n] [-t time] [-f] [-p subfolder] [-s size] gpg-id...
        Create and initialise a new password tomb
        Use gpg-id for encryption of both tomb and passwords

    pass open [subfolder] [-t time] [-k key] [--file tomb] [-f]
        Open a password tomb

    pass close [store]
        Close a password tomb

    pass timer [store]
        Show timer status

Options:
    -n, --no-init  Do not initialise the password store
    -t, --timer    Close the store after a given time
    -p, --path     Create the store for that specific subfolder
    -k, --key      Specify the path to the password tomb key
    --file         Specify the tomb file to open 
    -s, --size     Specify the tomb size in MB
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

## Import existing password repository

In order to use pass-tomb with your existing password repository you can:
1. Move your password repository: `mv ~/.password-store ~/.password-store-backup`
2. Create and open a new password tomb: `pass tomb <gpgid>`
3. Move all the content of your password repository in the new password tomb:
   ```
   mv ~/.password-store-backup/ ~/.password-store`
   ```

## Environment Variables

* `PASSWORD_STORE_TOMB`: path to `tomb` executable
* `PASSWORD_STORE_TOMB_FILE`: path to the password tomb (default: `~/.password.tomb`)
* `PASSWORD_STORE_TOMB_KEY`: path to the password tomb key file (default: `~/.password.key.tomb`)
* `PASSWORD_STORE_TOMB_SIZE`: password tomb size in MB (default: `30`)

## Multiple password tombs

It is possible to create multiple pass tomb and open them separately. You only need to set the tomb file, key and the password store directory manually using the environment variables:

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

Using `tomb` to store your password repository, you can take advantage of the tomb advanced feature like *steganography* and *private cloud storage*. The [tomb website][Tomb] provide a good presentation of the features available with Tomb. Moreover, you can read my guide on how to use [Tomb with GPG keys][pujol.io-tomb].

pass-tomb is not compatible with Android, but it should not be an issue for you. If you consider it is safe to put your password-store on Android then, it probably means you attacker model does not require the need of pass-tomb.

## Installation [<img src="https://repology.org/badge/vertical-allrepos/pass-tomb.svg" align="right">][repology-link]

**Requirements**
* `pass 1.7.0` or greater.
* `tomb 2.4` or greater.
* A `systemd` based Linux distribution is required to use the timer feature.

**ArchLinux**

`pass-tomb` is available in the [Arch User Repository][aur].
```sh
yay -S pass-tomb  # or your preferred AUR install method
```

**Debian**

```sh
apt install pass-extension-tomb
```

**NixOS**
```sh
nix-env -iA nixos.passExtensions.pass-tomb
```

**OSX**
> **pass-tomb is based on dm-crypt and therefore it is not compatible with Mac systems.**

**From git**
```sh
git clone https://github.com/roddhjav/pass-tomb/
cd pass-tomb
sudo make install
```

**Stable version**
```sh
wget https://github.com/roddhjav/pass-tomb/releases/download/v1.3/pass-tomb-1.3.tar.gz
tar xzf pass-tomb-1.3.tar.gz
cd pass-tomb-1.3
sudo make install
```

[Releases][releases] and commits are signed using [`06A26D531D56C42D66805049C5469996F0DF68EC`][keys]. You should check the key's fingerprint and verify the signature:
```sh
wget https://github.com/roddhjav/pass-tomb/releases/download/v1.3/pass-tomb-1.3.tar.gz.asc
gpg --recv-keys 06A26D531D56C42D66805049C5469996F0DF68EC
gpg --verify pass-tomb-1.3.tar.gz.asc
```

## Contribution

Feedback, contributors, pull requests are all very welcome.

[github-link]: https://github.com/roddhjav/pass-tomb
[workflow]: https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Froddhjav%2Fpass-tomb%2Fbadge%3Fref%3Dmaster&style=flat-square
[action]: https://actions-badge.atrox.dev/roddhjav/pass-tomb/goto?ref=master
[gitlab]: https://gitlab.com/roddhjav/pass-tomb/badges/master/pipeline.svg?style=flat-square
[gitlab-link]: https://gitlab.com/roddhjav/pass-tomb/pipelines
[coverage]: https://img.shields.io/coveralls/roddhjav/pass-tomb/master.svg?style=flat-square
[coverage-link]: https://coveralls.io/github/roddhjav/pass-tomb
[quality]: https://img.shields.io/codacy/grade/1c58ea63487a4b82874b05220d500c60/master.svg?style=flat-square
[quality-link]: https://www.codacy.com/app/roddhjav/pass-tomb
[release]: https://img.shields.io/github/release/roddhjav/pass-tomb.svg?maxAge=600&style=flat-square
[release-link]: https://github.com/roddhjav/pass-tomb/releases/latest
[repology-link]: https://repology.org/project/pass-tomb/versions

[pass]: https://www.passwordstore.org/
[Tomb]: https://www.dyne.org/software/tomb/
[github-tomb]: https://github.com/dyne/Tomb
[pujol.io-tomb]: https://pujol.io/blog/tomb-with-gpg-keys/
[keys]: https://pujol.io/keys
[aur]: https://aur.archlinux.org/packages/pass-tomb
[releases]: https://github.com/roddhjav/pass-tomb/releases
[keybase]: https://keybase.io/roddhjav
