#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                          WRF BUILD SCRIPT                                                 #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"

wrf_usage()
{
    echo "
    Usage: ./wrf_build.sh [OPTIONS] [ARGS]
    Eg:    ./wrf_build.sh --wrf_version=<wrf_version>\\
                        --wrf_compiler=<wrf_compiler>\\
                        --wrf_compiler_version=<wrf_compiler_version>\\
                        --wrf_mpi=<wrf_mpi>\\
                        --wrf_mpi_version=<wrf_mpi_version>\\
                        --wrf_mpi_compiler=<wrf_mpi_compiler>\\
                        --wrf_mpi_compiler_version=<wrf_mpi_compiler_version>\\
                        --wrf_mpi_flags=<wrf_mpi_flags>\\
                        --wrf_flags=<wrf_flags>\\
                        --wrf_jemalloc_version=<wrf_jemalloc_version>\\
                        --wrf_jemalloc_compiler=<wrf_jemalloc_compiler>\\
                        --wrf_jemalloc_compiler_version=<wrf_jemalloc_compiler_version>\\
                        --wrf_jemalloc_flags=<wrf_jemalloc_flags>\\
                        --wrf_hdf5_version=<hdf5_version>\\
                        --wrf_hdf5_mpi=<hdf5_mpi>\\
                        --wrf_hdf5_mpi_version=<hdf5_mpi_version>\\
                        --wrf_hdf5_mpi_compiler=<hdf5_mpi_compiler>\\
                        --wrf_hdf5_mpi_compiler_version=<hdf5_mpi_compiler_version>\\
                        --wrf_hdf5_mpi_flags=<hdf5_mpi_flags>\\
                        --wrf_hdf5_flags=<hdf5_flags>\\
                        --wrf_pnetcdf_version=<pnetcdf_version>\\
                        --wrf_pnetcdf_mpi=<pnetcdf_mpi>\\
                        --wrf_pnetcdf_mpi_version=<pnetcdf_mpi_version>\\
                        --wrf_pnetcdf_mpi_compiler=<pnetcdf_mpi_compiler>\\
                        --wrf_pnetcdf_mpi_compiler_version=<pnetcdf_mpi_compiler_version>\\
                        --wrf_pnetcdf_mpi_flags=<pnetcdf_mpi_flags>\\
                        --wrf_pnetcdf_flags=<pnetcdf_flags>\\
                        --wrf_netcdfc_version=<netcdfc_version>\\
                        --wrf_netcdff_version=<netcdff_version>\\
                        --wrf_netcdf_mpi=<netcdf_mpi>\\
                        --wrf_netcdf_mpi_version=<netcdf_mpi_version>\\
                        --wrf_netcdf_mpi_compiler=<netcdf_mpi_compiler>\\
                        --wrf_netcdf_mpi_compiler_version=<netcdf_mpi_compiler_version>\\
                        --wrf_netcdf_mpi_flags=<netcdf_mpi_flags>\\
                        --wrf_netcdf_hdf5_version=<netcdf_hdf5_version>\\
                        --wrf_netcdf_pnetcdf_version=<netcdf_pnetcdf_version>\\
                        --wrf_netcdf_flags=<netcdf_flags>

    Builds the WRF Application with specified version and specified compiler specifications, mpi specifications and dependency.

    Example: ./wrf_build.sh --wrf_version=4.2.1 --wrf_compiler=aocc --wrf_compiler_version=4.0.0 --wrf_mpi=openmpi --wrf_mpi_version=4.1.1 --wrf_mpi_compiler=aocc --wrf_mpi_compiler_version=4.0.0 --wrf_jemalloc_version=5.2.1 --wrf_jemalloc_compiler=aocc --wrf_jemalloc_compiler_version=4.0.0\\
             --wrf_hdf5_version=1.10.8 --wrf_hdf5_mpi=openmpi --wrf_hdf5_mpi_version=4.1.1 --wrf_hdf5_mpi_compiler=aocc --wrf_hdf5_mpi_compiler_version=4.0.0 --wrf_pnetcdf_version=1.11.2 --wrf_pnetcdf_mpi=openmpi --wrf_pnetcdf_mpi_version=4.1.1 --wrf_pnetcdf_mpi_compiler=aocc --wrf_pnetcdf_mpi_compiler_version=4.0.0\\
             --wrf_netcdfc_version=4.7.4 --wrf_netcdff_version=4.5.3 --wrf_netcdf_mpi=openmpi --wrf_netcdf_mpi_version=4.1.1--wrf_netcdf_mpi_compiler=aocc --wrf_netcdf_mpi_compiler_version=4.0.0 --wrf_netcdf_hdf5_version=1.10.8 --wrf_netcdf_pnetcdf_version=1.11.2
             --wrf_mpi_flags
             --wrf_flags
             --wrf_jemalloc_flags
             --wrf_hdf5_mpi_flags
             --wrf_hdf5_flags
             --wrf_pnetcdf_mpi_flags
             --wrf_pnetcdf_flags
             --wrf_netcdf_mpi_flags
             --wrf_netcdf_flags

    <wrf_version>:                      specify the version of WRF
                                        Recommended version : 4.2.1
                                        Latest version : 4.0.1, 4.0.2, 4.0.3 ,4.0.4, 4.1, 4.1.1 - 4.1.3, 4.2, 4.2.1 - 4.2.3, 4.3, 4.3.1 - 4.3.3, 4.4, 4.4.1 - 4.4.3, 4.5, 4.5.1
                                        All version :  3.0.1.1, 3.0.1, 3.1, 3.1.1, 3.2, 3.2.1, 3.3, 3.3.1, 3.4, 3.4.1, 3.5.1, 3.5, 3.6, 3.6.1, 3.7, 3.7.1, 3.8 3.9, 3.9.1
    
    <wrf_compiler>:                     specify the compiler to build wrf
                                        The following are the avialble compilers :
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <wrf_compiler_version>:             specify the version to build <wrf_compiler>
                                        for "aocc" as <wrf_compiler> the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <wrf_mpi>:                          specify the mpi to build wrf
                                        The following are the available mpi options :
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <wrf_mpi_version>:                  specify the version to build <wrf_mpi>

    <wrf_mpi_compiler>:                 specify the compiler to build <wrf_mpi>
                                        The following are the available compiler names :
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic   

    <wrf_mpi_compiler_version>:         specify the version to build <wrf_mpi_compiler>
                                        for <openfoam_mpi_compiler> as "aocc" the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <wrf_mpi_flags>:                    Specify the flags to buid <wrf_mpi>
                                        default flags for <wrf_mpi>
                                            aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                            gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                            intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <wrf_flags>:                        specify the flags to build <wrf>.
                                        default flags for wrf
                                            aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                            gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                            intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <wrf_jemalloc_version>:             specify the version of jemalloc
                                        Recommended version : 5.2.1
                                        Latest version : 5.3.0

    <wrf_jemalloc_compiler>:            specify the mpi to build jemalloc.The following are the available mpi:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <wrf_jemalloc_compiler_version>:    Specify the version to build <wrf_jemalloc_compiler>
                                        for "aocc" as <wrf_jemalloc_compiler> the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <wrf_jemalloc_flags> [optional]:    specify the jemalloc flags to build jemalloc
                                        default jemalloc_flags for <wrf_jemalloc_compiler>
                                        aocc:   '-O3  -march=znver4 -fopenmp'
                                        gcc:    '-O3  -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -march=skylake-avx512 -qopenmp'

    <wrf_hdf5_version>:                 specify the version of hdf5
                                        Recommended version : 1.10.8
                                        Latest version : 1.10.9, 1.8.23, 1.10.10

    <wrf_hdf5_mpi>:                     specify the mpi to build hdf5.The following are the available mpi:
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <wrf_hdf5_mpi_version>:             specify the version of <wrf_hdf5_mpi>

    <wrf_hdf5_mpi_compiler>:            specify the compiler to build <wrf_hdf5_mpi>.
                                        For the two <wrf_hdf5_mpi>s intel-mpi and intel-oneapi-mpi, <wrf_hdf5_mpi_compiler> will be used
                                        as 'wrapper compiler'.
                                        The following are the available compilers:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <wrf_hdf5_mpi_compiler_version>:    specify the version of MPI used to build hdf5
                                        for "aocc" as <wrf_hdf5_mpi_compiler> the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <wrf_hdf5_mpi_flags> [optional]:    specify the mpi flags to build <wrf_hdf5_mpi>
                                        default mpi_flags for <wrf_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <wrf_hdf5_flags> [optional]:        specify the hdf5 flags to build hdf5
                                        default hdf5_flags for <wrf_hdf5_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'
    
    <wrf_pnetcdf_version>:              specify the version of pnetcdf
                                        Recommended version : 1.11.2
                                        Latest version : 1.10.9, 1.8.23, 1.10.10

    <wrf_pnetcdf_mpi>:                  specify the mpi to build pnetcdf.The following are the available mpi:
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <wrf_pnetcdf_mpi_version>:          specify the version of <wrf_pnetcdf_mpi>

    <wrf_pnetcdf_mpi_compiler>:         specify the compiler to build <wrf_pnetcdf_mpi>.
                                        For the two <wrf_pnetcdf_mpi>s intel-mpi and intel-oneapi-mpi, <wrf_pnetcdf_mpi_compiler> will be used
                                        as 'wrapper compiler'.
                                        The following are the available compilers:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <wrf_pnetcdf_mpi_compiler_version>: specify the version of MPI used to build pnetcdf
                                        for <wrf_pnetcdf_mpi_compiler> as "aocc" the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <wrf_pnetcdf_mpi_flags> [optional]: specify the mpi flags to build <wrf_pnetcdf_mpi>
                                        default mpi_flags for <wrf_pnetcdf_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <wrf_pnetcdf_flags> [optional]:     specify the pnetcdf flags to build pnetcdf
                                        default pnetcdf_flags for <wrf_pnetcdf_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'

    <wrf_netcdfc_version>:              specify the version of netcdf
                                        Recommended version : 4.7.4
                                        Latest version : 4.9.2
                                        NetCDF Fortran  4.9.1

    <wrf_netcdff_version>:              Recommended version : 4.5.3
                                        Latest version : 4.9.2
                                        NetCDF Fortran 4.6.1

    <wrf_netcdf_mpi>:                   specify the mpi to build netcdf.The following are the available mpi:
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <wrf_netcdf_mpi_version>:           specify the version of <netcdf_mpi>
                                        Recommended version : 4.1.1
                                        Latest version : 4.1.4

    <wrf_netcdf_mpi_compiler>:          specify the compiler to build <netcdf_mpi>.
                                        For the two <netcdf_mpi>s intel-mpi and intel-oneapi-mpi, <netcdf_mpi_compiler> will be used
                                        as 'wrapper compiler'.
                                        The following are the available compilers:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <wrf_netcdf_mpi_compiler_version>:  specify the version of MPI used to build netcdf
                                        Recommended version : 3.2.0
                                        Latest version : 4.0.0

    <wrf_netcdf_hdf5_version>:          specify the version of HDF5 used to build netcdf
                                        Note : HDF5 module with same MPI settings as NetCDF will be loaded
                                        Recommended version : 1.10.8
                                        Latest version : 1.10.9, 1.8.23, 1.10.10

    <wrf_netcdf_pnetcdf_version>:       specify the version of PnetCDF used to build netcdf
                                        Note : PnetCDF module with same MPI settings as NetCDF will be loaded
                                        Recommended version : 1.11.2
                                        Latest version : 1.10.9, 1.8.23, 1.10.10


    <wrf_netcdf_mpi_flags> [optional]:  specify the mpi flags to build <netcdf_mpi>
                                        default mpi_flags for <mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <wrf_netcdf_flags> [optional]:      specify the netcdf flags to build netcdf
                                        default netcdf_flags for <netcdf_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'
"

}

