# About this copy

This repository is a copy of **Garuda Linux's ISO profiles**, taken from
<https://gitlab.com/garuda-linux/tools/iso-profiles>. All the work here is
Garuda Linux's, released under the GNU GPL v3 (see `LICENSE`). The only
additions are this file and `.github/workflows/sync-from-garuda.yml`.

## What is in it

The recipe Garuda uses to build its installable ISO images: for each
edition, the list of packages to install and the files to place in the
live system.

| Folder       | Editions                                                                 |
|--------------|--------------------------------------------------------------------------|
| `garuda/`    | cinnamon, dr460nized, dr460nized-gaming, gnome, hyprland, i3, kde-lite, mokka, sway, xfce |
| `community/` | cosmic                                                                   |
| `shared/`    | Settings and files used by every edition                                 |

## Staying up to date

The GitHub Action in `.github/workflows/sync-from-garuda.yml` runs every
day. It merges Garuda's latest `master` into this `master` and copies
Garuda's other branches and tags across. You can also run it by hand from
the **Actions** tab: open "Sync from Garuda" and click **Run workflow**.

## Building an ISO

You need an Arch Linux or Garuda Linux machine and several GB of free disk
space and downloads. The ISO is built by Garuda's own tool,
[garuda-tools](https://gitlab.com/garuda-linux/tools/garuda-tools), which
reads the profiles in this repository. Follow that project's instructions
and point it at the edition you want, for example `dr460nized`.

## Just want to install Garuda?

Download the official ISO from <https://garudalinux.org/downloads>. ISO
files are 3–4 GB, too big to keep in a git repository.
