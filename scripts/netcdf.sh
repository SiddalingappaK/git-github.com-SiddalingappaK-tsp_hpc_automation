
#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                       NetCDF BUILD SCRIPT                                                 #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"
netcdf_usage()
{
    echo "
    Usage: ./netcdf.sh [OPTIONS] [ARGS]
    Eg:    ./netcdf.sh --netcdfc_version=<netcdfc_version>\\
                       --netcdff_version=<netcdff_version>\\
                       --netcdf_mpi=<netcdf_mpi>\\
                       --netcdf_mpi_version=<netcdf_mpi_version>\\
                       --netcdf_mpi_compiler=<netcdf_mpi_compiler>\\
                       --netcdf_mpi_compiler_version=<netcdf_mpi_compiler_version>\\
                       --netcdf_mpi_flags=<netcdf_mpi_flags>\\
                       --netcdf_hdf5_version=<netcdf_hdf5_version>\\
                       --netcdf_pnetcdf_version=<netcdf_pnetcdf_version>\\
                       --netcdf_flags=<netcdf_flags>

    Builds the NetCDF Module of specified version with specified compiler specifications, mpi specifications.

        Example: ./netcdf.sh --netcdfc_version=4.7.4 --netcdff_version=4.5.3 --netcdf_mpi=openmpi \\
                 --netcdf_mpi_version=4.1.1 --netcdf_mpi_compiler=aocc --netcdf_mpi_compiler_version=4.0.0 \\
                 --netcdf_hdf5_version=1.10.8 --netcdf_pnetcdf_version=1.11.2
                 --netcdf_mpi_flags
                 --netcdf_flags
    <netcdfc_version>:                  specify the version of netcdf
                                        Recommended version : 4.7.4
                                        Latest version : 4.9.2
                                        NetCDF Fortran  4.9.1

    <netcdff_version>:                  Recommended version : 4.5.3
                                        Latest version : 4.9.2
                                        NetCDF Fortran 4.6.1

    <netcdf_mpi>:                       specify the mpi to build netcdf.The following are the available mpi:
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <netcdf_mpi_version>:               specify the version of <netcdf_mpi>
                                        Recommended version : 4.1.1
                                        Latest version : 4.1.4

    <netcdf_mpi_compiler>:              specify the compiler to build <netcdf_mpi>.
                                        For the two <netcdf_mpi>s intel-mpi and intel-oneapi-mpi, <netcdf_mpi_compiler> will be used
                                        as 'wrapper compiler'.
                                        The following are the available compilers:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <netcdf_mpi_compiler_version>:      specify the version of MPI used to build netcdf
                                        Recommended version : 3.2.0
                                        Latest version : 4.0.0

    <netcdf_hdf5_version>:              specify the version of HDF5 used to build netcdf
                                        Note : HDF5 module with same MPI settings as NetCDF will be loaded
                                        Recommended version : 1.10.8
                                        Latest version : 1.10.9, 1.8.23, 1.10.10

    <netcdf_pnetcdf_version>:           specify the version of PnetCDF used to build netcdf
                                        Note : PnetCDF module with same MPI settings as NetCDF will be loaded
                                        Recommended version : 1.11.2
                                        Latest version : 1.10.9, 1.8.23, 1.10.10


    <netcdf_mpi_flags> [optional]:      specify the mpi flags to build <netcdf_mpi>
                                        default mpi_flags for <mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <netcdf_flags> [optional]:          specify the netcdf flags to build netcdf
                                        default netcdf_flags for <netcdf_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'

                                        "

}

if [ -z $home_dir ];then
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
if [[ -z $netcdfc_version ]]  || [[ -z $netcdff_version ]] || [[ -z $netcdf_mpi ]] || [[ -z $netcdf_mpi_version ]] || [[ -z $netcdf_mpi_compiler ]] || [[ -z $netcdf_mpi_compiler_version ]] || [[ -z $netcdf_hdf5_version ]] || [[ -z $netcdf_pnetcdf_version ]] ;
then
    netcdf_usage
    exit
fi
min_options=8
if [[ $n_arg -gt ${min_options} ]];
then
    load_check_flags $[$n_arg-${min_options}] netcdf_mpi_flags netcdf_flags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        netcdf_usage
        exit
    fi
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                Building netcdf                                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

export build_netcdfc_packname=netcdf-c-$netcdfc_version
export build_netcdff_packname=netcdf-fortran-$netcdff_version

export netcdfc_packname=$build_netcdfc_packname
export netcdff_packname=$build_netcdff_packname

date=$(date | perl -pe 's/\s+/_/g;s/_$//;s/://g')
buildlog=buildlog.$netcdfc_packname.$netcdff_packname.$USER.$(hostname -s).$(hostname -d).$date.txt

DIR_STR=netcdf/${netcdfc_version}/${netcdff_version}/${netcdf_mpi}/${netcdf_mpi_version}/${netcdf_mpi_compiler}/${netcdf_mpi_compiler_version}/HDF5/${netcdf_hdf5_version}/PnetCDF
build_check $DIR_STR/$netcdf_pnetcdf_version "$netcdf_flags"
export rebuilt=$?

