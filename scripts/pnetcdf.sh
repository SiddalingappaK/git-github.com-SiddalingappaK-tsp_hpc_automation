#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                       PNETCDF BUILD SCRIPT                                                #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"
pnetcdf_usage()
{
    echo "
    Usage: ./pnetcdf.sh [OPTIONS] [ARGS]
    Eg:    ./pnetcdf.sh --pnetcdf_version=<pnetcdf_version>\\
                     --pnetcdf_mpi=<pnetcdf_mpi>\\
                     --pnetcdf_mpi_version=<pnetcdf_mpi_version>\\
                     --pnetcdf_mpi_compiler=<pnetcdf_mpi_compiler>\\
                     --pnetcdf_mpi_compiler_version =pnetcdf_mpi_compiler_version>\\
                     --pnetcdf_mpi_flags=<pnetcdf_mpi_flags>\\
                     --pnetcdf_flags=<pnetcdf_flags>
    Builds the pnetcdf Module of specified version with specified compiler specifications, mpi specifications.

    Example: ./pnetcdf.sh --pnetcdf_version=1.11.2 --pnetcdf_mpi=openmpi --pnetcdf_mpi_version=4.1.1 \\
             --pnetcdf_mpi_compiler=aocc --pnetcdf_mpi_compiler_version=4.0.0
             --pnetcdf_mpi_flags
             --pnetcdf_flags
    <pnetcdf_version>:                  specify the version of pnetcdf
                                        Recommended version : 1.11.2
                                        Latest version : 1.10.9, 1.8.23, 1.10.10

    <pnetcdf_mpi>:                      specify the mpi to build pnetcdf.The following are the available mpi:
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <pnetcdf_mpi_version>:              specify the version of <pnetcdf_mpi>

    <pnetcdf_mpi_compiler>:             specify the compiler to build <pnetcdf_mpi>.
                                        For the two <pnetcdf_mpi>s intel-mpi and intel-oneapi-mpi, <pnetcdf_mpi_compiler> will be used
                                        as 'wrapper compiler'.
                                        The following are the available compilers:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <pnetcdf_mpi_compiler_version>:     specify the version of MPI used to build pnetcdf
                                        for <pnetcdf_mpi_compiler> as "aocc" the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <pnetcdf_mpi_flags> [optional]:     specify the mpi flags to build <pnetcdf_mpi>
                                        default mpi_flags for <mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <pnetcdf_flags> [optional]:         specify the pnetcdf flags to build pnetcdf
                                        default pnetcdf_flags for <pnetcdf_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'

                                        "

}
if [ -z $home_dir ];  
then  
    source ./env_set.sh  
else  
    source $home_dir/scripts/env_set.sh 
