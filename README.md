# How to use this overlay

## with local overlays

[Local overlays](https://wiki.gentoo.org/wiki/Overlay/Local_overlay) should be managed via `/etc/portage/repos.conf/`.
To enable this overlay make sure you are using a recent Portage version (at least `2.2.14`), and create a `/etc/portage/repos.conf/brother-overlay.conf` file containing precisely:

```
[brother-overlay]
location = /usr/local/portage/brother-overlay
sync-type = git
sync-uri = https://github.com/stefan-langenmaier/brother-overlay.git
priority=9999
```

Afterwards, simply run `emerge --sync`, and Portage should seamlessly make all our ebuilds available.

## with layman

Invoke the following:

	layman -f -a brother-overlay
	
Or read the instructions on the [Gentoo Wiki](http://wiki.gentoo.org/wiki/Layman#Adding_custom_repositories).

# Installation

After performing those steps, the following should work (or any other package from this overlay):

	sudo emerge -av media-gfx/brother-scan3-bin