if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                       ${netcdfc_packname} IS FOUND IN MODULES LOADING MODULE                              #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/${netcdf_pnetcdf_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}/${netcdf_pnetcdf_version}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                        netcdf-c-$netcdfc_version IS NOT PRESENT IN MODULES                                #"
    echo "#                     netcdf-fortran-$netcdff_version IS NOT PRESENT IN MODULES                             #"
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

    ##### Load MPI module with specified falg #####
    if [[ ${netcdf_mpi_flags} ]];
    then
        bash ${home_dir}/scripts/mpi.sh  --mpi=$netcdf_mpi --mpi_version=$netcdf_mpi_version --mpi_compiler=$netcdf_mpi_compiler --mpi_compiler_version=$netcdf_mpi_compiler_version --mpi_flags=$netcdf_mpi_flags
    else
        bash ${home_dir}/scripts/mpi.sh --mpi=$netcdf_mpi --mpi_version=$netcdf_mpi_version --mpi_compiler=$netcdf_mpi_compiler --mpi_compiler_version=$netcdf_mpi_compiler_version
    fi

    ############## Load MPI moudle ##########
    module load $netcdf_mpi/$netcdf_mpi_version/$netcdf_mpi_compiler/$netcdf_mpi_compiler_version
    echo "~~~~~~~~~~   $netcdf_mpi-$netcdf_mpi_$netcdf_mpi_compiler_$netcdf_mpi_compiler_version is loaded  ~~~~~~~~~~~~"

    case $netcdf_mpi in
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

    ########### Building NETCDF ############

    ####### load hdf5 module #####   $netcdf_mpi/$netcdf_mpi_version/$netcdf_mpi_compiler/$netcdf_mpi_compiler_version
    echo "~~~~~~~~~~~ Loding hdf5-${netcdf_hdf5_version} ~~~~~~~~~~~"
    bash ${home_dir}/scripts/hdf5 --hdf5_version=${netcdf_hdf5_version} --hdf5_mpi=${netcdf_mpi} --hdf5_mpi_version=${netcdf_mpi_version} --hdf5_mpi_compiler=${netcdf_mpi_compiler} --hdf5_mpi_compiler_version=${netcdf_mpi_compiler_version}
    module load hdf5/${netcdf_hdf5_version}/${netcdf_mpi}/${netcdf_mpi_version}/${netcdf_mpi_compiler}/${netcdf_mpi_compiler_version}

    ####### load pnetcdf module #####
    echo "~~~~~~~~~~~ Loding pnetcdf-${netcdf_pnetcdf_version} ~~~~~~~~~~~"
    bash ${home_dir}/scripts/pnetcdf.sh --pnetcdf_version=${netcdf_pnetcdf_version} --pnetcdf_mpi=${netcdf_mpi} --pnetcdf_mpi_version=${netcdf_mpi_version} --pnetcdf_mpi_compiler=${netcdf_mpi_compiler} --pnetcdf_mpi_compiler_version=${netcdf_mpi_compiler_version}
    module load pnetcdf/${netcdf_pnetcdf_version}/${netcdf_mpi}/${netcdf_mpi_version}/${netcdf_mpi_compiler}/${netcdf_mpi_compiler_version}

    ########################################

    export NETCDF_BUILD=${home_dir}/apps/$DIR_STR/${netcdf_mpi_compiler_version}
    export NETCDFC_SOURCE=${home_dir}/source_codes/NetCDF/NetCFF-C
    export NETCDFF_SOURCE=${home_dir}/source_codes/NetCDF/NetCFF-F

    #########   Creating pnetcdf DIR    ########
    mkdir -p $NETCDFC_SOURCE
    mkdir -p $NETCDFF_SOURCE
    mkdir -p $NETCDF_BUILD

    ####### Downloading the tar files #######
    netcdfc_archive=$netcdfc_packname.tar.gz
    netcdff_archive=$netcdff_packname.tar.gz

    if [  -f "${NETCDFC_SOURCE}/$netcdfc_archive" ]
    then
        echo "$netcdfc_packname source file found in ${NETCDFC_SOURCE}"
    else
        cd ${NETCDFC_SOURCE}
        echo "Downloading $netcdfc_packname"
        wget https://github.com/Unidata/netcdf-c/archive/v${netcdfc_version}.tar.gz -O $netcdfc_archive
    fi


    if [  -f "${NETCDFF_SOURCE}/$netcdff_archive" ]
    then
        echo "$netcdff_packname source file found in ${NETCDFF_SOURCE}"
    else
        cd ${NETCDFF_SOURCE}
        echo "Downloading netcdff_packname"
        wget https://github.com/Unidata/netcdf-fortran/archive/v${netcdff_version}.tar.gz -O $netcdff_archive
    fi
