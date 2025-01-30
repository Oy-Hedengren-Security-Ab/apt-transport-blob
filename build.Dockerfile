FROM rust:bullseye
SHELL ["/bin/bash", "-c"]
RUN set -ex; \
    \
    dpkg --add-architecture amd64; \
    dpkg --add-architecture arm64; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        binutils-{aarch64,x86-64}-linux-gnu \
        build-essential \
        crossbuild-essential-{amd64,arm64} \
        debhelper-compat \
        devscripts \
        dh-cargo \
        dh-make \
        libssl-dev:{amd64,arm64} \
        lintian \
        # Necessary for automatic dependency resulution.
        {libc6,libssl1.1}:{amd64,arm64} \
    ; \
    rm -rf /var/lib/apt/lists/*
# Prevents unnecessary toolchain downloads.
WORKDIR /mnt
RUN --mount=source=rust-toolchain.toml,target=/mnt/rust-toolchain.toml \
    \
    rustup target add {aarch64,x86_64}-unknown-linux-gnu
RUN set -ex; \
    \
    # Use image-provided Cargo, as Bullseye doesn't provide Rustup.
    ln -fs /usr/local/cargo/bin/cargo /usr/bin/cargo; \
    # Prevent using nightly-only features.
    sed -i 's/"-Zavoid-dev-deps", //g' /usr/share/cargo/bin/cargo; \
    \
    git config --add --system safe.directory /mnt
