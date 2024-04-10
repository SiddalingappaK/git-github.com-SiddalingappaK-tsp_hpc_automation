#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                       CLOVERLEAF BUILD SCRIPT                                             #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"
cloverleaf_usage()
{
    echo "
    Usage: ./cloverleaf.sh --cloverleaf_version=<cloverleaf_version> \\
                           --cloverleaf_mpi=<cloverleaf_mpi> \\
                           --cloverleaf_mpi_version=<cloverleaf_mpi_version> \\
                           --cloverleaf_mpi_compiler=<cloverleaf_mpi_compiler> \\
                           --cloverleaf_mpi_compiler_version=<cloverleaf_mpi_compiler_version> \\
                           --colverleaf_mpi_cflags=<colverleaf_mpi_cflags> \\
                           --colverleaf_mpi_cxxflags=<colverleaf_mpi_cxxflags> \\
                           --colverleaf_mpi_fcflags=<colverleaf_mpi_fcflags> \\
                           --cloverleaf_cflags=<cloverleaf_cfalgs> \\
                           --cloverleaf_fcflags=<cloverleaf_fcflags>
    Builds the cloverleaf of specified version with compiler specifications and mpi specifications.

    Example: ./cloverleaf.sh --cloverleaf_version=1.3 --cloverleaf_mpi=openmpi \\
            --cloverleaf_mpi_version=4.1.4 --cloverleaf_mpi_compiler=aocc \\
            --cloverleaf_mpi_compiler_version=4.0.0

    <cloverleaf_version>:                  specify the version to build cloverleaf

    <cloverleaf_mpi>:                      specify the mpi to build cloverleaf
                                           **NOTE: For intel-mpi and intel-oneapi-mpi no flags are required as it will be build with spack.
                                           The following are the available mpis:
                                           onempi
                                           intel-mpi
                                           intel-oneapi_mpi

    <cloverleaf_mpi_version>:              specify the version of <cloverleaf_mpi>

    <cloverleaf_mpi_compiler>:             specify the compiler to build <cloverleaf_mpi>
                                           **NOTE: For the two <hpl_mpi>s intel-mpi and intel-oneapi-mpi, <hpl_mpi_compiler> will be used
                                               as 'wrapper compiler' and not to be used to build <hpl_mpi> through spack.
                                           The following are the available compilers:
                                           aocc
                                           gcc
                                           intel-oneapi-compilers-classic

    <cloverleaf_mpi_compiler_version>:     specify the version of <cloverleaf_mpi_compiler>
                                           for "aocc" as <cloverleaf_mpi_compiler> the following are the supported versions:
                                           3.2.0
                                           4.0.0

    <colverleaf_mpi_cflags> [optional] :   specify the CFLAGS to build <cloverleaf_mpi>
                                           default CFLAGS for <mpi_compiler>
                                           aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                           gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast
                                           intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <colverleaf_mpi_cxxflags> [optional] : specify the flags to build <cloverleaf_mpi>
                                           default cloverleaf_mpi_flags for <mpi_compiler>
                                           aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                           gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast
                                           intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <colverleaf_mpi_fcflags> [optional] :  specify the flags to build <cloverleaf_mpi>
                                           default cloverleaf_mpi_flags for <mpi_compiler>
                                           aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                           gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast
                                           intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <cloverleaf_cfalgs> [optional]:        specify the CFLAGS to build cloverleaf
                                           default CFLAGS for <cloverleaf_compiler>
                                           aocc:                           '-O3 -funroll-loops -march=znver4 -fopenmp -fPIC -ffast-math'
                                           gcc:                            '-O3 -funroll-loops -march=znver4 -fopenmp -fPIC -ffast-math'
                                           intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC -no-prec-div'

    <cloverleaf_fcfalgs> [optional]:       specify the FCFLAGS to build cloverleaf
                                           default FCFLAGS for <cloverleaf_compiler>
                                           aocc:                           '-O3 -funroll-loops -march=znver4 -fopenmp -fPIC -ffast-math'
                                           gcc:                            '-O3 -funroll-loops -march=znver4 -fopenmp -fPIC -ffast-math'
                                           intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC -no-prec-div'

    INVALID COMBINATIONS :
        1. cloverleaf_mpi="intel-mpi" and cloverleaf_mpi_compiler="aocc"
        2. cloverleaf_mpi="intel-mpi" and cloverleaf_mpi_compiler="gcc"
        3. cloverleaf_mpi="intel-oneapi-mpi" and cloverleaf_mpi_compiler="aocc"
        4. cloverleaf_mpi="intel-oneapi-mpi" and cloverleaf_mpi_compiler="gcc"

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
    loaded=$?
    n_arg=$[$n_arg+$loaded]
    shift 1
done
if [[ $cloverleaf_mpi == intel-mpi || $cloverleaf_mpi == intel-oneapi-mpi ]] && [[ $cloverleaf_mpi_compiler == aocc || $cloverleaf_mpi_compiler == gcc ]];then
        echo "THIS IS A INVALID CASE"
        cloverleaf_usage
        exit
fi
if [[ -z $cloverleaf_version ]] || [[ -z $cloverleaf_mpi  ]] || [[ -z $cloverleaf_mpi_version ]] || [[ -z $cloverleaf_mpi_compiler ]] || [[ -z $cloverleaf_mpi_compiler_version ]];
then
    cloverleaf_usage
    exit
fi
manditory_options=5
if [[ $n_arg -gt ${manditory_options} ]];
then
    load_check_flags $[$n_arg-${manditory_options}] cloverleaf_mpi_cflags cloverleaf_mpi_cxxflags cloverleaf_mpi_fcflags cloverleaf_cflags cloverleaf_fcflags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        cloverleaf_usage
        exit
    fi
fi
DIR_STR=cloverleaf/$cloverleaf_version/$cloverleaf_mpi/$cloverleaf_mpi_version/$cloverleaf_mpi_compiler
build_check $DIR_STR/$cloverleaf_mpi_compiler_version CFlags:FCFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$cloverleaf_cflags:$cloverleaf_fcflags:$cloverleaf_mpi_cflags:$cloverleaf_mpi_cxxflags:$cloverleaf_mpi_fcflags"
export rebuilt=$?
if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                      CLOVERLEAF IS PRESENT IN MODULES LOADING MODULE                                      #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/$cloverleaf_mpi_compiler_version
else
    rm -rf $home_dir/apps/$DIR_STR
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                 REQUESTED CLOVERLEAF IS NOT PRESENT IN MODULES BUILDING CLOVERLEAF                        #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                                       HOSTNAME:    $(hostname)                                            #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    lock_check "$DIR_STR/$cloverleaf_mpi_compiler_version"
    locked_files=""
    trap 'unlock "$locked_files"' EXIT SIGINT
    lock "$DIR_STR/$cloverleaf_mpi_compiler_version"
    mkdir -p $home_dir/source_codes/cloverleaf
    if [ -e "$home_dir/source_codes/cloverleaf/v${cloverleaf_version}.tar.gz" ];
    then
        echo "Source file already exists building..."
    else
        wget -P $home_dir/source_codes/cloverleaf \
        https://github.com/UK-MAC/CloverLeaf_ref/archive/v${cloverleaf_version}.tar.gz
    fi
    mkdir -p $home_dir/apps/$DIR_STR/$cloverleaf_mpi_compiler_version
    tar -xf $home_dir/source_codes/cloverleaf/v${cloverleaf_version}.tar.gz -C $home_dir/apps/$DIR_STR/$cloverleaf_mpi_compiler_version
    cd $home_dir/apps/$DIR_STR/$cloverleaf_mpi_compiler_version/CloverLeaf_ref-${cloverleaf_version}


    case $cloverleaf_mpi_compiler in
    aocc)
        echo "using AOCC compiler"
        if [[ -z $cloverleaf_cflags ]];
        then
            echo "cloverleaf_cflags is not defined. Choosing default CFLAGS"
            export cloverleaf_cflags="-fopenmp -O3 -march=znver4 -ffast-math -funroll-loops"
            export Type_CFlags=default
        else
            export Type_CFlags=custom
        fi
        if [[ -z $cloverleaf_fcflags ]];
        then
            echo "cloverleaf_fcflags is not defined. Choosing default FCFLAGS"
            export cloverleaf_fcflags="-fopenmp -O3 -march=znver4 -ffast-math -funroll-loops"
            export Type_FCFlags=default
        else
            export Type_FCFlags=custom
        fi
        ;;

    gcc)
        echo "using GCC compiler"
        if [[ -z $cloverleaf_cflags ]];
        then
            echo "cloverleaf_cflags is not defined. Choosing default CFLAGS"
            export cloverleaf_cflags="-fopenmp -O3 -march=znver4 -funroll-loops -ffloat-store"
            export Type_CFlags=default
        else
            export Type_CFlags=custom
        fi
        if [[ -z $cloverleaf_fcflags ]];
        then
            echo "cloverleaf_fcflags is not defined. Choosing default FCFLAGS"
            export cloverleaf_fcflags="-fopenmp -O3 -march=znver4 -funroll-loops -ffloat-store"
            export Type_FCFlags=default
        else
            export Type_FCFlags=custom
        fi
        ;;
    icc | intel-oneapi-compilers-classic)
        echo "using ICC compiler"
        if [[ -z $cloverleaf_cflags ]];
        then
            echo "cloverleaf_cflags is not defined. Choosing default CFLAGS"
            export cloverleaf_cflags="-qopenmp -O3 -march=skylake-avx512"
            export Type_CFlags=default
        else
            export Type_CFlags=custom
        fi
        if [[ -z $cloverleaf_fcflags ]];
        then
            echo "cloverleaf_fcflags is not defined. Choosing default FCFLAGS"
            export cloverleaf_fcflags="-qopenmp -O3 -march=skylake-avx512"
            export Type_FCFlags=default
        else
            export Type_FCFlags=custom
        fi
        ;;
    *)
        echo "compiler is not avaiable, exiting..."
        exit
        ;;
    esac
    export CFLAGS=$cloverleaf_cflags
    export FCFLAGS=$cloverleaf_fcflags

    #mpi
    cloverleaf_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/mpi.sh --mpi_cflags=$cloverleaf_mpi_cflags --mpi_cxxflags=$cloverleaf_mpi_cxxflags --mpi_fcflags=$cloverleaf_mpi_fcflags --mpi=$cloverleaf_mpi --mpi_version=$cloverleaf_mpi_version --mpi_compiler=$cloverleaf_mpi_compiler --mpi_compiler_version=$cloverleaf_mpi_compiler_version
    cd $cloverleaf_cur_dir
    module load $cloverleaf_mpi/$cloverleaf_mpi_version/$cloverleaf_mpi_compiler/$cloverleaf_mpi_compiler_version
    lock "$cloverleaf_mpi/$cloverleaf_mpi_version/$cloverleaf_mpi_compiler/$cloverleaf_mpi_compiler_version"
    mpi_mf=$home_dir/module_files/$cloverleaf_mpi/$cloverleaf_mpi_version/$cloverleaf_mpi_compiler/$cloverleaf_mpi_compiler_version
    Type_mpi_CFlags=$(cat $mpi_mf| grep "^ *Type_CFlags" | cut -d ":" -f 2)
    Type_mpi_CXXFlags=$(cat $mpi_mf | grep "^ *Type_CXXFlags" | cut -d ":" -f 2)
    Type_mpi_FCFlags=$(cat $mpi_mf | grep "^ *Type_FCFlags" | cut -d ":" -f 2)
    mpi_CFlags=$(cat $mpi_mf | grep "^ *CFlags" | cut -d ":" -f 2)
    mpi_CXXFlags=$(cat $mpi_mf | grep "^ *CXXFlags" | cut -d ":" -f 2)
    mpi_FCFlags=$(cat $mpi_mf | grep "^ *FCFlags" | cut -d ":" -f 2)



    cloverleaf_cur_dir=$PWD
    cd $home_dir/scripts
    bash $home_dir/scripts/compiler.sh --compiler_name=$cloverleaf_mpi_compiler --compiler_version=$cloverleaf_mpi_compiler_version
    cd $cloverleaf_cur_dir
    module load $cloverleaf_mpi_compiler/$cloverleaf_mpi_compiler_version
    lock "$cloverleaf_mpi_compiler/$cloverleaf_mpi_compiler_version"

    case $cloverleaf_mpi in
        openmpi)
            export MPICC=mpicc
            export MPIFC=mpif90
            ;;
        intel-mpi | intel-oneapi-mpi)
            export MPICC=mpiicc
            export MPIFC=mpiifort
            ;;
        *)
            echo "mpi is not available,exiting..."
            exit
            ;;
    esac

    echo "
