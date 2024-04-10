#!/bin/bash
if [ -z $home_dir ];
then
    source ./env_set.sh
else
    source $home_dir/scripts/env_set.sh
fi
print_line header MATHLIBRARY
math_usage()
{
    echo "
    Usage: ./mathlib.sh --math=<math_lib_vendor>\\
                        --math_version=<math_version>\\
                        --math_compiler=<math_compiler>\\
                        --math_compiler_version=<math_compiler_version>
    Builds the math library of specified math library vendor with compiler specifications.

    Example 1 : ./mathlib.sh --math=aocl --math_version=3.2.0 --math_compiler=aocc --math_compiler_version=3.2.0
    Example 2 : ./mathlib.sh --math=aocl --math_version=4.0 --math_compiler=aocc --math_compiler_version=4.0.0
    Example 3 : ./mathlib.sh --math=aocl --math_version=3.2.0 --math_compiler=gcc --math_compiler_version=11.2
    Example 4 : ./mathlib.sh --math=aocl --math_version=4.0 --math_compiler=gcc --math_compiler_version=11.2

    <math_lib_vendor>       :   specify the math libarary vendors to build.
                                The following the the availbale math library vendors:
                                aocl
                                intel-mkl
                                intel-oneapi-mkl

    <math_version>          :   specify the version of <math_library_vendor>
                                for aocl as <math_lib_vendor>, the following are the available versions:
                                    4.0
                                    3.2.0

    <math_compiler>         :   specify the compiler to build <math_library_vendor>.
                                The following are the available compilers:
                                aocc
                                gcc
                                intel-oneapi-compilers-classic
                                NOTE: for intel-mkl or intel-oneapi-mkl, prefer to specify <math_compiler> which is
                                      available in spack compilers.

    <math_compiler_version> :   specify the version of <math_compiler> to build <math_lib_vendor>

    "

}
while [ $# -gt 0 ];
do
    load $1
    shift 1
done
if [[ -z ${math} ]] || [[ -z ${math_version} ]] || [[ -z ${math_compiler} ]] || [[ -z ${math_compiler_version} ]] ;
then
    math_usage
    exit
fi
if [[ ${math} == "aocl" ]] && [[ ${math_compiler} == "gcc" ]];
then
    export math_compiler_version="11.2"
fi

if [ -f ${home_dir}/module_files/${math}/${math_version}/${math_compiler}/${math_compiler_version} ];
then
    print_line found MATHLIBRARY
    module load ${math}/${math_version}/${math_compiler}/$math_compiler_version
else
    mkdir -p $home_dir/log_files/$math/$math_version/$math_compiler
    {
    print_line not_found MATHLIBRARY
    print_line hostname $hostname
    lock_check "${math}/${math_version}/${math_compiler}/$math_compiler_version"
    if [ -f ${home_dir}/module_files/${math}/${math_version}/${math_compiler}/${math_compiler_version} ];
    then
        print_line found MATHLIBRARY
        module load ${math}/${math_version}/${math_compiler}/$math_compiler_version
        exit
    fi
    locked_files=""
    trap 'unlock "$locked_files"' EXIT SIGINT
    lock "${math}/${math_version}/${math_compiler}/$math_compiler_version "
    rm -rf ${home_dir}/module_files/${math}/${math_version}/${math_compiler}/${math_compiler_version}
    if [ ${math} == "aocl" ];
    then
        export DIR_STR=aocl/${math_version}/${math_compiler}
        mkdir -p $home_dir/apps/${DIR_STR}
        if [  -f "${home_dir}/source_codes/aocl/aocl-linux-${math_compiler}-${math_version}.tar.gz" ];
        then
            echo "aocl-linux-${math_compiler}-${math_version}.tar.gz source file found "
        else
                echo "aocl-linux-${math_compiler}-${math_version}.tar.gz source file not found"
                exit
        fi
        cd $home_dir/source_codes/aocl
        echo " Building ${math}"
        tar -xf "aocl-linux-${math_compiler}-${math_version}.tar.gz"
        cd aocl-linux-${math_compiler}-${math_version}
        ./install.sh -t $home_dir/apps/${DIR_STR} -i lp64
        mv $home_dir/apps/${DIR_STR}/${math_version} $home_dir/apps/${DIR_STR}/${math_compiler_version}
        if [ -d "$home_dir/apps/${DIR_STR}/${math_compiler_version}/lib" ];
        then
            print_line success AOCL
        else
            print_line failed AOCL
            exit
        fi
        mkdir -p ${home_dir}/module_files/${DIR_STR}

        echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "\tAdds ${math} to your environment variables"
}
module-whatis "loads ${DIR_STR}/${math_compiler_version}"
set             libhome            $home_dir/apps/${DIR_STR}/${math_compiler_version}
setenv          AOCLROOT           \$libhome
setenv          MATHLIBROOT        \$libhome
prepend-path    AOCL_PATH          \$libhome
prepend-path    INCLUDE            \$libhome/include
prepend-path    CPATH              \$libhome/include
prepend-path    C_INCLUDE_PATH     \$libhome/include
prepend-path    CPLUS_INCLUDE_PATH \$libhome/include
prepend-path    LIBRARY_PATH       \$libhome/lib
prepend-path    LD_LIBRARY_PATH    \$libhome/lib
" > ${home_dir}/module_files/${DIR_STR}/${math_compiler_version}
    elif [ ${math} == "intel-mkl" ] || [ ${math} == "intel-oneapi-mkl" ];
    then
        print_line spack MKL
        if [[ $math_compiler == "intel-oneapi-compilers-classic" ]];
        then
            spack_math_compiler=intel
        else
            spack_math_compiler=$math_compiler
        fi
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
        compilers=$(spack compilers)
        compilers=$(echo $compilers | grep "Available compilers" | grep ${spack_math_compiler}@${math_compiler_version})
        if [[ -z $compilers ]];
        then
            echo "${spack_math_compiler}@${math_compiler_version} compiler not found in spack"
            echo "Installing compiler"
            available_cmp=$(spack compilers)
            available_cmp=$(echo $available_cmp | grep "Available compilers")
            if [[ -z $available_cmp ]];
            then
                echo "Base compiler is not found in spack, adding base compiler"
                spack compiler find
            fi
            spack install -vvv ${math_compiler}@${math_compiler_version}
            cur_dir=$PWD
            spack cd -i ${math_compiler}@${math_compiler_version}
            spack compiler add $PWD
            compilers=$(spack compilers)
            compilers=$(echo $compilers | grep "Available compilers" | grep ${spack_math_compiler}@${math_compiler_version})
            if [[ -z $compilers ]];
            then
                echo "Compiler installation failed. Exiting ..."
                exit
            fi
            cd $cur_dir
        fi
        math_valid=$(spack list ${math})
        if [[ -z $math_valid ]];
        then
            echo "$math is not available in spack. Exit..."
            exit
        fi
        math_version_valid=$(spack versions ${math})
        math_version_valid=$(echo $math_version_valid | grep $math_version)
        if [[ -z $math_version_valid ]];
        then
            echo "$math_version_valid math version is not found in spack"
            exit
        fi
        echo "Installing Math through spack ......."
        spack install -vvv ${math}@${math_version}%${spack_math_compiler}@${math_compiler_version}
        math_installation_confirm=$(spack find ${math}@${math_version}%${spack_math_compiler}@${math_compiler_version} | grep "\-------")
        if [[ -z $math_installation_confirm ]];
        then
            echo "MATH Installation failed. Exiting ..."
            exit
        else
            echo "MKL is installed with spack Creating module file for MKL"
            cur_dir=$PWD
            spack cd -i ${math}@${math_version}%${spack_math_compiler}@${math_compiler_version}
            cd mkl
            cd $math_version
            mkl_root=$PWD
            cd $cur_dir
            mkdir -p $home_dir/module_files/$math/$math_version/$math_compiler
            if [ -d $mkl_root/lib ];
                then
                    print_line success MKL    
                else
                    print_line failed MKL
                    exit
            fi
            echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "\tAdds ${math} to your environment variables"
}
module-whatis "loads ${math}/${math_version}/${math_compiler}/${math_compiler_version}"
set             libhome            $mkl_root
setenv          MKLROOT           \$libhome
setenv          MATHLIBROOT        \$libhome
prepend-path    MKL_PATH          \$libhome
prepend-path    INCLUDE            \$libhome/include
prepend-path    CPATH              \$libhome/include
prepend-path    C_INCLUDE_PATH     \$libhome/include
prepend-path    CPLUS_INCLUDE_PATH \$libhome/include
prepend-path    LIBRARY_PATH       \$libhome/lib/intel64
prepend-path    LD_LIBRARY_PATH    \$libhome/lib/intel64
" > ${home_dir}/module_files/${math}/${math_version}/${math_compiler}/${math_compiler_version}
        fi
    fi
    unlock "$locked_files"
    } 2>&1 | tee $home_dir/log_files/${math}/${math_version}/${math_compiler}/${mpi_compiler_version}_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

