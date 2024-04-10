#!/bin/bash
if [ -z $home_dir ];
then
    source ./env_set.sh
else
    source $home_dir/scripts/env_set.sh
fi
print_line header LAMMPS
lammps_usage()
{
    echo "
    Usage: ./lammps.sh --lammps_version=<lammps_version> \\
                       --lammps_compiler=<lammps_compiler>\\
                       --lammps_compiler_version=<lammps_compiler_version>\\
                       --lammps_math=<lammps_math> \\
                       --lammps_math_version=<lammps_math_version> \\
                       --lammps_math_compiler=<lammps_math_compiler> \\
                       --lammps_math_compiler_version=<lammps_math_compiler_version> \\
                       --lammps_mpi=<lammps_mpi> \\
                       --lammps_mpi_version=<lammps_mpi_version> \\
                       --lammps_mpi_compiler=<lammps_mpi_compiler> \\
                       --lammps_mpi_compiler_version=<lammps_mpi_compiler_version> \\
                       --lammps_mpi_cflags=<lammps_mpi_cflags> \\
                       --lammps_mpi_cxxflags=<lammps_mpi_cxxflags> \\
                       --lammps_mpi_fcflags=<lammps_mpi_fcflags> \\
                       --lammps_cxxflags=<lammps_cxxflags>
    Builds the lammps benchmark of specifies version with mpi specifications and math library specification.

    Example: ./lammps.sh --lammps_version=stable --lammps_compiler=aocc --lammps_compiler_version=4.0.0 --lammps_math=aocl \\
    --lammps_math_version=4.0 --lammps_math_compiler=aocc --lammps_math_compiler_version=4.0.0 --lammps_mpi=openmpi  \\
    --lammps_mpi_version=4.1.4 --lammps_mpi_compiler=aocc --lammps_mpi_compiler_version=4.0.0




    <lammps_version>:                  specify the version to build lammps

    <lammps_compiler>:                 specify the name of compiler to build lammps.The following the the availbale compilers:
                                       aocc
                                       gcc
                                       intel-oneapi-compilers-classic

    <lammps_compiler_version>:         specify the vesrion of <lammps_compiler>
                                       for "aocc" as <lammps_compiler> the following are the supported versions:
                                          3.2.0
                                          4.0.0

    <lammps_math_lib_vendor>:          specify the math library vendor to build lammps.The follwoing are available math libarary vendors:
                                       aocl
                                       intel-mkl
                                       intel-oneapi-mkl
    <lammps_math_version>:             specify the version of <lammps_math_lib_vendor>
                                       for aocl as <lammps_math_lib_vendor>, the following are the available versions:
                                       4.0
                                       3.2.0
    <lammps_math_compiler>:            specify the compiler to build <lammps_math_lib_vendor>.The following are the available compilers:
                                       aocc
                                       gcc
                                       intel-oneapi-compilers-classic
    <lammps_math_compiler_version>:    specify the version of <lammps_math_compiler>
                                       for "aocc" as <lammps_math_compiler> the following are the supported versions:
                                       3.2.0
                                       4.0.0

    <lammps_mpi>:                      specify the mpi to build lammps.The following are the available mpi:
                                       **NOTE: For intel-mpi and intel-oneapi-mpi no flags are required as it will be build with spack.
                                       openmpi
                                       intel-mpi
                                       intel-oneapi-mpi
    <lammps_mpi_version>:              specify the version of <lammps_mpi>

    <lammps_mpi_compiler>:             specify the compiler to build <lammps_mpi>.
                                       **NOTE: For the two <lammps_mpi>s intel-mpi and intel-oneapi-mpi, <lammps_mpi_compiler> will be used
                                       as 'wrapper compiler' and not to be used to build <lammps_mpi> through spack.
                                       The following are the available compilers:
                                       aocc
                                       gcc
                                       intel-oneapi-compilers-classic

    <lammps_mpi_compiler_version>:     specify the version of <lammps_mpi_compiler>
                                       for "aocc" as <lammps_mpi_compiler> the following are the supported versions:
                                       3.2.0
                                       4.0.0

    <lammps_mpi_cflags> [optional]:    specify the CFLAGS to build <lammps_mpi>
                                       default CFLAGS for <lammps_mpi_compiler>
                                       aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                       gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                       intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <lammps_mpi_cxxflags> [optional]:  specify the CXXFLAGS to build <lammps_mpi>
                                       default CXXFLAGS for <lammps_mpi_compiler>
                                       aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                       gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                       intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <lammps_mpi_cflags> [optional]:    specify the FCFLAGS to build <lammps_mpi>
                                       default FCFLAGS for <lammps_mpi_compiler>
                                       aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                       gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                       intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'C'

    <lammps_cxxflags> [optional]:      specify the CXXFLAGS to build lammps
                                       default CXXFLAGS for <lammps_mpi_compiler>
                                       aocc:             '-O3 -fopenmp'
                                       gcc:              '-O3 -fopenmp'
                                       intel-oneapi-compilers-classic: '-O3 -qopenmp'


"

}
n_arg=0
while [ $# -gt 0 ];
do
    load $1
    loaded=$?
    n_arg=$[$n_arg+$loaded]
    shift 1
done
if [[ -z $lammps_version ]] || [[ -z $lammps_compiler ]] || [[ -z $lammps_compiler_version ]] || [[ -z $lammps_math ]] || [[ -z $lammps_math_version ]] \
|| [[ -z $lammps_math_compiler ]] || [[ -z $lammps_math_compiler_version ]] || [[ -z $lammps_mpi ]] || \
[[ -z $lammps_mpi_version ]] || [[ -z $lammps_mpi_compiler ]] || [[ -z $lammps_mpi_compiler_version ]];
then
    lammps_usage
    exit
fi
manditory_options=11
if [[ $n_arg -gt ${manditory_options} ]];
then
    load_check_flags $[$n_arg-${manditory_options}] lammps_mpi_cflags lammps_mpi_cxxflags lammps_mpi_fcflags lammps_cxxflags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        lammps_usage
        exit
    fi
fi
export DIR_STR=lammps/$lammps_version/$lammps_compiler/$lammps_compiler_version/$lammps_math/$lammps_math_version/$lammps_math_compiler/$lammps_math_compiler_version/$lammps_mpi/$lammps_mpi_version/$lammps_mpi_compiler
build_check $DIR_STR/$lammps_mpi_compiler_version CXXFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$lammps_cxxflags:$lammps_mpi_cflags:$lammps_mpi_cxxflags:$lammps_mpi_fcflags"
export rebuilt=$?
if [ $rebuilt == 0 ];
then
    print_line found LAMMPS
    module load ${DIR_STR}/${lammps_mpi_compiler_version}
else
    mkdir -p $home_dir/log_files/${DIR_STR}
    {
    print_line not_found LAMMPS
    print_line hostname $hostname
    lock_check "$DIR_STR/${lammps_mpi_compiler_version}"
    build_check $DIR_STR/$lammps_mpi_compiler_version CXXFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$lammps_cxxflags:$lammps_mpi_cflags:$lammps_mpi_cxxflags:$lammps_mpi_fcflags"
    rebuilt=$?
    if [ $rebuilt == 0 ];
    then
        print_line found LAMMPS
        module load ${DIR_STR}/${lammps_mpi_compiler_version}
        exit
    fi
    locked_files=""
    trap 'unlock "$locked_files"' EXIT SIGINT
    lock "$DIR_STR/${lammps_mpi_compiler_version}"
    rm -rf $home_dir/module_files/$DIR_STR/${lammps_mpi_compiler_version}
    lammps_cur_dir=$PWD
    cd $home_dir/scripts
    bash $home_dir/scripts/mathlib.sh --math=$lammps_math --math_version=$lammps_math_version --math_compiler=$lammps_math_compiler --math_compiler_version=$lammps_math_compiler_version
    cd $lammps_cur_dir
    module load $lammps_math/$lammps_math_version/$lammps_math_compiler/$lammps_math_compiler_version
    lock "$lammps_math/$lammps_math_version/$lammps_math_compiler/$lammps_math_compiler_version"
    case $lammps_math in
    aocl)
        export OPTIONS=" -DFFT=FFTW3 -DFFTW3F_LIBRARY="$AOCLROOT/lib/libfftw3f.so" -DFFTW3F_OMP_LIBRARY="$AOCLROOT/lib/libfftw3f_omp.so" -DFFT_FFTW_THREADS=on $OPTIONS"
        ;;
    intel-mkl | intel-oneapi-mkl )
        export OPTIONS=" -DFFT=MKL -DFFT_MKL_THREADS=on"
        ;;
    fftw)
        echo ""
        ;;
    *)
        echo "$lammps_math is not found"
        exit 1
        ;;
    esac

    #mpi
    lammps_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/mpi.sh --mpi_cflags="$lammps_mpi_cflags" --mpi_cxxflags="$lammps_mpi_cxxflags" --mpi_fcflags="$lammps_mpi_fcflags" \
    --mpi=$lammps_mpi --mpi_version=$lammps_mpi_version --mpi_compiler=$lammps_mpi_compiler --mpi_compiler_version=$lammps_mpi_compiler_version
    cd $lammps_cur_dir
    module load $lammps_mpi/$lammps_mpi_version/$lammps_mpi_compiler/$lammps_mpi_compiler_version
    lock "$lammps_mpi/$lammps_mpi_version/$lammps_mpi_compiler/$lammps_mpi_compiler_version"
    mpi_mf=$home_dir/module_files/$lammps_mpi/$lammps_mpi_version/$lammps_mpi_compiler/$lammps_mpi_compiler_version
    Type_mpi_CFlags=$(cat $mpi_mf| grep "^ *Type_CFlags" | cut -d ":" -f 2)
    Type_mpi_CXXFlags=$(cat $mpi_mf | grep "^ *Type_CXXFlags" | cut -d ":" -f 2)
    Type_mpi_FCFlags=$(cat $mpi_mf | grep "^ *Type_FCFlags" | cut -d ":" -f 2)
    mpi_CFlags=$(cat $mpi_mf | grep "^ *CFlags" | cut -d ":" -f 2)
    mpi_CXXFlags=$(cat $mpi_mf | grep "^ *CXXFlags" | cut -d ":" -f 2)
    mpi_FCFlags=$(cat $mpi_mf | grep "^ *FCFlags" | cut -d ":" -f 2)

    #compiler
    lammps_cur_dir=$PWD
    cd $home_dir/scripts
    bash $home_dir/scripts/compiler.sh --compiler_name=$lammps_compiler --compiler_version=$lammps_compiler_version
    cd $lammps_cur_dir
    module load $lammps_compiler/$lammps_compiler_version
    lock "$lammps_compiler/$lammps_compiler_version"
    case $lammps_compiler in
    aocc)
        if [[ -z $lammps_cxxflags ]];
        then
            echo "lammps_cxxflags is not defined. Choosing default CXXFLAGS"
            export lammps_cxxflags="-O3 -fopenmp"
            export Type_CXXFlags=default
        else
            export Type_CXXFlags=custom
        fi
        export CXXFLAGS=$lammps_cxxflags
        export CXX=clang++
        ;;
    gcc)
        if [[ -z $lammps_cxxflags ]];
        then
            echo "lammps_cxxflags is not defined. Choosing default CXXFLAGS"
            export lammps_cxxflags="-O3 -fopenmp"
            export Type_CXXFlags=default
        else
            export Type_CXXFlags=custom
        fi
        export CXXFLAGS=$lammps_cxxflags
        export CXX=g++
        ;;
    intel-oneapi-compilers-classic)
        if [[ -z $lammps_cxxflags ]];
        then
            echo "lammps_cxxflags is not defined. Choosing default CXXFLAGS"
            export lammps_cxxflags="-O3 -qopenmp -xHost -O3 -fp-model fast=2 -no-prec-div -qoverride-limits -qopt-zmm-usage=high "
            export Type_CXXFlags=default
        else
            export Type_CXXFlags=custom
        fi
        export CXXFLAGS=$lammps_cxxflags
        export CXX=icpc
        ;;
    *)
        echo "$lammps_mpi_compiler compiler not found"
        exit 1
        ;;
    esac

    export BUILD_DIR=$home_dir/source_codes/$DIR_STR/$lammps_mpi_compiler_version
    export INSTALL_DIR=$home_dir/apps/$DIR_STR/$lammps_mpi_compiler_version
    mkdir -p $INSTALL_DIR
    mkdir -p $BUILD_DIR
    rm -rf $BUILD_DIR/*
    cd $BUILD_DIR
    wget https://download.lammps.org/tars/lammps-${lammps_version}.tar.gz
    tar -xf lammps-${lammps_version}.tar.gz
    lammps_dir=$(ls -l | grep "^d" | awk '{print $9}')
    cd $lammps_dir
    mkdir build
    cd build
    cmake ../cmake $OPTIONS  -DCMAKE_BUILD_TYPE=Release  -DCMAKE_CXX_COMPILER="$CXX"  \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" -DENABLE_THREAD=true -DBUILD_MPI=yes -DBUILD_SHARED_LIBS=yes \
       -DPKG_KSPACE=on -DFFT_SINGLE=yes -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" -DPKG_MOLECULE=yes -DPKG_RIGID=yes -DPKG_EXTRA-DUMP=yes -DPKG_MANYBODY=yes \
        -DPKG_GRANULAR=yes -DPKG_OPT=yes -DBUILD_OMP=yes -DPKG_OPENMP=yes
    make -j $(nproc)
    make install
    if [ -e $INSTALL_DIR/bin/lmp ];
    then
        print_line success LAMMPS    
    else
        print_line failed LAMMPS
        exit
    fi
    mkdir -p $home_dir/module_files/$DIR_STR
    echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "\tloads all dependencies and set the path for lammps"
}
module-whatis \"loads all dependencies and set the path for lammps
Type_CXXFlags:        $Type_CXXFlags
CXXFlags:             $lammps_cxxflags
Type_mpi_CFlags:    $Type_mpi_CFlags
mpi_CFlags:         $mpi_CFlags
Type_mpi_CXXFlags:  $Type_mpi_CXXFlags
mpi_CXXFlags:       $mpi_CXXFlags
Type_mpi_FCFlags:   $Type_mpi_FCFlags
mpi_FCFlags:        $mpi_FCFlags
\"
setenv      LAMMPSROOT       $INSTALL_DIR

" > $home_dir/module_files/$DIR_STR/$lammps_mpi_compiler_version
    module load $DIR_STR/$lammps_mpi_compiler_version
    rm -rf $BUILD_DIR
    unlock "$locked_files"
    } 2>&1 | tee $home_dir/log_files/${DIR_STR}/$lammps_mpi_compiler_version_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

