# Garuda Linux ISO profiles

[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

## Found any issue?

- If any packaging issues occur, don't hesitate to report them via our issues section of our PKGBUILD repo.
  You can click [here](https://gitlab.com/garuda-linux/pkgbuilds/-/issues/new) to create a new one.
- If issues concerning the configurations and settings occur, please open a new issue on this repository.
  Click [here](https://gitlab.com/garuda-linux/tools/iso-profiles/-/issues/new) to start the process.

## How to contribute?

We highly appreciate contributions of any sort! 😊 To do so, please follow these steps:

- [Create a fork of this repository](https://gitlab.com/garuda-linux/tools/iso-profiles/-/forks/new).
- Clone your fork locally ([short git tutorial](https://rogerdudler.github.io/git-guide/)).
- Add the desired changes to PKGBUILDs or source code.
- Commit using a [conventional commit message](https://www.conventionalcommits.org/en/v1.0.0/#summary) and push any changes back to your fork.
  This is crucial as it allows our CI to generate changelogs easily.
  - The [commitizen](https://github.com/commitizen-tools/commitizen) application helps with creating a fitting commit message.
  - You can install it via [pip](https://pip.pypa.io/) as there is currently no package in Arch repos: `pip install --user -U Commitizen`.
  - Then proceed by running `cz commit` in the cloned folder.
- [Create a new merge request at our main repository](https://gitlab.com/garuda-linux/tools/iso-profiles/-/merge_requests/new).
- Check if any of the pipeline runs fail and apply eventual suggestions.

We will then review the changes and eventually merge them.

## How to use the repo?

### Default profile.conf

```sh
# use multilib packages; x86_64 only
# multilib="true"

# use extra packages as defined in pkglist to activate a full profile
# extra="false"

################ install ################

# default displaymanager: none
# supported; lightdm, sddm, gdm, lxdm, mdm
# displaymanager="none"

# Set to false to disable autologin in the livecd
# autologin="true"

# nonfree xorg drivers
# nonfree_mhwd="true"

# possible values: grub;systemd-boot
# efi_boot_loader="grub"

# configure calamares for netinstall
# netinstall="false"

# configure calamares to use chrootcfg instead of unpackfs; default: unpackfs
# chrootcfg="false"

# use geoip
# geoip="true"

# unset defaults to given values
# names must match systemd service names
# enable_systemd=('bluetooth' 'cronie' 'ModemManager' 'NetworkManager' 'org.cups.cupsd')
# disable_systemd=()

# unset defaults to given values,
# names must match openrc service names
# enable_openrc=('acpid' 'bluetooth' 'elogind' 'cronie' 'cupsd' 'dbus' 'syslog-ng' 'NetworkManager')
# disable_openrc=()

# unset defaults to given values
# addgroups="video,power,disk,storage,optical,network,lp,scanner,wheel"

# the same workgroup name if samba is used
# smb_workgroup="garuda"

################# live-session #################

# unset defaults to given value
# hostname="garuda"

# unset defaults to given value
# username="garuda"

# unset defaults to given value
# password="garuda"

# the login shell
# defaults to bash
# login_shell=/bin/bash

# unset defaults to given values
# names must match systemd service names
# services in enable_systemd array don't need to be listed here
# enable_systemd_live=('garuda-live' 'mhwd-live' 'pacman-init' 'mirrors-live')

# unset defaults to given values,
# names must match openrc service names
# services in enable_openrc array don't need to be listed here
# enable_openrc_live=('garuda-live' 'mhwd-live' 'pacman-init' 'mirrors-live')
```

### New package list tags

```sh
>openrc
>systemd

>i686
>x86_64
>multilib

>nonfree_default
>nonfree_i686
>nonfree_x86_64
>nonfree_multilib

>garuda

>basic
>extra
```

### Packages-Root

- Contains root image packages
- Ideally no Xorg

### Packages-Desktop

- Contains the desktop image packages
- Desktop environment packages go here

### Packages-Mhwd

- Contains the MHWD driver packages repo

### Packages-Live

- Contains packages you only want in live session but not installed on the target system with installer
- Default files are in shared folder and can be symlinked or defined in a real file

### Buildiso can be configured to use custom repos

- create a user-repos.conf

```sh
${profile_dir}/user-repos.conf
```

**Add only your repos to user-repos.conf!**

**Important**: Only online repos is allowed in the user-repos.conf. Buildiso will fail on file-based repos.
