#!/bin/bash
if [ -z $home_dir ];
then
    source ./env_set.sh
else
    source $home_dir/scripts/env_set.sh
fi
print_line header COMPILER
compiler_usage()
{
    echo "
    Usage          :    ./compiler.sh --compiler_name=<compiler>\\
                        --compiler_version=<version>

    Builds the compiler with specified version.

    Example 1      :    ./compiler.sh --compiler_name=aocc --compiler_version=4.0.0
    Example 2      :    ./compiler.sh --compiler_name=aocc --compiler_version=3.2.0

    <compiler>     :    specify the name of compiler to build.The following are the available compilers:
                        aocc
                        gcc
                        intel-oneapi-compilers-classic

    <version>      :     specify the version of <compiler>
                         for "aocc" as <compiler> the following are the supported versions:
                            3.2.0
                            4.0.0

    "

}
while [ $# -gt 0 ];
do
    load $1
    shift 1
done
if [[ -z $compiler_name ]] || [[ -z $compiler_version ]] ;
then
        compiler_usage
        exit
fi
if [ -f $home_dir/module_files/$compiler_name/$compiler_version ];
then
        print_line found COMPILER
        module load $compiler_name/$compiler_version
else
        mkdir -p $home_dir/log_files/$compiler_name
        {
        print_line not_found COMPILER
        print_line hostname $hostname
        lock_check "$compiler_name/$compiler_version"
        if [ -f $home_dir/module_files/$compiler_name/$compiler_version ];
        then
            print_line found COMPILER
            module load $compiler_name/$compiler_version
            exit
        fi
        locked_files=""
        lock "$compiler_name/$compiler_version"
        trap 'unlock "$locked_files"' EXIT SIGINT
        rm -rf $home_dir/module_files/$compiler_name/$compiler_version
        if [ $compiler_name == "aocc" ];
        then
                echo "Adding AOCC compiler"
                mkdir -p $home_dir/apps/aocc
                cd $home_dir/source_codes/aocc
                if [[ -f aocc-compiler-$compiler_version.tar ]];
                then
                        echo "aocc tar file is exist ..."
                else
                        echo "aocc-compiler-$compiler_version.tar file not found."
                        exit
                fi
                tar -xf aocc-compiler-$compiler_version.tar -C $home_dir/apps/aocc
                cd $home_dir/apps/aocc
                mv aocc-compiler-$compiler_version $compiler_version
                cd $compiler_version
                ./install.sh
                if [ -d $home_dir/apps/aocc/$compiler_version/bin ];
                then
                        print_line success COMPILER         
                else
                        print_line failed COMPILER
                        exit
                fi
                mkdir -p $home_dir/module_files/aocc
                echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    global version AOCChome
    puts stderr "\tAOCC \n"
    puts stderr "\tloads AOCC compiler setup \n"
}

module-whatis "loads AOCC compiler setup "
set             root               $home_dir/apps/aocc/$compiler_version
setenv          COMPILERROOT       $home_dir/apps/aocc/$compiler_version
setenv          AOCCROOT           $home_dir/apps/aocc/$compiler_version
prepend-path    PATH                \$root/bin
prepend-path    LIBRARY_PATH           \$root/lib32
prepend-path    LIBRARY_PATH           \$root/lib
prepend-path    LD_LIBRARY_PATH        \$root/lib32
prepend-path    LD_LIBRARY_PATH        \$root/lib
prepend-path    C_INCLUDE_PATH         \$root/include
prepend-path    CPLUS_INCLUDE_PATH     \$root/include
" > $home_dir/module_files/aocc/$compiler_version
        fi
        if [ $compiler_name == "gcc" ];
        then
                mkdir -p $home_dir/apps/gcc/$compiler_version
                mkdir -p $home_dir/source_codes/gcc/$compiler_version
                cd $home_dir/source_codes/gcc/$compiler_version
                rm -rf *
                wget https://ftp.gnu.org/gnu/gcc/gcc-${compiler_version}/gcc-${compiler_version}.tar.gz
                tar -xf gcc-${compiler_version}.tar.gz
                cd gcc-${compiler_version}
                gcc_cur_dir=$PWD
                cd $home_dir/scripts
                bash $home_dir/scripts/compiler.sh --compiler_name=aocc --compiler_version=4.0.0
                cd $gcc_cur_dir
                module load aocc/4.0.0
                module load mpfr/4.2.0
                module load mpc/1.2.1
                module load gmp/6.2.1
                module load m4/1.4.19
                echo "mpfr : $MPFRROOT"
                echo "mpc :  $MPCROOT"
                echo "gmp :  $GMPROOT"
                echo "m4  :  $M4ROOT"
                ./configure --prefix=$home_dir/apps/gcc/$compiler_version CC=clang CXX=clang++ FC=flang --with-gmp=$GMPROOT --with-mpfr=$MPFRROOT --with-mpc=$MPCROOT
                rc=${PIPESTATUS[0]}
                [[ $rc -eq 0 ]] || exit $rc
                make -j
                rc=${PIPESTATUS[0]}
                [[ $rc -eq 0 ]] || exit $rc
                make install
                rc=${PIPESTATUS[0]}
                [[ $rc -eq 0 ]] || exit $rc

                if [ -f $home_dir/apps/gcc/$compiler_version/bin/gcc ];
                then
                        print_line success COMPILER
                else
                        print_line failed COMPILER
                        exit
                fi
                mkdir -p $home_dir/module_files/gcc
                echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    global version AOCChome
    puts stderr "\tGCC \n"
    puts stderr "\tloads GCC compiler setup \n"
}
module-whatis "loads GCC compiler setup"
set    root     $home_dir/apps/gcc/$compiler_version
setenv  GCCROOT     \$root
setenv  COMPILERROOT   \$root
prepend-path    PATH    \$root/bin
prepend-path    MANPATH   \$root/man
prepend-path    INCLUDE   \$root/include
prepend-path    LD_LIBRARY_PATH  \$root/lib
prepend-path    LD_LIBRARY_PATH  \$root/lib64
set prereq1  mpfr/4.2.0
set prereq2  mpc/1.2.1
set prereq3  gmp/6.2.1
set prereq4   m4/1.4.19

