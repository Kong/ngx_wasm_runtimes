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

This script is supposed to be invoked from an ARM machine. Note that this takes
a significant amount of memory and disk space: if you are launching a virtual
machine to perform this task, start it with at least 32 GB of RAM and 32 GB of
disk to be on the safe side (the 8 GB you often get by default is not enough).

The script will attempt to `docker push` the newly-built image. For the image
upload to succeed, prior to running the script you need to login with `docker
login ghcr.io -u <username>`, using a GitHub token that contains the
`write:packages` scope as a password ([see more detailed docs
here][gh_token_docs]). Your GitHub user also needs to have [write
access][gh_write_package] to the [ngx-wasm-runtimes][ngx_wasm_runtimes_pkg]
package.

[gh_token_docs]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic
[gh_write_package]: https://stackoverflow.com/a/72585915
[ngx_wasm_runtimes_pkg]: https://github.com/orgs/Kong/packages/container/package/ngx-wasm-runtimes