if [ -z $home_dir ]; then
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
if [[ -z $wrf_version ]]  || [[ -z $wrf_compiler ]] || [[ -z $wrf_compiler_version ]] || [[ -z $wrf_mpi ]] || [[ -z $wrf_mpi_compiler ]] || [[ -z $wrf_mpi_compiler_version ]] || [[ -z $wrf_jemalloc_version ]] || [[ -z $wrf_jemalloc_compiler ]] || [[ -z $wrf_jemalloc_compiler_version ]] || [[ -z $wrf_hdf5_version ]] || [[ -z $wrf_hdf5_mpi ]] || [[ -z $wrf_hdf5_mpi_version ]] || [[ -z $wrf_hdf5_mpi_compiler ]] || [[ -z $wrf_hdf5_mpi_compiler_version ]] || [[ -z $wrf_pnetcdf_version ]] || [[ -z $wrf_pnetcdf_mpi ]] || [[ -z $wrf_pnetcdf_mpi_version ]] || [[ -z $wrf_pnetcdf_mpi_compiler ]] || [[ -z $wrf_pnetcdf_mpi_compiler_version ]] || [[ -z $wrf_netcdfc_version ]] || [[ -z $wrf_netcdff_version ]] || [[ -z $wrf_netcdf_mpi ]] || [[ -z $wrf_netcdf_mpi_version ]] || [[ -z $wrf_netcdf_mpi_compiler ]] || [[ -z $wrf_netcdf_mpi_compiler_version ]] || [[ -z $wrf_netcdf_hdf5_version ]] || [[ -z $wrf_netcdf_pnetcdf_version ]];
then
    wrf_usage
    exit
