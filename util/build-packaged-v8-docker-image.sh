OS=$(uname -s | tr '[:upper]' '[:lower:]')
ARCH=$(uname -m)
case $ARCH in
    x86_64)  ARCH='amd64';;
    aarch64) ARCH='arm64';;
esac

V8_VERSION=10.5.8

NGX_WASM_MODULE=ngx_wasm_module
DIR_NGX_WASM_MODULE=$PWD/$NGX_WASM_MODULE


download_ngx_wasm_module() {
    echo "Cloning ngx_wasm_module reposiory..."

    if [[ ! -d "$DIR_NGX_WASM_MODULE" ]]; then
      git clone git@github.com:Kong/ngx_wasm_module.git $NGX_WASM_MODULE
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
    echo "Building V8..."

    docker build \
        -t ghcr.io/kong/ngx-wasm-runtimes:v8-$V8_VERSION-$OS-$ARCH \
        --platform linux/$ARCH \
        --build-arg NGX_WASM_MODULE=$NGX_WASM_MODULE \
        --build-arg OS=$OS \
        --build-arg ARCH=$ARCH \
        --build-arg RUNTIME=v8 \
        --build-arg RUNTIME_VERSION=$V8_VERSION \
        -f ./assets/Dockerfile .

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