if { [module-info mode load] } {
        if { ! [ is-loaded \$prereq1 ] } {
            module load \$prereq1
        }
        if { ! [ is-loaded \$prereq2 ] } {
            module load \$prereq2
        }
        if { ! [ is-loaded \$prereq3 ] } {
            module load \$prereq3
        }
        if { ! [ is-loaded \$prereq4 ] } {
            module load \$prereq4
        }
}

if { [module-info mode unload ] } {
        if { [ is-loaded \$prereq1 ] } {
            module unload \$prereq1
        }
        if { [ is-loaded \$prereq2 ] } {
            module unload \$prereq2
        }
        if { [ is-loaded \$prereq3 ] } {
            module unload \$prereq3
        }
        if { [ is-loaded \$prereq4 ] } {
            module unload \$prereq4
        }
}

" > $home_dir/module_files/gcc/$compiler_version
        fi
        if [[ $compiler_name == "intel-oneapi-compilers-classic" ]];
        then
            print_line spack INTEL-ONEAPI-COMPILERS-CLASSIC
            if [[ -d $home_dir/spack ]];
            then
                echo "In $home_dir spack is already exist Installing mkl with spack"
            else
                echo "spack is not found in $home_dir"
                cur_dir=$PWD
                cd $home_dir
                git clone https://github.com/spack/spack.git
                cd $cur_dir
            fi
            if [[ -z $(which spack) ]] && [[ -f $home_dir/spack/share/spack/setup-env.sh ]];
            then
                source $home_dir/spack/share/spack/setup-env.sh
            else
                echo "Check spack dir and Environment"
            fi
            available_cmp=$(spack compilers)
            available_cmp=$(echo $available_cmp | grep "Available compilers")
            if [[ -z $available_cmp ]];
            then
                echo "Base compiler is not found in spack, adding base compiler"
                spack compiler find
            fi
            compiler_version_valid=$(spack versions ${compiler_name})
            compiler_version_valid=$(echo $compiler_version_valid | grep $compiler_version)
            if [[ -z $compiler_version_valid ]];
            then
                echo "$compiler_version compiler version is not found in spack"
                exit
            fi
            echo "Installing compiler thropugh spack ......."
            spack install -vvv ${compiler_name}@${compiler_version}
            compiler_installation_confirm=$(spack find ${compiler_name}@${compiler_version})
            if [[ -z $compiler_installation_confirm ]];
            then
                echo "${compiler_name}@${compiler_version} Compiler Installation failed. Exiting ..."
                exit
            else
                echo "${compiler_name}@${compiler_version} Compiler installed creating module file"
                cur_dir=$PWD
                spack cd -i ${compiler_name}@${compiler_version}
                export icc_inst_root=$PWD
                spack compiler add $PWD
                cd $cur_dir
                if [ -f $icc_inst_root/bin/icc ];
                then
                        print_line success COMPILER
                else
                        print_line failed COMPILER
                        exit
                fi
                mkdir -p $home_dir/module_files/$compiler_name
                echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "\tAdds ${compiler_name} to your environment variables"
}
module-whatis "loads ${compiler_name}/${compiler_version}"
set         icc_root             $icc_inst_root
setenv      COMPILERROOT         \$icc_root
setenv      ICCROOT              \$icc_root
prepend-path    PATH             \$icc_root/bin
prepend-path    LD_LIBRARY_PATH   \$icc_root/lib
prepend-path    LD_LIBRARY_PATH   \$icc_root/lib/x64
prepend-path    LD_LIBRARY_PATH   \$icc_root/compiler/lib/intel64_lin
prepend-path    MANPATH             \$icc_root/man/common/man1
" > $home_dir/module_files/$compiler_name/$compiler_version
            fi
        fi
        unlock "$locked_files"
        } 2>&1 | tee $home_dir/log_files/$compiler_name/${compiler_version}_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

