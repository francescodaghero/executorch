#!/usr/bin/env bash

set -eu
script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
et_root_dir=$(cd ${script_dir}/../../.. && pwd)
et_root_dir=$(realpath ${et_root_dir})
toolchain=riscv32-unknown-elf-gcc
setup_path_script=${et_root_dir}/examples/riscv/riscv-scratch/setup_path

set -x
cd "${et_root_dir}"

( set +x ;
    echo "--------------------------------------------------------------------------------" ;
    echo "Build ExecuTorch target libs ${build_type} into '${et_build_dir}'" ;
    echo "--------------------------------------------------------------------------------" )

# Build
cmake -DCMAKE_TOOLCHAIN_FILE=${toolchain_cmake} \
-DCMAKE_BUILD_TYPE=Release \
-DEXECUTORCH_BUILD_DEVTOOLS=$build_devtools \
--preset riscv-baremetal -B${et_build_dir}

parallel_jobs="$(get_parallel_jobs)"

cmake --build ${et_build_dir} -j"${parallel_jobs}" --target install --config ${build_type} --

set +x

echo "[$(basename $0)] Generated static libraries for ExecuTorch:"
find ${et_build_dir} -name "*.a" -exec ls -al {} \;
