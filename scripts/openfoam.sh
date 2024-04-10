#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                           OPENFOAM SCRIPT                                                 #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"
openfoam_usage()
{
    echo "
    Usage :  ./openfoam.sh --openfoam_version=<openfoam_version>\\
                           --openfoam_compiler=<openfoam_compiler>\\
                           --openfoam_compiler_version=<openfoam_compiler_version>\\
                           --openfoam_mpi=<openfoam_mpi>\\
                           --openfoam_mpi_version=<openfoam_mpi_version>\\
                           --openfoam_mpi_compiler=<openfoam_mpi_compiler>\\
                           --openfoam_mpi_compiler_version=<openfoam_mpi_compiler_version>\\
                           --openfoam_mpi_flags=<openfoam_mpi_flags>\\ 
                           --openfoam_flags=<openfoam_flags> 

    Example: ./openfoam.sh --openfoam_version=2206 --openfoam_compiler=aocc --openfoam_compiler_version=4.0.0 \\
             --openfoam_mpi=openmpi --openfoam_mpi_compiler=aocc --openfoam_mpi_version=4.1.4  --openfoam_mpi_compiler_version=4.0.0 \\
             --openfoam_flags=\"-O3 -march=znver3 -fopenmp\"

    <openfoam_version>:             Specify the version of openfoam


    <openfoam_compiler>:            Specify the compiler to build openfoam
                                    The following are the avialble compilers :
                                    aocc
                                    gcc
                                    intel-oneapi-compilers-classic

    <openfoam_compiler_version>:    Specify the version to build <openfoam_compiler>
                                    for "aocc" as <openfoam_compiler> the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <openfoam_mpi>:                 Specify the mpi to build openfoam
                                    The following are the available mpi options :
                                    openmpi
                                    intel-mpi
                                    intel-oneapi-mpi

    <openfoam_mpi_version>:         Specify the version to build <openfoam_mpi>

    <openfoam_mpi_compiler>:        Specify the compiler to build <openfoam_mpi>
                                    The following are the available compiler names :
                                    aocc
                                    gcc
                                    intel-oneapi-compilers-classic

    <openfoam_mpi_compiler_version>:Specify the version to build <openfoam_mpi_compiler>
                                    for <openfoam_mpi_compiler> as "aocc" the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <openfoam_mpi_flags> [optional]:Specify the flags to buid <openfoam_mpi>
                                    default flags for <openfoam_mpi>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <openfoam_flags> [optional]    :Specify the flags to build openfoam
                                    Default flags for <openfoam_compiler>
                                        aocc :                          '-O3 -march=znver3 -fopenmp'
                                        gcc  :                          '-O3 -march=znver3 -fopenmp -fPIC'
                                        intel-oneapi-compilers  :       '-O3 -march=znver3 -qopenmp -fPIC'
                                        intel-oneapi-compilers-classic: '-O3 -march=znver3 -qopenmp -fPIC'

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
if [[ -z $openfoam_version ]] || [[ -z $openfoam_compiler ]] || [[ -z $openfoam_compiler_version ]] || [[ -z $openfoam_mpi ]] || [[ -z $openfoam_mpi_version ]] || [[ -z $openfoam_mpi_compiler ]] || [[ -z $openfoam_mpi_compiler_version ]];then
    openfoam_usage
    exit
fi
min_options=7
if [[ $n_arg -gt ${min_options} ]];
then
    load_check_flags $[$n_arg-${min_options}] openfoam_mpi_flags openfoam_flags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        openfoam_usage
        exit
    fi
fi
            
DIR_STR=openfoam/${openfoam_version}/${openfoam_compiler}/${openfoam_compiler_version}/${openfoam_mpi}/${openfoam_mpi_version}/${openfoam_mpi_compiler}

build_check $DIR_STR/$openfoam_mpi_compiler_version $openfoam_flags
export rebuilt=$?

if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                  OPENFOAM IS ALREADY COMPILED WITH THE SPECIFIED OPTION"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/${openfoam_mpi_compiler_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                    REQUESTED OPENFOAM IS NOT PRESENT IN MODULES BUILDING OPENFOAM                         #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                                       HOSTNAME:    $(hostname)                                            #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    export openfoam_build=${home_dir}/apps/${DIR_STR}/${openfoam_mpi_compiler_version}
    export openfoam_source=${home_dir}/source_codes/${DIR_STR}/${openfoam_mpi_compiler_version}
    mkdir -p ${openfoam_build}
    mkdir -p ${openfoam_source}

    cd ${openfoam_source}
    if [  -e "${openfoam_source}/OpenFOAM-v${openfoam_version}.tgz" ] && [ -e "${openfoam_source}/ThirdParty-v${openfoam_version}.tgz" ];
    then
        echo "OpenFOAM-v${openfoam_version} source file found in ${openfoam_source}"
    else
        echo "Downloading OpenFOAM-v${openfoam_version}"
        wget https://dl.openfoam.com/source/v${openfoam_version}/OpenFOAM-v${openfoam_version}.tgz
        wget https://dl.openfoam.com/source/v${openfoam_version}/ThirdParty-v${openfoam_version}.tgz
    fi
    cd ${openfoam_build}
    rm -rf *
    tar -xzf ${openfoam_source}/OpenFOAM-v${openfoam_version}.tgz -C $openfoam_build
    tar -xzf ${openfoam_source}/ThirdParty-v${openfoam_version}.tgz -C $openfoam_build
    export FOAM_VERBOSE=set
    export openfoam_cur_dir=$PWD
    cd $home_dir/scripts
    if [[ ${openfoam_mpi_flags} ]];
    then
        bash ${home_dir}/scripts/mpi.sh --mpi_flags=${openfoam_mpi_flags} --mpi=${openfoam_mpi} --mpi_version=${openfoam_mpi_version} --mpi_compiler=${openfoam_mpi_compiler} --mpi_compiler_version=${openfoam_mpi_compiler_version}
    else
        bash ${home_dir}/scripts/mpi.sh --mpi=${openfoam_mpi} --mpi_version=${openfoam_mpi_version} --mpi_compiler=${openfoam_mpi_compiler} --mpi_compiler_version=${openfoam_mpi_compiler_version}
    fi
    cd $openfoam_cur_dir
    module load ${openfoam_mpi}/${openfoam_mpi_version}/${openfoam_mpi_compiler}/${openfoam_mpi_compiler_version}
    sed -i "s/FOAM_MPI=openmpi-${openfoam_mpi_version}/FOAM_MPI=openmpi-${openfoam_mpi_version}/g" ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/config.sh/mpi
    case $openfoam_mpi in
    openmpi)
        export WM_MPLIB=OPENMPI
        export MPI_ARCH_PATH=$MPIROOT
        export MPI_HOME=$MPIROOT
        export config_file=openmpi
        export FOAM_MPI=openmpi
        ;;
    intel-oneapi-mpi | intel-mpi)
        export WM_MPLIB=INTELMPI
        export MPI_ARCH_PATH=$MPIROOT
        export I_MPI_CC=icc
        export I_MPI_CXX=icpc
        export MPI_HOME=$MPIROOT
        export config_file=intelmpi
        export FOAM_MPI=intelmpi
        ;;
    *)
        echo "$openfoam_mpi not found"
        exit
        ;;
    esac
    sed -i "s/WM_MPLIB=SYSTEMOPENMPI/WM_MPLIB=$WM_MPLIB/g" ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/bashrc

    echo "export WM_MPLIB=$WM_MPLIB
    export MPI_ARCH_PATH=$MPIROOT
    export MPI_HOME=$MPIROOT
    export I_MPI_CC=$I_MPI_CC
    export I_MPI_CXX=$I_MPI_CXX
    export FOAM_MPI=$FOAM_MPI
    " > ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/config.sh/prefs.${config_file}

    export openfoam_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/compiler.sh --compiler_name=$openfoam_compiler --compiler_version=$openfoam_compiler_version
    cd $openfoam_cur_dir
    module load ${openfoam_compiler}/${openfoam_compiler_version}
    case $openfoam_compiler in
    aocc)
        export CC=clang
        export FC=flang
        export CXX=clang++
        export F90=flang
        export F77=flang
        export AR=llvm-ar
        export RANLIB=llvm-ranlib
        export NM=llvm-nm
        if [[ $openfoam_flags ]];then
            export build_type=custom
        else
            export openfoam_flags="-O3 -march=znver3 -fopenmp"
            export build_type=default
        fi

        export CFLAGS=$openfoam_flags
        export CXXFLAGS=$openfoam_flags
        export FCFLAGS=$openfoam_flags
        export FFLAGS=$openfoam_flags

        export WM_CXXFLAGS="$CXXFLAGS"
        export WM_CFLAGS="$CFLAGS"
        sed -i 's/WM_COMPILER=Gcc/WM_COMPILER=Amd/' ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/bashrc
        sed -i 's/clang++ -std=c++11/& -pthread/g' ${openfoam_build}/OpenFOAM-v${openfoam_version}/wmake/rules/General/Clang/c++
        comp=Amd
        ;;
    gcc)
        export CC=gcc
        export CXX=g++
        export F90=gfortran
        export F77=gfortran
        export FC=gfortran

        if [[ $openfoam_flags ]];then
            export build_type=custom
        else
            export openfoam_flags="-O3 -march=znver3 -fopenmp -fPIC"
            export build_type=default
        fi

        export CFLAGS=$openfoam_flags
        export CXXFLAGS=$openfoam_flags
        export FCFLAGS=$openfoam_flags
        export FFLAGS=$openfoam_flags

        export WM_CXXFLAGS="$CXXFLAGS"
        export WM_CFLAGS="$CFLAGS"
        sed -i 's/g++ -std=c++11/& -pthread/g' ${openfoam_build}/OpenFOAM-v${openfoam_version}/wmake/rules/General/Gcc/c++
        comp=Gcc
        ;;
    intel-oenapi-compilers | intel-oneapi-compilers-classic)
        export CC=icc
        export CXX=icpc
        export F90=ifort
        export F77=ifort
        export FC=ifort

        if [[ $openfoam_flags ]];then
            export build_type=custom
        else
            export openfoam_flags="-O3 -march=znver3 -qopenmp -fPIC"
            export build_type=default
        fi
        export CFLAGS=$openfoam_flags
        export CXXFLAGS=$openfoam_flags
        export FCFLAGS=$openfoam_flags
        export FFLAGS=$openfoam_flags

        export WM_CXXFLAGS="$CXXFLAGS"
        export WM_CFLAGS="$CFLAGS"
        sed -i 's/WM_COMPILER=Gcc/WM_COMPILER=Icc/' ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/bashrc
        sed -i 's/icpc -std=c++11/& -pthread/g' ${openfoam_build}/OpenFOAM-v${openfoam_version}/wmake/rules/General/Icc/c++
        comp=Icc
        ;;
    *)
        echo "compiler not found"
        exit
        ;;
    esac
    echo "export WM_CXXFLAGS=\"$CXXFLAGS\"
    export WM_CFLAGS=\"$CFLAGS\"
    " > ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/config.sh/prefs.${comp}

    echo "export WM_MPLIB=$WM_MPLIB
    export MPI_ARCH_PATH=$MPIROOT
    export MPI_HOME=$MPIROOT
    export I_MPI_CC=$I_MPI_CC
    export I_MPI_CXX=$I_MPI_CXX
    export FOAM_MPI=$FOAM_MPI
    export WM_CXXFLAGS=\"$CXXFLAGS\"
    export WM_CFLAGS=\"$CFLAGS\"
    export FOAM_VERBOSE=set
    " > ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/config.sh/prefs.sh

    source ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/bashrc
    echo "WM_PROJECT_DIR : $WM_PROJECT_DIR"
    echo " Building in progress ... "
    echo "Build OpenFOAM-v${openfoam_version}"
    cd OpenFOAM-v${openfoam_version}

    time ./Allwmake -j $(nproc) all -k

    source ${openfoam_build}/OpenFOAM-v${openfoam_version}/etc/bashrc
    cd ${openfoam_build}/OpenFOAM-v${openfoam_version}/platforms/linux64${comp}DPInt32Opt/bin/

    if [ -e "simpleFoam" ] && [ -e "blockMesh" ] && [ -e "snappyHexMesh" ] && [ -e "decomposePar" ];
    then
        echo "OPENFOAM BUILD SUCCESSFUL"
        mkdir -p ${home_dir}/module_files/${DIR_STR}
        echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
        puts stderr "\tAdds OPENFOAM to your environment variables"
                        }
    module-whatis \" ${DIR_STR}/${openfoam_mpi_compiler_version}
    Build flags:       $openfoam_flags
    Build type:        $build_type \"
    set             root                  ${openfoam_build}/OpenFOAM-v${openfoam_version}/platforms/linux64${comp}DPInt32Opt
    setenv          OPENFOAMROOT            \$root
    prepend-path    PATH                    \$root/bin

    " > ${home_dir}/module_files/$DIR_STR/${openfoam_mpi_compiler_version}
    else
        echo "OPENFOAM BUILD Failed"
    fi
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$openfoam_mpi_compiler_version__$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