######### Removing old Build ###############
    rm -rf ${NETCDF_BUILD}/*

######## Setting Specific Compiler Flags #######
    case $netcdf_mpi_compiler in
    icc)
        ARCH="-march=core-avx2"
        OMP="-fqopenmp"
        ;;
    gcc)
        ARCH=${CPU_ARC}
        OMP="-fopenmp"
        ;;
    aocc)
        if [[ -z $netcdf_flags ]];
        then
            #export hpl_flags="-O3 -funroll-loops -march=skylake-avx512 -qopenmp"
            ARCH=${CPU_ARC}
            OMP="-fopenmp"
            export build_type=default
        else
            export build_type=custom
        fi
        ;;
    esac

    export CFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    export CXXFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    export FCFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    export FFLAGS="-O3 ${ARCH} ${OMP} -fPIC"

    export CFLAGS="$CFLAGS -I${MPI_DIR}/include -I${HDF5_DIR}/include -I${PNETCDF_DIR}/include -I${NETCDF_BUILD}/include"
    export CPPFLAGS="$CXXFLAGS -I${MPI_DIR}/include -I${HDF5_DIR}/include -I${PNETCDF_DIR}/include -I${NETCDF_BUILD}/include"
    export LDFLAGS="-L${MPI_DIR}/lib -L${MPI_DIR}/lib64 -L${HDF5_DIR}/lib -L${HDF5_DIR}/lib64 -L${PNETCDF_DIR}/lib -L${PNETCDF_DIR}/lib64 -L${NETCDF_BUILD}/lib -L${NETCDF_BUILD}/lib64 "

    cd ${NETCDF_BUILD}
    rm -rf $netcdfc_packname

    tar xf ${NETCDFC_SOURCE}/$netcdfc_archive
    echo " Building $netcdfc_packname "

    cd $netcdfc_packname

    ./configure --with-hdf5=${HDF5_DIR} --enable-dynamic-loading --enable-netcdf-4 --enable-shared --enable-pnetcdf --disable-dap --prefix=${NETCDF_BUILD} 2>&1 | tee configure.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make -j $(nproc) 2>&1 | tee make.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make install -j $(nproc) 2>&1 | tee make-install.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make clean

    echo "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
    echo "#                                Building netcdff                                      #"
    echo "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"

    cd ${NETCDF_BUILD}
    rm -rf $netcdff_packname

    tar xf ${NETCDFF_SOURCE}/$netcdff_archive
    echo " Building $netcdff_packname "

    cd $netcdff_packname
    ./configure --prefix=${NETCDF_BUILD} --enable-shared 2>&1 | tee configure.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    sed -i -e 's#wl=""#wl="-Wl,"#g' libtool
    sed -i -e 's#pic_flag=""#pic_flag=" -fPIC -DPIC"#g' libtool

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make install 2>&1 | tee make-install.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make clean

    if  [ -f ${NETCDF_BUILD}/lib/libnetcdf.a ] || [ -e "${NETCDF_BUILD}/lib64/libnetcdf.a" ] || [ -f ${NETCDF_BUILD}/lib/libnetcdff.a ] || [ -e "${NETCDF_BUILD}/lib64/libnetcdff.so" ];
    then
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                  ${netcdff_packname} and ${netcdff_packname} BUILD SUCCESSFUL                             #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"

            export PATH=${NETCDF_BUILD}/bin:${PATH}
            export LD_LIBRARY_PATH=${NETCDF_BUILD}/lib:${LD_LIBRARY_PATH}
            export INCLUDE=${NETCDF_BUILD}/include:${INCLUDE}

            mkdir -p ${home_dir}/module_files/$DIR_STR

            echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
                puts stderr "\tAdds NetCFD to your environment variables"
            }
            module-whatis \"sets the NetCFDROOT path
            Build flags:       $netcdf_flags
            Build type:        $build_type\"
            set             root           ${NETCDF_BUILD}
            setenv          NETCDF_ROOT               \$root
            setenv          NETCDF                    \$root
            setenv          NETCDF_DIR                \$root
            setenv          NETCDFF_DIR               \$root
            setenv          NETCDFC_DIR               \$root
            prepend-path    PATH                    \$root/bin
            prepend-path    LD_LIBRARY_PATH         \$root/lib
            prepend-path    LIBRARY_PATH            \$root/lib
            prepend-path    C_INCLUDE_PATH          \$root/include
            " > ${home_dir}/module_files/$DIR_STR/$netcdf_pnetcdf_version
            module load $DIR_STR/$netcdf_pnetcdf_version
    else
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                               Building ${netcdff_packname} is UNSUCCESSFUL                                #"
            echo "#                               Building ${netcdfc_packname} is UNSUCCESSFUL                                #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
            echo " --- Please check : ${home_dir}/log_files/${DIR_STR}/$netcdf_pnetcdf_version_${date}.log  ---"
            cd ${home_dir}
            exit 1
    fi
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$netcdf_pnetcdf_version_${date}.log

fi