FLAGS=${FCFLAGS}
CFLAGS=${CFLAGS} -c
MPI_COMPILER=${MPIFC}
C_MPI_COMPILER=${MPICC}
" > new_makefile
    export num=$[$(cat Makefile|wc -l)-$(cat -n Makefile | grep "clover_leaf: c_lover" | awk '{print $1}')+1]
    cat Makefile | tail -n ${num} >> new_makefile
    cp -rf new_makefile Makefile
    make
    if [[ -f ./clover_leaf ]];
    then
        echo "#===========================================================================================================#"
        echo "#                                                                                                           #"
        echo "#                                            COLVERLEAF BUILD SUCCESSFUL                                    #"
        echo "#                                                                                                           #"
        echo "#===========================================================================================================#"
        mkdir -p ${home_dir}/module_files/$DIR_STR
        echo "#%Module1.0#####################################################################
        proc ModulesHelp { } {
            puts stderr "\tsets the CLOVERLEAFROOT path"
        }
        module-whatis \"sets the CLOVERLEAFROOT path
        Type_CFlags:        $Type_CFlags
        CFlags:             $cloverleaf_cflags
        Type_FCFlags:       $Type_FCFlags
        FCFlags:            $cloverleaf_fcflags
        Type_mpi_CFlags:    $Type_mpi_CFlags
        mpi_CFlags:         $mpi_CFlags
        Type_mpi_CXXFlags:  $Type_mpi_CXXFlags
        mpi_CXXFlags:       $mpi_CXXFlags
        Type_mpi_FCFlags:   $Type_mpi_FCFlags
        mpi_FCFlags:        $mpi_FCFlags\"
        setenv     CLOVERLEAFROOT   $home_dir/apps/$DIR_STR/$cloverleaf_mpi_compiler_version/CloverLeaf_ref-${cloverleaf_version}
        " > ${home_dir}/module_files/$DIR_STR/$cloverleaf_mpi_compiler_version
        module load $DIR_STR/$cloverleaf_mpi_compiler_version
    else
        echo "#===========================================================================================================#"
        echo "#                                                                                                           #"
        echo "#                                               CLOVERLEAF BUILD FAILED                                     #"
        echo "#                                                                                                           #"
        echo "#===========================================================================================================#"
        exit
    fi
    unlock "$locked_files"
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$cloverleaf_mpi_compiler_version_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

