#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
NGX_WASM_DIR=${NGX_WASM_DIR:-"$(
    cd $(dirname $(dirname ${0}))
    pwd -P
)"}


OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case $ARCH in
    x86_64)  ARCH='amd64';;
    aarch64) ARCH='arm64';;
esac

get_data_from_action() {
    local block="$1"
    local search_k="$2"
    local search_v="$3"
    local target_k="$4"
    local action="$NGX_WASM_DIR/.github/workflows/release.yml"

    # a good-enough YAML-parsing state machine for finding
    # a key-value pair in a block given another key-value pair
    awk '
    function check() {
        if (!in_block) return;
        if (sv == "'$search_v'" && tv != "") { print tv; exit; }
    }

    /'$block':/ { in_block=1; next; }
    /(name|matrix|runs-on|env|steps|if|needs):/ { check(); in_block=0; }
    // { if (!in_block) next; }

    /^[[:space:]]*-/             { check(); sv=""; tv=""; }
    /^[-[:space:]]*'$search_k':/ { sv=$NF; }
    /^[-[:space:]]*'$target_k':/ { tv=$NF; }
    ' "$action"
}

V8_VERSION=${V8_VERSION:-$(get_data_from_action env RUNTIME v8 VERSION)}

if [ -z "$V8_VERSION" ]; then
    echo "V8 version could not be detected, please set V8_VERSION environment variable." >&2
    exit 1
fi

NGX_WASM_MODULE=ngx_wasm_module
DIR_NGX_WASM_MODULE=$PWD/$NGX_WASM_MODULE

download_ngx_wasm_module() {
    echo "Cloning ngx_wasm_module reposiory..."

    if [[ ! -d "$DIR_NGX_WASM_MODULE" ]]; then
      git clone https://github.com/kong/ngx_wasm_module.git $NGX_WASM_MODULE
    fi
}

build_wasmx_build_image() {
    echo "Building wamx-build-image..."

    if [[ -z "$(docker images -q wasmx-build-ubuntu)" ]]; then
        pushd $DIR_NGX_WASM_MODULE
            make act-build
        popd
    fi
}

build_packaged_v8_image() {
    echo "Building ghcr.io/kong/ngx-wasm-runtimes:v8-$V8_VERSION-$OS-$ARCH"

    docker build \
        -t ghcr.io/kong/ngx-wasm-runtimes:v8-$V8_VERSION-$OS-$ARCH \
        --platform linux/$ARCH \
        --build-arg NGX_WASM_MODULE=$NGX_WASM_MODULE \
        --build-arg OS=$OS \
        --build-arg ARCH=$ARCH \
        --build-arg RUNTIME=v8 \
        --build-arg RUNTIME_VERSION=$V8_VERSION \
        -f ./assets/Dockerfile . && \
    docker push ghcr.io/kong/ngx-wasm-runtimes:v8-$V8_VERSION-$OS-$ARCH
}

if [[ ! "$ARCH" == "arm64" ]]; then
    echo "Currently, this script should be invoked only in ARM linux" >&2
    exit 1
else
    download_ngx_wasm_module
    build_wasmx_build_image
    build_packaged_v8_image
fi

