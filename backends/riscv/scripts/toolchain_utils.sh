#!/usr/bin/env bash
# Important to check for unset variables since this script is always sourced from setup.sh
set -u

# Check if the script is being sourced
(return 0 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo "Error: This script must be sourced."
    exit 1
fi

script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
source "${script_dir}/utils.sh"

function gcc_select_toolchain() {
    if [[ "${ARCH}" == "x86_64" ]] ; then
        toolchain_url="https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-2/riscv-toolchain-15-x86_64-lin.tar.gz"
        toolchain_dir="toolchain"
        toolchain_md5_checksum=""
    elif [[ "${ARCH}" == "aarch64" ]] || [[ "${ARCH}" == "arm64" ]] ; then
        if [[ "${OS}" == "Darwin" ]]; then
            toolchain_url="https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-2/riscv-toolchain-15-arm64-mac.zip"
            toolchain_dir="toolchain"
            toolchain_md5_checksum=""
        elif [[ "${OS}" == "Linux" ]]; then
            toolchain_url="https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-2/riscv-toolchain-15-aarch64-lin.tar.gz"
            toolchain_dir="toolchain"
            toolchain_md5_checksum=""
        fi
    else
        # This should never happen, it should be covered by setup.sh but catch it anyway
        log_step "toolchain" "Error: Unsupported architecture ${ARCH}"
        exit 1
    fi
}


function select_toolchain() {
    gcc_select_toolchain
    log_step "toolchain" "Selected ${toolchain_dir} for ${ARCH}/${OS}"
}

function setup_toolchain() {
    # TODO: Change this to a rv32 multilib toolchain 
    # Download and install the pico2 toolchain (default is arm-none-eabi)
    cd "${root_dir}"
    if [[ ! -e "${toolchain_dir}.tar.gz" ]]; then
        log_step "toolchain" "Downloading ${toolchain_dir} toolchain"
        # TODO: This is not working for Darwin atm
        curl --output "${toolchain_dir}.tar.gz" -L "${toolchain_url}"
    fi

    log_step "toolchain" "Installing ${toolchain_dir} toolchain"
    rm -rf "${toolchain_dir}"
    mkdir -p "${toolchain_dir}"
    ls
    tar xf "${toolchain_dir}.tar.gz" -C "${toolchain_dir}"
}

function setup_path_toolchain() {
    toolchain_bin_path="$(cd ${toolchain_dir}/bin && pwd)"
    append_env_in_setup_path PATH ${toolchain_bin_path}
}
