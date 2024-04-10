#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                       HDF5 BUILD SCRIPT                                                   #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"
hdf5_usage()
{
    echo "
    Usage: ./HDF5.sh [OPTIONS] [ARGS]
    Eg:    ./HDF5.sh --hdf5_version <hdf5_version>\\
                     --hdf5_mpi <hdf5_mpi>\\
                     --hdf5_mpi_version <hdf5_mpi_version>\\
                     --hdf5_mpi_compiler <hdf5_mpi_compiler>\\
                     --hdf5_mpi_compiler_version <hdf5_mpi_compiler_version>\\
                     --hdf5_mpi_flags <hdf5_mpi_flags>\\
                     --hdf5_flags <hdf5_flags>
    Builds the HDF5 Module of specified version with specified compiler specifications, mpi specifications.

    Example: ./HDF5.sh --hdf5_version 1.10.8 --hdf5_mpi openmpi --hdf5_mpi_version 4.1.1 --hdf5_mpi_compiler aocc --hdf5_mpi_compiler_version 4.0.0
             --hdf5_mpi_flags 
             --hdf5_flags
    <hdf5_version>:                  specify the version of hdf5 
                                     Recommended version : 1.10.8 
                                     Latest version : 1.10.9, 1.8.23, 1.10.10 

    <hdf5_mpi>:                      specify the mpi to build hdf5.The following are the available mpi:
                                     openmpi
                                     intel-mpi
                                     intel-oneapi-mpi

    <hdf5_mpi_version>:              specify the version of <hdf5_mpi>

    <hdf5_mpi_compiler>:             specify the compiler to build <hdf5_mpi>.
                                     For the two <hdf5_mpi>s intel-mpi and intel-oneapi-mpi, <hdf5_mpi_compiler> will be used 
                                     as 'wrapper compiler'.
                                     The following are the available compilers:
                                     aocc
                                     gcc
                                     intel-oneapi-compilers-classic

    <hdf5_mpi_compiler_version>:     specify the version of MPI used to build hdf5

    <hdf5_mpi_flags> [optional]:     specify the mpi flags to build <hdf5_mpi>
                                     default mpi_flags for <mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <hdf5_flags> [optional]:         specify the hdf5 flags to build hdf5
                                     default hdf5_flags for <hdf5_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'

                                        "

}

while [ $# -gt 0 ] ;
do
    case $1 in
            --hdf5_version)
                echo "hdf5_version : $2"
                export hdf5_version=$2
            ;;
            --hdf5_mpi)
                echo "hdf5_mpi : $2"
                export hdf5_mpi=$2
            ;;
            --hdf5_mpi_version)
                echo "hdf5_mpi_version : $2"
                export hdf5_mpi_version=$2
            ;;
            --hdf5_mpi_compiler)
                echo "hdf5_mpi_compiler : $2"
                export hdf5_mpi_compiler=$2
            ;;
            --hdf5_mpi_compiler_version)
                echo "hdf5_mpi_compiler_version : $2"
                export hdf5_mpi_compiler_version=$2
            ;;
            --hdf5_mpi_flags)
                echo "hdf5_mpi_flags : $2"
                export hdf5_mpi_flags=$2
            ;;
            --hdf5_flags)
                echo "hdf5_flags : $2"
                export hdf5_flags=$2
            ;;
            --help)
                hdf5_usage
                exit
            ;;
            *)
                echo "Invalid Option $1"
                hdf5_usage
                exit
            ;;
    esac    
    shift 2
done
if [[ -z $hdf5_version ]]  || [[ -z $hdf5_mpi ]] || [[ -z $hdf5_mpi_version ]] || [[ -z $hdf5_mpi_compiler ]] || [[ -z $hdf5_mpi_compiler_version ]] ;
then
    hdf5_usage
    exit
fi


DIR_STR=hdf5/${hdf5_version}/${hdf5_mpi}/${hdf5_mpi_version}/${hdf5_mpi_compiler}
source ./env_set.sh
build_check $DIR_STR/$hdf5_mpi_compiler_version "$hdf5_flags"
export rebuilt=$?

