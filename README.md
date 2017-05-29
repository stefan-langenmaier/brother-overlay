This is a fork to make it work with the brother dcp9055cdn.
Original repo is here: https://github.com/stefan-langenmaier/brother-overlay/

# How to use this overlay

## with local overlays

[Local overlays](https://wiki.gentoo.org/wiki/Overlay/Local_overlay) should be managed via `/etc/portage/repos.conf/`.
To enable this overlay make sure you are using a recent Portage version (at least `2.2.14`), and create a `/etc/portage/repos.conf/brother-overlay.conf` file containing precisely:

```
[brother-overlay]
location = /usr/local/portage/brother-overlay
sync-type = git
sync-uri = https://github.com/madImpulse/brother-overlay.git
priority=9999
```

Afterwards, simply run `emerge --sync`, and Portage should seamlessly make all our ebuilds available.

# Installation

After performing those steps, the following should work (or any other package from this overlay):

	sudo emerge -av net-print/brother-dcp9055cdn-bin