fi 
n_arg=0
while [ $# -gt 0 ];
do
    load $1
    n_arg=$[$n_arg+1]
    shift 1
done
if [[ -z $pnetcdf_version ]]  || [[ -z $pnetcdf_mpi ]] || [[ -z $pnetcdf_mpi_version ]] || [[ -z $pnetcdf_mpi_compiler ]] || [[ -z $pnetcdf_mpi_compiler_version ]] ;
then
    pnetcdf_usage
    exit
fi
min_options=5
if [[ $n_arg -gt ${min_options} ]];
then
    load_check_flags $[$n_arg-${min_options}] pnetcdf_mpi_flags pnetcdf_flags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        pnetcdf_usage
        exit
    fi
fi
build_packname=pnetcdf-${pnetcdf_version}
pnc_packname=${build_packname}
echo " --- PNCPACKNAME : ${pnc_packname}"
date=$(date | perl -pe 's/\s+/_/g;s/_$//;s/://g')

DIR_STR=pnetcdf/${pnetcdf_version}/${pnetcdf_mpi}/${pnetcdf_mpi_version}/${pnetcdf_mpi_compiler}
build_check $DIR_STR/$pnetcdf_mpi_compiler_version "$pnetcdf_flags"
export rebuilt=$?

if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                    pnetcdf-${pnetcdf_version} IS FOUND IN MODULES LOADING MODULE                          #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/${pnetcdf_mpi_compiler_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                        pnetcdf-${pnetcdf_version} IS NOT PRESENT IN MODULES                               #"
    echo "#                                 Building pnetcdf-${pnetcdf_version}                                       #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                                       HOSTNAME:    $(hostname)                                            #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    ##### CPU Model ##########
    cpu_model=$(grep 'model name' /proc/cpuinfo | head -n1 | awk -F': ' '{print $2}' | awk '{print $3}')
    if [[ $cpu_model == *"9"* ]];
    then
        echo "Genoa"
        CPU_ARC="-march=znver4"
    elif [[ $cpu_model == *"7"* ]]; then
        echo "Milan"
        CPU_ARC="-march=znver3"
    elif [[ $cpu_model == *"8"* ]]; then
        echo "Intel"
        CPU_ARC="-march=core-avx2"
    else
        echo "Unknown Series"
        CPU_ARC="-march=auto"
    fi

    export PNETCDF_SOURCE=${home_dir}/source_codes/pnetcdf
    export PNETCDF_BUILD=${home_dir}/apps/$DIR_STR/${pnetcdf_mpi_compiler_version}

    #########   Creating pnetcdf DIR    ########
    mkdir -p $PNETCDF_SOURCE
    mkdir -p $PNETCDF_BUILD
    cd ${PNETCDF_SOURCE}
    #rm -rf ${PNETCDF_SOURCE}/*
    rm -rf ${PNETCDF_BUILD}/*

    ##### Load MPI module with specified falg #####
    if [[ ${pnetcdf_mpi_flags} ]];
    then
        bash ${home_dir}/scripts/mpi.sh --mpi=$pnetcdf_mpi --mpi_version=$pnetcdf_mpi_version --mpi_compiler=$pnetcdf_mpi_compiler --mpi_compiler_version=$pnetcdf_mpi_compiler_version --mpi_flags=$pnetcdf_mpi_flags
    else
        bash ${home_dir}/scripts/mpi.sh --mpi=$pnetcdf_mpi --mpi_version=$pnetcdf_mpi_version --mpi_compiler=$pnetcdf_mpi_compiler --mpi_compiler_version=$pnetcdf_mpi_compiler_version
    fi

    module load $pnetcdf_mpi/$pnetcdf_mpi_version/$pnetcdf_mpi_compiler/$pnetcdf_mpi_compiler_version

    ####~~~~~~~~~~~~~~~ Wrapper Compiler ~~~~~~~~~~~~~~~~~~~~####
    case $pnetcdf_mpi in
    openmpi)
            export CC=mpicc
            export FC=mpif90
            export CXX=mpiCC
            ;;
    intelmpi)
            export CC=mpiicc
            export FC=mpif90
            export CXX=mpicxx
            ;;
    esac


    ########### Building PNETCDF ############
    if [[ -z $pnetcdf_flags ]];
    then
        #export hpl_flags="-O3 -funroll-loops -march=skylake-avx512 -qopenmp"
        export build_type=default
    else
        export build_type=custom
    fi
    pnc_archive=${pnc_packname}.tar.gz

    if [  -f "${PNETCDF_SOURCE}/${pnc_archive}" ]
    then
        echo "${pnc_archive} source file found in ${PNETCDF_SOURCE}"
    else
        echo "Downloading ${pnc_packname}"
        wget -P ${PNETCDF_SOURCE} https://parallel-netcdf.github.io/Release/$pnc_archive
    fi

    cd ${PNETCDF_BUILD}
    rm -rf ${pnc_packname}

    echo " Building ${pnc_packname} in $PWD "

    tar xvf ${PNETCDF_SOURCE}/${pnc_archive}

    cd ${pnc_packname}
    #Configuring PNETCDF library

    ./configure --disable-cxx --enable-fortran=yes --enable-shared --prefix=${PNETCDF_BUILD} 2>&1 | tee  config_log.0

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make -j $(nproc) 2>&1| tee make_log.1

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make install -j $(nproc) 2>&1 | tee  make_install_log.2

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc


    ############## Checking if build successful or not ###############
    if [ -d "${PNETCDF_BUILD}" ] && [ -e "${PNETCDF_BUILD}/lib/libpnetcdf.a" ]
    then
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                                ${pnc_packname} BUILD SUCCESSFUL                                           #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
            export PATH=${PNETCDF_BUILD}/bin:${PATH}
            export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PNETCDF_BUILD}/lib
            export INCLUDE=${INCLUDE}:${PNETCDF_BUILD}/include

            ##########  Create module Dir ############
            mkdir -p ${home_dir}/module_files/$DIR_STR
            echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
                puts stderr "\tAdds pnetcdf to your environment variables"
            }
            module-whatis \"sets the HPLROOT path
            Build flags:       $pnetcdf_flags
            Build type:        $build_type\"
            set             root           ${PNETCDF_BUILD}
            setenv          PNETCDF_ROOT               \$root
            setenv          PNETCDF_DIR                \$root
            setenv          PNETCDF                    \$root
            prepend-path    PATH                       \$root/bin
            prepend-path    LD_LIBRARY_PATH            \$root/lib
            prepend-path    LIBRARY_PATH               \$root/lib
            prepend-path    C_INCLUDE_PATH             \$root/include
            setenv          BUILD_MPI                ${pnetcdf_mpi}
            " > ${home_dir}/module_files/${DIR_STR}/${pnetcdf_mpi_compiler_version}
            module load ${DIR_STR}/${pnetcdf_mpi_compiler_version}

    else
            echo "${pnc_packname} installtion failed. Please reinstall ${pnc_packname} again".
            echo " --- Please check : ${PNETCDF_BUILD}/$buildlog ---"
            cd ${home_dir}
            exit 1
    fi

    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$pnetcdf_mpi_compiler_version${date}.log

fi