fi
min_options=28
if [[ $n_arg -gt ${min_options} ]];then
    load_check_flags $[$n_arg-${min_options}] wrf_mpi_flags wrf_flags wrf_jemalloc_flags wrf_hdf5_mpi_flags wrf_hdf5_flags wrf_netcdf_mpi_flags wrf_netcdf_flags wrf_pnetcdf_mpi_flags wrf_pnetcdf_flags
    if [ $? == 0 ];then
        echo "Flags specified incorrecly, Exiting... "
        wrf_usage
        exit
    fi
fi
export wrf_packname=WRF-$wrf_version
date=$(date | perl -pe 's/\s+/_/g;s/_$//;s/://g')
buildlog=buildlog.$wrf_packname.$USER.$(hostname -s).$(hostname -d).$date.txt
DIR_STR=wrf/${wrf_version}/${wrf_compiler}/${wrf_compiler_version}/${wrf_mpi}/${wrf_mpi_compiler}/${wrf_mpi_compiler_version}/jemalloc/${wrf_jemalloc_version}/${wrf_jemalloc_compiler}/${wrf_jemalloc_compiler_version}/${wrf_jemalloc_compiler_version}/HDF5/${wrf_hdf5_version}/${wrf_hdf5_mpi}/${wrf_hdf5_mpi_version}/${wrf_hdf5_mpi_compiler}/${wrf_hdf5_mpi_compiler_version}/pnetcdf/${wrf_pnetcdf_version}/${wrf_pnetcdf_mpi}/${wrf_pnetcdf_mpi_version}/${wrf_pnetcdf_mpi_compiler}/${wrf_pnetcdf_mpi_compiler_version}/netcdf/${wrf_netcdfc_version}/${wrf_netcdff_version}/${wrf_netcdf_mpi}/${wrf_netcdf_mpi_version}/${wrf_netcdf_mpi_compiler}/${wrf_netcdf_mpi_compiler_version}/${wrf_netcdf_hdf5_version}
build_check $DIR_STR/${wrf_netcdf_pnetcdf_version} "$wrf_flags"
export rebuilt=$?

