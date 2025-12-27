set(TARGET_CPU
    "rv32imc"
    CACHE STRING "Target CPU"
)
string(TOLOWER ${TARGET_CPU} CMAKE_SYSTEM_PROCESSOR)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER "riscv32-unknown-elf-gcc")
set(CMAKE_CXX_COMPILER "riscv32-unknown-elf-g++")
set(CMAKE_ASM_COMPILER "riscv32-unknown-elf-gcc")
set(CMAKE_LINKER "riscv32-unknown-elf-ld")

set(CMAKE_EXECUTABLE_SUFFIX ".elf")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Select C/C++ version
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

set(GCC_CPU ${CMAKE_SYSTEM_PROCESSOR})
#TODO 
string(REPLACE "rv32imc" "rv32imc" GCC_CPU ${GCC_CPU})

# Compile options
add_compile_options(
  -march=${GCC_CPU} "$<$<CONFIG:DEBUG>:-gdwarf-3>"
  "$<$<COMPILE_LANGUAGE:CXX>:-fno-unwind-tables;-fno-rtti;-fno-exceptions>"
  -fdata-sections -ffunction-sections
)

# Compile defines
add_compile_definitions("$<$<NOT:$<CONFIG:DEBUG>>:NDEBUG>")

# Link options
add_link_options(-march=${GCC_CPU})

# Set floating point unit
if(CMAKE_SYSTEM_PROCESSOR MATCHES "\\+nofp")
  set(FLOAT soft)
else()
  set(FLOAT hard)
endif()

if(FLOAT)
  add_compile_options(-mfloat-abi=${FLOAT})
  add_link_options(-mfloat-abi=${FLOAT})
endif()

add_link_options(LINKER:--nmagic,--gc-sections)

# Compilation warnings
add_compile_options(
  # -Wall -Wextra -Wcast-align -Wdouble-promotion -Wformat
  # -Wmissing-field-initializers -Wnull-dereference -Wredundant-decls -Wshadow
  # -Wswitch -Wswitch-default -Wunused -Wno-redundant-decls
  -Wno-error=deprecated-declarations -Wno-error=shift-count-overflow -Wno-psabi
)