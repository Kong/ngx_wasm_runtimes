# ngx_wasm_runtimes
Github Action for building Wasm runtimes for WasmX

## Notes on ARM Binaries

Compiling ARM binaries on GH hosted runners is only possible by emulating the
compilation process. Building V8 in a emulated environment takes much longer
than usual, in fact, more than 6 hours -- exceeding the execution time limit of
a GHA job running on GHA runners.

Since it's not possible to build V8 ARM binaries on GHA runners, the CI job that
uploads ARM artifacts leverages a pre built Docker image containing the ARM
deliverables. The job simply extracts a `.tar.gz` file representing the release
artifact and uploads it to GH.

### Pre-built Docker image

The Docker image used in the CI job is built on top of `wasmx-build-ubuntu` and
simply adds two layers to the image, one copying `ngx_wasm_module` source code
and the other actually building and packaging V8.

The image can be built by invoking `./util/build-packaged-v8-docker-image.sh`.
This script is supposed to be invoked from an ARM machine.
