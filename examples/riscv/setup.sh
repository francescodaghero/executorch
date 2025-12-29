#!/usr/bin/env bash
set -u

########################
### Hardcoded constants
########################
script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
et_dir=$(realpath $script_dir/../..)
ARCH="$(uname -m)"
OS="$(uname -s)"
root_dir="${script_dir}/riscv-scratch"
enable_baremetal_toolchain=1
target_toolchain=""

# Figure out if setup.sh was called or sourced and save it into "is_script_sourced"
(return 0 2>/dev/null) && is_script_sourced=1 || is_script_sourced=0

# Global scope these so they can be set later
toolchain_url=""
toolchain_dir=""
toolchain_md5_checksum=""

# Load logging helpers early so option parsing can emit status messages.
source "$et_dir/backends/riscv/scripts/utils.sh"


# List of supported options and their descriptions
OPTION_LIST=(
  "--root-dir Path to scratch directory"
  "--enable-baremetal-toolchain Enable baremetal toolchain setup"
  "--help Display help"
)


########
### Functions
########

function print_usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo
    echo "Available options:"
    for entry in "${OPTION_LIST[@]}"; do
        opt="${entry%% *}"
        desc="${entry#* }"
        printf "  %-40s %s\n" "$opt" "$desc"
    done
    echo
    echo "Supplied args: $*"
}

function check_options() {
    while [[ "${#}" -gt 0 ]]; do
        case "$1" in
            --root-dir)
                # Only change default root dir if the script is being executed and not sourced.
                if [[ $is_script_sourced -eq 0 ]]; then
                    root_dir=${2:-"${root_dir}"}
                fi

                if [[ $# -ge 2 ]]; then
                    shift 2
                else
                    print_usage "$@"
                    exit 1
                fi
                ;;
            --enable-baremetal-toolchain)
                enable_baremetal_toolchain=1
                shift
                ;;
            --target-toolchain)
                # Only change default root dir if the script is being executed and not sourced.
                if [[ $is_script_sourced -eq 0 ]]; then
                    target_toolchain=${2:-"${target_toolchain}"}
                fi

                if [[ $# -ge 2 ]]; then
                    shift 2
                else
                    print_usage "$@"
                    exit 1
                fi
                ;;
            --help)
                print_usage "$@"
                exit 0
                ;;
            *)
                print_usage "$@"
                exit 1
                ;;
        esac
    done
}

function setup_root_dir() {
    mkdir -p "${root_dir}"
    root_dir=$(realpath "${root_dir}")
    log_step "main" "Prepared root dir at ${root_dir}"
    setup_path_script="${root_dir}/setup_path"
}

function create_setup_path(){
    cd "${root_dir}"

    clear_setup_path
    log_step "path" "Generating setup path scripts at ${setup_path_script}"

    if [[ "${enable_baremetal_toolchain}" -eq 1 ]]; then
        setup_path_toolchain
    fi

   log_step "path" "Update PATH by sourcing ${setup_path_script}.{sh|fish}"
}



########
### main
########

# script is not sourced! Lets run "main"
if [[ $is_script_sourced -eq 0 ]]; then
    set -e

    check_options "$@"

    # Import utils
    source $et_dir/backends/riscv/scripts/toolchain_utils.sh

    log_step "main" "Checking platform and OS"
    check_platform_support
    check_os_support

    cd "${script_dir}"

    # Setup the root dir
    setup_root_dir
    cd "${root_dir}"

    log_step "options" \
             "root=${root_dir}, target-toolchain=${target_toolchain:-<default>}"
    log_step "options" \
             "toolchain=${enable_baremetal_toolchain}" 

    # Setup toolchain
    if [[ "${enable_baremetal_toolchain}" -eq 1 ]]; then
        log_step "toolchain" "Configuring baremetal toolchain (${target_toolchain:-gnu})"
        # Select appropriate toolchain
        select_toolchain
        setup_toolchain
    fi

    # Create the setup_path.sh used to create the PATH variable for shell
    create_setup_path

    # Setup the TOSA reference model and serialization dependencies

    log_step "main" "Setup complete"
    exit 0
fi
