% pass-tomb(1)
% pass tomb was written by Alexandre Pujol (alexandre@pujol.io)
% February 2024

# NAME

pass-tomb — A **pass**(1) extension that helps to keep the whole tree of password encrypted inside a **tomb**(1)

# SYNOPSIS

**pass tomb** [*options…*] *gpgid...*

**pass open** [*options…*]

**pass close** [*options…*]

**pass timer** [*options…*]

# DESCRIPTION

Due to the structure of **pass**(1), file- and directory names are not encrypted in the password store. **pass tomb** provides a convenient solution to put your password store in a **tomb**(1) and then keep your password tree encrypted when you are not using it.

It uses the same GPG key to encrypt passwords and tomb, therefore you don't need to manage more key or secret. Moreover, you can ask pass-tomb to automatically close your store after a given time.

**The new workflow is the following:**

1. Create a password tomb with **pass tomb**. It creates a new tomb and opens it in *~/.password-store*. Then it initializes the password repository with the same GPG key.
2. Use pass as usual.
3. When finished close the password tomb: **pass close**.
4. To use pass again, you need to open the password tomb: **pass open**.

# COMMAND

## **pass tomb** [ *--no-init*, *-n* ] [ *--timer=time*, *-t time* ] [ *--path=subfolder*, *-p subfolder* ] [*--force*, *-f*] [*--size=size*, *-s size*] *gpg-id...*

Create and initialize a new password tomb. This command must be run first, before a password store can be used.

*gpg-id*

:   Refer to the encryption key of both passwords and tomb. Multiple gpg-ids may be specified, in order to encrypt the tomb and each password with multiple ids.


`--path=subfolder`, `-p subfolder`

:   Specific password tomb using *gpg-id* or a set of gpg-ids is assigned for that specific subfolder of the password store.


`--=subfolder`, `-p subfolder`

`--no-init`, `-n`

:   Do not initialize the password store. By default, pass-tomb initializes the password store with the same key(s) it generated the tomb. The purpose of this option is to let the user free to initialize the password store with a different key or set of keys.

`--timer=time`, `-t time`

:   Close the password store automatically systemd timer after a given time. This time will be saved in the *.timer* file present in the store.

`--force`, `-f`

:   Force the password store to be mounted or created even if a plain text swap is present. Make sure you know what you are doing if you force an operation.

`--size`, `-s`

:   Specify the tomb size in MB.


## **pass open** [ *--timer=time*, *-t time* ] [*--force*, *-f*] [*--key=key*, *-k key*] [*subfolder*]

Open a password tomb. If a *.timer* file is present in the store, a systemd timer will be initialized.

*subfolder*

:   The password store will be opened in the subfolder.

`--timer=time`, `-t time`

:   Close the store automatically closed using a systemd timer after a given time. If a '.time' file was already present in the store, this time will be updated. Multiple timer can be used in the same time.

`--force`, `-f`

:   Force the password store to be mounted or created even if a plain text swap is present. Make sure you know what you are doing if you force an operation.

`--key`, `-k`

:   Specify the path to the password tomb key.

`--file`

:   Specify the path to the password tomb. 


## **pass close** [*store*]

Close a password tomb.

*store*

:   If *store* is specified, pass close will try to close this store.

## **pass timer** [*store*]

Show timer status.

*store*

:   If *store* is specified, pass timer will show the status for this store.

# OPTIONS

**`-n`, `--no-init`**

:   Do not initialize the password store

**`-t`, `--timer`**

:   Close the store after a given time

**`-p`, `--path`**

:   Create the store for that specific subfolder

**`-k`, `--key`**

:   Specify the tomb key to open the store

**`--file`**

:   Specify the tomb file to open 

**`-s`, `--size`**

:   Specify the tomb size in MB

**`-f`, `--force`**

:   Force the tomb operations (i.e. even if swap is active)

**`-q`, `--quiet`**

:   Be quiet

**`-v`, `--verbose`**

:   Be verbose

**`-d`, `--debug`**

:   Print tomb debug messages

**`--unsafe`**

:   Speed up tomb creation (for testing purposes only)

**`-V`, `--version`**

:   Show version information

**`-h`, `--help`**

:   Show usage message.


# EXAMPLES

**Create a new password tomb**

```sh
zx2c4@laptop ~ $ pass tomb Jason@zx2c4.com
 (*) Your password tomb has been created and opened in ~/.password-store.
 (*) Password store initialised for Jason@zx2c4.com.
  .  Your tomb is: ~/.password.tomb
  .  Your tomb key is: ~/.password.key.tomb
  .  You can now use pass as usual.
  .  When finished, close the password tomb using 'pass close'.
```

**Open a password tomb**

```sh
zx2c4@laptop ~ $ pass open
 (*) Your password tomb has been opened in ~/.password-store.
  .  You can now use pass as usual.
  .  When finished, close the password tomb using 'pass close'.
```

**Close a password tomb**

```sh
zx2c4@laptop ~ $ pass close
 (*) Your password tomb has been closed.
  .  Your passwords remain present in ~/.password.tomb.
```

**Create a new password tomb and set a timer**

```sh
zx2c4@laptop ~ $ pass tomb Jason@zx2c4.com --timer=1h
 (*) Your password tomb has been created and opened in ~/.password-store.
 (*) Password store initialised for Jason@zx2c4.com.
  .  Your tomb is: ~/.password.tomb
  .  Your tomb key is: ~/.password.key.tomb
  .  You can now use pass as usual.
  .  This password store will be closed in 1h

zx2c4@laptop ~ $ pass open
 (*) Your password tomb has been opened in ~/.password-store.
  .  You can now use pass as usual.
  .  This password store will be closed in 1h
```

**Open a password tomb and set a timer**

```sh
zx2c4@laptop ~ $ pass open
 (*) Your password tomb has been opened in ~/.password-store.
  .  You can now use pass as usual.
  .  This password store will be closed in 10min
```

# ENVIRONMENT VARIABLES

*PASSWORD_STORE_TOMB*

:   Path to tomb executable

*PASSWORD_STORE_TOMB_FILE*

:   Path to the password tomb, by default *~/.password.tomb*

*PASSWORD_STORE_TOMB_KEY*

:   Path to the password tomb key file by default *~/.password.key.tomb*

*PASSWORD_STORE_TOMB_SIZE*

:   Password tomb size in MB, by default *10*

# SEE ALSO

**pass(1)**, **tomb(1)**, **pass-import(1)**, **pass-update(1)**, **pass-audit(1)**, **pass-otp(1)**