if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                       WRF-${wrf_packname} IS FOUND IN MODULES LOADING MODULE                              #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/${wrf_netcdf_pnetcdf_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                          WRF-${wrf_packname} IS NOT PRESENT IN MODULES                                    #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                                       HOSTNAME:    $(hostname)                                            #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"

    export WRF_SOURCE=${home_dir}/source_codes/$DIR_STR/${wrf_netcdf_pnetcdf_version}
    export WRF_BUILD=${home_dir}/apps/$DIR_STR/${wrf_netcdf_pnetcdf_version}

    #########      Creating HDF5 DIR    ########
    mkdir -p $WRF_SOURCE
    mkdir -p $WRF_BUILD
    #cd $HDF5_SOURCE
    #rm -rf $HDF5_SOURCE/*
    rm -rf $WRF_BUILD/*

    ###########    CPU Architecture    #########
    cpu_model=$(grep 'model name' /proc/cpuinfo | head -n1 | awk -F': ' '{print $2}' | awk '{print $3}')
    if [[ $cpu_model == *"9"* ]];
    then
        echo "Genoa"
        CPU_ARC="-march=znver4"
    elif [[ $cpu_model == *"7"* ]]; then
        echo "Milan"
        CPU_ARC="-march=znver3"
    elif [[ $cpu_model == *"Platinum"* ]] || [[ $cpu_model == *"8"* ]] ; then
        echo "Intel"
        CPU_ARC="-march=skylake-avx512"
    else
        echo "Unknown Series"
        CPU_ARC="-march=auto"
    fi

    ##### Loading modules with specified flag #####
    module load $wrf_compiler/$wrf_compiler_version

    ######## Loading Jemalloc module ########
    if [[ ${wrf_jemalloc_flags} ]];
    then
        bash ${home_dir}/scripts/jemalloc.sh --jemalloc_version=$wrf_jemalloc_version --jemalloc_compiler=$wrf_jemalloc_compiler --jemalloc_compiler_version=$wrf_jemalloc_compiler_version --jemalloc_flags=$wrf_jemalloc_flags
    else
        bash ${home_dir}/scripts/jemalloc.sh --jemalloc_version=$wrf_jemalloc_version --jemalloc_compiler=$wrf_jemalloc_compiler --jemalloc_compiler_version=$wrf_jemalloc_compiler_version
    fi
    module load jemalloc/$wrf_jemalloc_version/$wrf_jemalloc_compiler/$wrf_jemalloc_compiler_version

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    ####### Loading MPI module  ##########
    if [[ ${wrf_mpi_flags} ]];
    then
        bash ${home_dir}/scripts/mpi.sh --mpi=$wrf_mpi --mpi_version=$wrf_mpi_version --mpi_compiler=$wrf_mpi_compiler --mpi_compiler_version=$wrf_mpi_compiler_version --mpi_flags=$wrf_mpi_flags
    else
        bash ${home_dir}/scripts/mpi.sh --mpi=$wrf_mpi --mpi_version=$wrf_mpi_version --mpi_compiler=$wrf_mpi_compiler --mpi_compiler_version=$wrf_mpi_compiler_version
    fi
    module load $wrf_mpi/$wrf_mpi_version/$wrf_mpi_compiler/$wrf_mpi_compiler_version

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    ######## Loading HDF5 module ########
    if [[ ${wrf_hdf5_flags} ]];
    then
        bash ${home_dir}/scripts/HDF5.sh --hdf5_version=$wrf_hdf5_version --hdf5_mpi=$wrf_hdf5_mpi --hdf5_mpi_version=$wrf_hdf5_mpi_version --hdf5_mpi_compiler=$wrf_hdf5_mpi_compiler --hdf5_mpi_compiler_version=$wrf_hdf5_mpi_compiler_version --hdf5_flags=$wrf_hdf5_flags
    else
        bash ${home_dir}/scripts/HDF5.sh --hdf5_version=$wrf_hdf5_version --hdf5_mpi=$wrf_hdf5_mpi --hdf5_mpi_version=$wrf_hdf5_mpi_version --hdf5_mpi_compiler=$wrf_hdf5_mpi_compiler --hdf5_mpi_compiler_version=$wrf_hdf5_mpi_compiler_version
    fi
    module load hdf5/$wrf_hdf5_version/$wrf_hdf5_mpi/$wrf_hdf5_mpi_version/$wrf_hdf5_mpi_compiler/$wrf_hdf5_mpi_compiler_version

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    ######## Loading PnetCDF module ########
    if [[ ${wrf_pnetcdf_flags} ]];
    then
        bash ${home_dir}/scripts/pnetcdf.sh --pnetcdf_version=$wrf_pnetcdf_version --pnetcdf_mpi=$wrf_pnetcdf_mpi --pnetcdf_mpi_version=$wrf_pnetcdf_mpi_version --pnetcdf_mpi_compiler=$wrf_pnetcdf_mpi_compiler --pnetcdf_mpi_compiler_version=$wrf_pnetcdf_mpi_compiler_version --pnetcdf_flags=$wrf_pnetcdf_flags
    else
        bash ${home_dir}/scripts/pnetcdf.sh --pnetcdf_version=$wrf_pnetcdf_version --pnetcdf_mpi=$wrf_pnetcdf_mpi --pnetcdf_mpi_version=$wrf_pnetcdf_mpi_version --pnetcdf_mpi_compiler=$wrf_pnetcdf_mpi_compiler --pnetcdf_mpi_compiler_version=$wrf_pnetcdf_mpi_compiler_version
    fi
    module load pnetcdf/${wrf_pnetcdf_version}/${wrf_pnetcdf_mpi}/${wrf_pnetcdf_mpi_version}/${wrf_pnetcdf_mpi_compiler}/${wrf_pnetcdf_mpi_compiler_version}

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    ######## Loading NetCDF module ########
    if [[ ${wrf_netcdf_flags} ]];
    then
        bash ${home_dir}/scripts/netcdf.sh --netcdfc_version=$wrf_netcdfc_version --netcdff_version=$wrf_netcdff_version --netcdf_mpi=$wrf_netcdf_mpi --netcdf_mpi_version=$wrf_netcdf_mpi_version --netcdf_mpi_compiler=$wrf_netcdf_mpi_compiler --netcdf_mpi_compiler_version=$wrf_netcdf_mpi_compiler_version --netcdf_hdf5_version=$wrf_netcdf_hdf5_version --netcdf_pnetcdf_version=$wrf_netcdf_pnetcdf_version ----netcdf_flags=$wrf_netcdf_flags
    else
        bash ${home_dir}/scripts/netcdf.sh --netcdfc_version=$wrf_netcdfc_version --netcdff_version=$wrf_netcdff_version --netcdf_mpi=$wrf_netcdf_mpi --netcdf_mpi_version=$wrf_netcdf_mpi_version --netcdf_mpi_compiler=$wrf_netcdf_mpi_compiler --netcdf_mpi_compiler_version=$wrf_netcdf_mpi_compiler_version --netcdf_hdf5_version=$wrf_netcdf_hdf5_version --netcdf_pnetcdf_version=$wrf_netcdf_pnetcdf_version
    fi
    module load netcdf/${wrf_netcdfc_version}/${wrf_netcdff_version}/${wrf_netcdf_mpi}/${wrf_netcdf_mpi_version}/${wrf_netcdf_mpi_compiler}/${wrf_netcdf_mpi_compiler_version}/HDF5/${wrf_netcdf_hdf5_version}/PnetCDF/$wrf_netcdf_pnetcdf_version

    echo "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
    echo "#                           Building  $wrf_packname                                    #"
    echo "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"

    case $wrf_compiler in
    aocc)
        echo "using AOCC compiler"
        export FC=flang
        export CC=clang
        export CXX=clang++
        export AR=llvm-ar
        export NM=llvm-nm
        export RANLIB=llvm-ranlib
#######################################################################################################
#####                   create python or jason to load latest aocl for amd tool chain #################
#######################################################################################################
        bash ${home_dir}/scripts/mathlib.sh --math=aocl --math_version=3.2 --math_compiler=$wrf_compiler --math_compiler_version=$wrf_compiler_version
        module load aocl/3.2/$wrf_compiler/$wrf_compiler_version
#######################################################################################################
        export MATHFLAGS="-lamdlibm -L$SOURCES/amdlibm -lm"
        export OPT_CFLAGS="-m64 -Ofast -ffast-math -march=znver4 -mllvm -vector-library=LIBMVEC  -freciprocal-math -ffp-contract=fast -mavx2 -funroll-loops -finline-aggressive"
        export OPT_LDFLAGS="-m64 -Ofast $MATHFLAGS "
        export OPT_FCFLAGS="-m64 -Ofast -march=znver4 -Mbyteswapio -freciprocal-math -ffp-contract=fast -mavx2 -funroll-loops -ffast-math -finline-aggressive "
################Default Flag ######################
        if [[ -z $wrf_flags ]];
        then
            export CFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export CXXFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export FCFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export FFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export build_type=default
        else
            export build_type=custom
        fi
    ;;
    gcc)
        echo "using GCC compiler"
        export CC=gcc
        export CXX=g++
        export F90=gfortran
        export F77=gfortran
        export AR=llvm-ar
        export NM=llvm-nm
        export RANLIB=llvm-ranlib
        if [[ -z $wrf_flags ]];
        then
            export CFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export CXXFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export FCFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export FFLAGS="-O3 $CPU_ARC -fopenmp -fPIC"
            export build_type=default
        else
            export build_type=custom
        fi
        ;;
    intel-oneapi-compilers-classic)
        echo "using ICC compiler"
        export CC=icc
        export CXX=icpc
        export F90=ifort
        export F77=ifort
        export FC=ifort
        export AR=ar
        export arflags=r
        export RANLIB=echo
        if [[ -z $wrf_flags ]];
        then
            export CFLAGS="-O3 $CPU_ARC -fqopenmp -fPIC"
            export CXXFLAGS="-O3 $CPU_ARC -fqopenmp -fPIC"
            export FCFLAGS="-O3 $CPU_ARC -fqopenmp -fPIC"
            export FFLAGS="-O3 $CPU_ARC -fqopenmp -fPIC"
            export build_type=default
        else
            export build_type=custom
        fi
    ;;
    esac

    export WRFIO_NCD_LARGE_FILE_SUPPORT=1
    export wrf_archive=v${wrf_version}.tar.gz
    ######### Download WRF Tar Package #########
    if [  -f "${WRF_SOURCE}/$wrf_archive" ]
    then
        echo "${wrf_packname} source file found in ${WRF_SOURCE}"
    else
        if [[ $wrf_version == 4* ]]; then
            echo "Downloading ${wrf_packname}"
            wget -P ${WRF_SOURCE} https://github.com/wrf-model/WRF/archive/refs/tags/v${wrf_version}.tar.gz
            export wrf_archive=v${wrf_version}.tar.gz

        else
            wget -P ${WRF_SOURCE} https://www2.mmm.ucar.edu/wrf/src/WRFV${wrf_version}.TAR.gz
            export wrf_archive=WRFV${wrf_version}.TAR.gz
        fi
    fi

    cd $WRF_BUILD
    rm -rf ${wrf_packname}
    rm -rf WRF-${wrf_version}
    echo " UnTaring ${hdf5_packname}"
    tar xf ${WRF_SOURCE}/$wrf_archive
    mv WRFV3 WRF-${wrf_version}

    cd WRF-${wrf_version}

########################### Compilation ##################################
    case "$wrf_compiler" in
    aocc)
        ################ AMD Optimised Configure file ##################################
        if [[ $wrf_version == 4* ]]; then
            wget https://raw.githubusercontent.com/Manojmp2000/WRF-V4_configure_file/main/configure.wrf
        else
            wget https://raw.githubusercontent.com/Manojmp2000/WRF-V3_configure_file/main/configure.wrf
        fi

        chmod +x configure.wrf
    ;;
    gcc)
        printf "%s\n" 35 1 | ./configure
        sed -i "s/\(^FCOPTIM.*\)/\1 ${FFLAGS}/" configure.wrf
        sed -i "s/\(^DM_CC.*\)/\1 -DMPI2_SUPPORT/" configure.wrf
    ;;
    intel-oneapi-compilers-classic)
        sed -i 's/-xCORE-AVX2/-march=core-avx2/g;s/-xHost//g' arch/configure.defaults
        sed -i 's/-openmp/-qopenmp -qoverride-limits/g' arch/configure.defaults
        printf "%s\n" 67 1 | ./configure
        sed -i 's/) -DNMM_CORE=$(WRF_NMM_CORE)/) -DNMM_CORE=$(WRF_NMM_CORE) -DLANDREAD_STUB/g' configure.wrf
        sed -i 's/-xCORE-AVX2/-march=core-avx2/g;s/-xHost//g' arch/configure.defaults
        sed -i 's/-openmp/-qopenmp -qoverride-limits/g' arch/configure.defaults

    ;;
    *)
    echo "Unknown option"
        exit 1
    ;;
    esac

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    # Start the compilation
    #
    echo "Compiling wrf"
    ./compile -j $(nproc) em_real 2>&1 | tee make_log_em_real

    #
    # Sometimes a parallel build fails the first time due to unsatisfied
    # dependencies. Try one more time
    #
    if [ ! -f main/wrf.exe ]; then
        ./compile -j $(nproc) em_real 2>&1 | tee make_log_em_real
    fi

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc


    cd $WRF_BUILD/WRF-${wrf_version}/main
    if  [ -f $WRF_BUILD/WRF-${wrf_version}/main/wrf.exe ] || [ -e "wrf.exe" ] && [ -e "ndown.exe" ] && [ -e "real.exe" ] && [ -e "tc.exe" ];
    then
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                             WRF-${wrf_version} BUILD SUCCESSFUL                                           #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
            export PATH=$WRF_BUILD/WRF-${wrf_version}/main:${PATH}
            mkdir -p ${home_dir}/module_files/$DIR_STR

            echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
                puts stderr "\tAdds WRF to your environment variables"
            }
            module-whatis \"sets the WRF_ROOT path
            Build flags:       $wrf_flags
            Build type:        $build_type\"
            set             root           $WRF_BUILD/WRF-${wrf_version}
            setenv          WRF_ROOT               \$root
            " > ${home_dir}/module_files/$DIR_STR/${wrf_netcdf_pnetcdf_version}
            module load $DIR_STR/${wrf_netcdf_pnetcdf_version}
    else
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                               WRF-${wrf_version} BUILD UNSUCCESSFUL                                       #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"

            echo " --- Please check : ${home_dir}/log_files/${DIR_STR}/${wrf_netcdf_pnetcdf_version}${date}.log ---"
            cd ${home_dir}
            exit 1
    fi
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/${wrf_netcdf_pnetcdf_version}${date}.log

fi


