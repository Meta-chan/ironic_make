# Welcome to Ironic Make!
Ironic Make is an unusual build system. It...
 - Consists of only one small file – `build.bat`
 - Automatically detects installed compilers
 - Requires no installed programs (except of compilers of course)
 - Has human-readable, cross-compiler build options
 - Is very user-friendly. Nothing can be simpler than double-clicking `build.bat`, can it?

# Structure
 - `compile.bat` \- Ironic Make with **reduced functionality**. It can automatically identify compilers and compile simple programs. To find compiler- and project-dependent commands search for `REM COMPILE`.
 - `build.bat` \- Ironic Make with **full functionality**. It is also a single file, but it creates `ironic_make.exe` and `ironic_compilers` after first run. It consists of three parts:
   - Batch job (Search for `REM BATCH`)
   - Source of `ironic_make.exe` (Search for `REM SOURCE`)
   - Makefile (Search for `REM MAKEFILE`)
 - `ironic_make.c` \- source code of `ironic_make.exe`. Will be deleted as soon as `ironic_make.exe` is compiled.
 - `ironic_make.exe` \- main part of the build system. Reads `Makefile` section of `build.bat` and performs building.
 - `ironic_compilers` \- file used by `ironic_make.exe` to store information about detected compilers.
 - `ironic_make_dev.c` \- `ironic_make.c` used for development.
 
# `build.bat` command line options
Although `build.bat` and `ironic_simple_build.bat` are designed to be called from GUI, they may be called from command line. In this form, they accept options:
 - Nothing for first found compiler and architecture
 - `vs` \- for Visual Studio compiler
 - `gcc` \- for GNU compiler
 - `x86` \- for x86 architecture
 - `amd64` \- for amd64 architecture
 - Everything else for help

# Makefile syntax
The syntax is similar to GNU `make`, but much simpler. It has:
 - Targets and dependencies. Note target and dependencies can contain `/`, `*` and `%` characters. Example: `temp/%.obj : source/%.cpp`.
 - Custom variables with standard `${}` syntax.
 - Comments with standard `#` syntax.
 - Automatic read-only variables:
   - `$%` for `%` pattern
   - `$#` for exit code of last command
   - `OS` for OS type. May be `Windows` (other reserved for future use)
   - `CC` for compiler type. May be `gcc` or `vs`
   - `ARCH` for compiler architecture. May be `x86` or `amd64`
   - `$T` for all target
   - `$D` for first all dependencies
   - `$F` for first dependency
   - `T`, `D` and `F` can also have suffixes: `F` for full path to `build.bat` directory, `R` for relative path to file directory, `N` for bare name, and `E` for extension. The full target file name will be then `$(TFRNE)`. Only continuous and ordered sequences from `F`, `R`, `N` and `E` are automatic variables
 - Built-in commands:
   - `if`, `else`, `elseif`, `end` for conditional execution. Syntax: typical C operators, `exist` and `defined` functions
   - `native` for calling OS's shell. Syntax: one-line command
   - `compile` for compilation. It's options:
     - `--include_dir DIR` \- Includes search directory for compiler.
     - `--link_dir DIR` \- Includes search directory for linker.
     - `--link NAME` \- Makes linker link some library.
     - `--define MACRO[=DEFINITION]` \- Defines macro. Note that `DEFINITION` may be quoted, with `\"` and `\\` processed inside quotation.
     - `--output NAME` \- Name of output file. If the name has no extension, the default for selected compiler will be used.
     - `--native OPTION` \- Native option for some compiler. Note that `OPTION` may be quoted, with `\"` and `\\` processed inside quotation.
     - `--target OPTION` \- Defines what target file does the compiler produce. Options are:
       - `executable` for executable file (default)
       - `object` for object file
       - `shared` for shared library
       - `static` for static library 
       - `assembly` for assembly
       - `source` for preprocessed source code
     - `--optimize OPTION` \- Defines optimization of compiler. Options are:
       - `speed` for speed optimization (default)
       - `debug` for debug experience
       - `size` for size optimization
       - `max` for all optimization compiler can offer

# `ironic_make.exe` comamnd line options
If you want to use `ironic_make.exe` separately from `build.bat`, you may want to know about it's options:
 - Nothing for default build
 - `vs`, `gcc`, `x86`, `amd64` same as for `build.bat`
 - `version` for version
 - `compile` for direct access to `compile` function, may be used after compiler and architecture options
 - Everything else for help

# Supported compilers
 - Microsoft Visual Studio
 - MinGW

# Help
If your favourite compiler is not supported, you are tired of writing native instructions, you found a bug or just need help \- feel free to contact me in any form.

###### P.S. My code is not dirty, it is alternatively clean.