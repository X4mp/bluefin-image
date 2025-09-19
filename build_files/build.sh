#!/bin/bash

set -ouex pipefail

### Install packages

echo "::group:: Copy Files"
cp /ctx/packages.json /tmp/packages.json
echo "::endgroup::"

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

echo "::group:: Enable Coprs"
readarray -t ENALED_REPOS < <(jq -r "[(.all | (select(.repos != null).repos)[])] \
                    | sort | unique[]" /tmp/packages.json)
# Enable Copr Repos
if [[ "${#ENALED_REPOS[@]}" -gt 0 ]]; then
    for repo in "${ENALED_REPOS[@]}"; do
        dnf5 -y copr enable "$repo"
    done
else
    echo "No coprs to enable."
fi
echo "::endgroup::"

echo "::group:: Install Packages"
readarray -t INCLUDED_PACKAGES < <(jq -r "[(.all | (select(.packages != null).packages)[])] \
                    | sort | unique[]" /tmp/packages.json)
# Install Packages
if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y install "${INCLUDED_PACKAGES[@]}"
else
    echo "No packages to install."
fi

# Disable Copr Repos so they don't end up in the final repo
if [[ "${#ENALED_REPOS[@]}" -gt 0 ]]; then
    for repo in "${ENALED_REPOS[@]}"; do
        dnf5 -y copr disable "$repo"
    done
else
    echo "No coprs to disable."
fi
echo "::endgroup::"

echo "::group:: Install brew Packages"
readarray -t BREW_PACKAGES < <(jq -r "[(.all | (select(.brew != null).brew)[])] \
                    | sort | unique[]" /tmp/packages.json)
# Install Packages
if [[ "${#BREW_PACKAGES[@]}" -gt 0 ]]; then
    for pkg in "${BREW_PACKAGES[@]}"; do
        brew install "$pkg"
    done
else
    echo "No brew packages to install."
fi
echo "::endgroup::"


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
