FROM wasmx-build-ubuntu

ARG ARCH
ARG OS
ARG RUNTIME
ARG RUNTIME_VERSION
ARG NGX_WASM_MODULE

ENV TARGET_NAME=$RUNTIME-$VERSION-$OS-$ARCH
ENV PACKAGE_NAME=ngx_wasm_runtime-$RUNTIME-$RUNTIME_VERSION-$OS-$ARCH.tar.gz

COPY ./$NGX_WASM_MODULE /wasmx

RUN /wasmx/util/runtimes/$RUNTIME.sh /wasmx/work/$TARGET_NAME $RUNTIME_VERSION $ARCH && \
    mkdir -p /wasmx/dist && \
    cd /wasmx/work && \
    tar czvpf /wasmx/dist/$PACKAGE_NAME $TARGET_NAME
