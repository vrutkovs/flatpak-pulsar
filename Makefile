all: prepare-repo install-deps build clean-cache update-repo copy-to-export

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	for i in $(shell seq 0 20); do \
		flatpak --user install -y flathub org.freedesktop.Sdk/x86_64/21.08 org.electronjs.Electron2.BaseApp/x86_64/21.08 && break; \
	done

build:
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Nightly build of Pulsar, `date`" \
		${EXPORT_ARGS} app io.github.pulsar-edit.yaml

clean-cache:
	rm -rf .flatpak-builder/build

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 repo
	echo 'gpg-verify-summary=false' >> repo/config
	rm -rf repo/.lock

copy-to-export:
	rm -rf export && mkdir export
	cp -rf repo/ export/
