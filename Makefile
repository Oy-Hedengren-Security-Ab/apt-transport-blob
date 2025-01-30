DEB_HOST_ARCH := $(shell dpkg-architecture -q DEB_HOST_ARCH)
DEB_VERSION := $(shell ./deb-version)

.FORCE:
.PHONY: .FORCE all deb-build deb-install deb-lint debian/changelog

all: deb-build deb-lint deb-install

deb-build: deb-build-amd64 deb-build-arm64

deb-build-%: .FORCE debian/changelog
	dpkg-buildpackage -a $* -B
# dpkg-buildpackage doesn't provide an option to change the output dir.
	mv ../*.deb .

deb-install:
	dpkg -i *_$(DEB_VERSION)_$(DEB_HOST_ARCH).deb

deb-lint: deb-lint-amd64 deb-lint-arm64

deb-lint-%: .FORCE
	lintian \
		--cfg .lintianrc \
		--fail-on error \
		--fail-on warning \
		*_$(DEB_VERSION)_$*.deb

debian/changelog:
	rm -f debian/changelog
	env \
		EDITOR=true \
		EMAIL="Oy Hedengren Security Ab <hedengren@hedengren.fi>" \
		dch \
		--create \
		--empty \
		--newversion "$(DEB_VERSION)" \
		--package apt-transport-blob \
		"Current release."