if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                        HDF5-${hdf5_version} IS FOUND IN MODULES LOADING MODULE                            #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/${hdf5_mpi_compiler_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                         HDF5-${hdf5_version} IS NOT PRESENT IN MODULES                                    #"
    echo "#                                 Building HDF5-${hdf5_version}                                             #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"

 
    export build_packname=hdf5-${hdf5_version}
    export hdf5_packname=${build_packname}
    export HDF5_SOURCE=${home_dir}/source_codes/HDF5
    export HDF5_BUILD=${home_dir}/apps/$DIR_STR/$hdf5_mpi_compiler_version


    date=$(date | perl -pe 's/\s+/_/g;s/_$//;s/://g')
    buildlog=buildlog.$hdf5_packname.$USER.$(hostname -s).$date.txt

    #########      Creating HDF5 DIR    ########
    mkdir -p $HDF5_SOURCE
    mkdir -p $HDF5_BUILD
    #cd $HDF5_SOURCE
    #rm -rf $HDF5_SOURCE/*
    rm -rf $HDF5_BUILD/*
    
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

    ##### Load MPI module with specified flag #####
    if [[ ${hdf5_mpi_flags} ]];
    then
        bash ${home_dir}/scripts/mpi.sh --mpi $hdf5_mpi --mpi_version $hdf5_mpi_version --mpi_compiler $hdf5_mpi_compiler --mpi_compiler_version $hdf5_mpi_compiler_version --mpi_flags $hdf5_mpi_flags 
    else
        bash ${home_dir}/scripts/mpi.sh --mpi $hdf5_mpi --mpi_version $hdf5_mpi_version --mpi_compiler $hdf5_mpi_compiler --mpi_compiler_version $hdf5_mpi_compiler_version
    fi

    module load $hdf5_mpi/$hdf5_mpi_version/$hdf5_mpi_compiler/$hdf5_mpi_compiler_version

    export CXXFLAGS=-I${OPENMPIROOT}/include
    export LDFLAGS="-L${OPENMPIROOT}/lib -L${OPENMPIROOT}/lib64 "

    hdf5_archive=${hdf5_packname}.tar.gz
    ######### Download HDF5 Package #########
    if [  -f "${HDF5_SOURCE}/$hdf5_archive" ]
    then
        echo "${hdf5_packname} source file found in ${HDF5_SOURCE}"
    else
        echo "Downloading ${hdf5_packname}"
        wget -P ${HDF5_SOURCE} https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_version::-2}/${hdf5_packname}/src/$hdf5_archive
    fi
    
    cd $HDF5_BUILD
    rm -rf ${hdf5_packname}
    echo " Building ${hdf5_packname}"
    tar xf ${HDF5_SOURCE}/$hdf5_archive
    

    case $hdf5_mpi_compiler in
    icc)
        ARCH="-march=core-avx2"
        OMP="-fqopenmp"
        ;;
    gcc)
        ARCH=${CPU_ARC}
        OMP="-fopenmp"
        ;;
    aocc)
        if [[ -z $hdf5_flags ]];
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

    case $hdf5_mpi in
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

    #Setting up the compiler flags
    export CFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    export CXXFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    export FCFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    export FFLAGS="-O3 ${ARCH} ${OMP} -fPIC"
    #export FCFLAGS="-mllvm --max-speculation-depth=0 -Mextend -ffree-form $FCFLAGS"
    cd ${hdf5_packname}    
    ./configure  --prefix=${HDF5_BUILD} CFLAGS="$CFLAGS" FCFLAGS="$FCFLAGS" --enable-fortran --enable-parallel --enable-hl --enable-shared 2>&1 | tee configure.log
    
    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    if [ $hdf5_mpi_compiler == "aocc" ];
    then
        sed -i -e 's#wl=""#wl="-Wl,"#g' libtool
        sed -i -e 's#pic_flag=""#pic_flag=" -fPIC -DPIC"#g' libtool
    elif [ $hdf5_mpi_compiler == "gcc" ] || [ $hdf5_mpi_compiler == "icc" ];
    then
        #sed -i -e 's#wl=""#wl="-Wl,"#g' libtool
        #sed -i -e 's#pic_flag=""#pic_flag=" -fPIC -DPIC"#g' libtool
        echo "Dont do sed for gcc and icc"
    fi

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make -j $(nproc) 2>&1 | tee make.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make install 2>&1 | tee make-install.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make clean

    if  [ -f ${HDF5_BUILD}/lib/libhdf5.a ] || [ -e "${HDF5_BUILD}/lib64/libhdf5.a" ] ;
    then
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                               ${hdf5_packname} BUILD SUCCESSFUL                                           #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
            export PATH=${HDF5_BUILD}/bin:${PATH}
            export LD_LIBRARY_PATH=${HDF5_BUILD}/lib:${HDF5_BUILD}/lib64:${LD_LIBRARY_PATH}
            export INCLUDE=${HDF5_BUILD}/include:${INCLUDE}

            export LDFLAGS+="-L${HDF5_BUILD}/lib -L${HDF5_BUILD}/lib64"
            export CFLAGS+="-I${HDF5_BUILD}/include"
            mkdir -p ${home_dir}/module_files/$DIR_STR

            echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
                puts stderr "\tAdds HDF5 to your environment variables"
            }
            module-whatis \"sets the HDF5_ROOT path
            Build flags:       $hdf5_flags
            Build type:        $build_type\"
            set             root           ${HDF5_BUILD}
            setenv          HDF5_ROOT               \$root
            setenv          HDF5_DIR                \$root
            setenv          HDF5                    \$root
            prepend-path    PATH                    \$root/bin
            prepend-path    LD_LIBRARY_PATH         \$root/lib
            prepend-path    LIBRARY_PATH            \$root/lib
            prepend-path    C_INCLUDE_PATH          \$root/include
            prepend-path    CPLUS_INCLUDE_PATH      \$root/include
            prepend-path    CPATH                   \$root/include
            setenv          BUILD_MPI               $hdf5_mpi
            setenv          HDF5LIB                 hdf5
            " > ${home_dir}/module_files/$DIR_STR/$hdf5_mpi_compiler_version
            module load $DIR_STR/$hdf5_mpi_compiler_version
    else
            echo " Building ${hdf5_packname} is UNSUCCESSFUL "
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                               Building ${hdf5_packname} is UNSUCCESSFUL                                   #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
        
            #echo " --- Please check : ${BUILD_DIR}/$buildlog ---"
            cd ${home_dir}
            exit 1
    fi
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$hdf5_mpi_compiler_version_${date}.log
    
fi



















