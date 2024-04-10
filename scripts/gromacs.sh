#!/bin/bash
if [ -z $home_dir ];
then
        source ./env_set.sh
else
        source $home_dir/scripts/env_set.sh
fi
print_line header GROMACS
gromacs_usage()
{
    echo "
    Usage: ./gromacs.sh --gromacs_version=<gromacs_version>\\
                        --gromacs_compiler=<gromacs_compiler>\\
                        --gromacs_compiler_version=<gromacs_compiler_version>\\
                        --gromacs_math=<gromacs_math_lib_vendor>\\
                        --gromacs_math_version=<gromacs_math_version>\\
                        --gromacs_math_compiler=<gromacs_math_compiler>\\
                        --gromacs_math_compiler_version=<gromacs_math_compiler_version>\\
                        --gromacs_mpi=<gromacs_mpi>\\
                        --gromacs_mpi_version=<gromacs_mpi_version>\\
                        --gromacs_mpi_compiler=<gromacs_mpi_compiler>\\
                        --gromacs_mpi_compiler_version=<gromacs_mpi_compiler_version>\\
                        --gromacs_simd=<gromacs_simd>\\
                        --gromacs_mpi_cflags=<gromacs_mpi_cflags>\\
                        --gromacs_mpi_cxxflags=<gromacs_mpi_cxxflags>\\
                        --gromacs_mpi_fcflags=<gromacs_mpi_fcflags>\\
                        --gromacs_cflags=<gromacs_cflags>
   --gromacs_cxxflags=<gromacs_cxxflags>

    Builds the gromacs of specified version with specified compiler specifications, mpi specifications, math library specifications and simd.


    Example: ./gromacs.sh --gromacs_version=2023.1 --gromacs_compiler=aocc --gromacs_compiler_version=4.0.0 --gromacs_math=aocl \\
             --gromacs_math_version=4.0 --gromacs_math_compiler=aocc --gromacs_math_compiler_version=4.0.0 --gromacs_mpi=openmpi \\
             --gromacs_mpi_version=4.1.4 --gromacs_mpi_compiler=aocc --gromacs_mpi_compiler_version=4.0.0 --gromacs_simd=AVX_512

    <gromacs_version>:                  specify the gromacs version

    <gromacs_compiler>:                 specify the name of compiler to build gromacs.The following compilers are available:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <gromacs_compiler_version>:         specify the version of <gromacs_compiler>
                                        for "aocc" as <gromacs_compiler> the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <gromacs_math_lib_vendor>:          specify the math library vendor to build gromacs.The following are the available vendors:
                                        aocl
                                        intel-mkl
                                        intel-oneapi-mkl

    <gromacs_math_version>:             specify the version of <gromacs_math_lib_vendor>
                                        for aocl as <gromacs_math_lib_vendor>, the following are the available versions:
                                            4.0
                                            3.2.0

    <gromacs_math_compiler>:            specify the compiler to build <gromacs_math_lib_vendor>.The following are the available compilers:
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic
                                        NOTE: for intel-mkl or intel-oneapi-mkl, prefer to specify <gromacs_math_compiler> which is
                                            available in spack compilers.

    <gromacs_math_compiler_version>:    specify the version of <gromacs_math_compiler>
                                        for "aocc" as <gromacs_math_compiler> the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <gromacs_mpi>:                      specify the name of mpi to build gromacs.The folllowing are the available mpi:
                                        openmpi
                                        intel-mpi
                                        intel-oneapi-mpi

    <gromacs_mpi_version>:              specify the version of <gromacs_mpi>

    <gromacs_mpi_compiler>:             specify the name of compiler to build <gromacs_mpi>.The following are the availble compilers;
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

    <gromacs_mpi_compiler_version>:     specify the version of <gromacs_mpi_compiler>
                                        for "aocc" as <gromacs_mpi_compiler> the following are the supported versions:
                                            3.2.0
                                            4.0.0

    <gromacs_simd>:                     specify the simd instruction set for gromacs.The following the available simd:
                                        AVX_512
                                        AVX_256

    <gromacs_mpi_cflags> [optional]:    specify the CFLAGS to build mpi.
                                        default CFLAGS for <gromacs_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <gromacs_mpi_cxxflags> [optional]:  specify the CXXFLAGS to build mpi.
                                        default CXXFLAGS for <gromacs_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <gromacs_mpi_fcflags> [optional]:   specify the FCFLAGS to build mpi.
                                        default FCFLAGS for <gromacs_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <gromacs_cflags> [optional] :       specify the flags to build gromacs.
                                        default <gromacs_flags> for <gromacs_compiler>
                                        aocc:   -O3 -march=znver4 -mprefer-vector-width=512 -flto -ffast-math -mllvm -unroll-threshold=8\\
                                                -flv-function-specialization
                                        gcc:    -O3 -Ofast -ffast-math -march=znver4
                                        intel-oneapi-compilers-classic:  -O3 -march=skylake-avx512 -qopt-zmm-usage=high -fp-model fast=2 -no-prec-div

    <gromacs_cxxflags> [optional]:      specify the flags to build gromacs.
                                        default <gromacs_flags> for <gromacs_compiler>
                                        aocc:   -O3 -march=znver4 -mprefer-vector-width=512 -flto -ffast-math -mllvm -unroll-threshold=8\\
                                                -flv-function-specialization
                                        gcc:    -O3 -Ofast -ffast-math -march=znver4
                                        intel-oneapi-compilers-classic:  -O3 -march=skylake-avx512 -qopt-zmm-usage=high -fp-model fast=2 -no-prec-div

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
if [[ -z $gromacs_version ]] || [[ -z $gromacs_compiler ]] || [[ -z $gromacs_compiler_version ]] || [[ -z $gromacs_math ]] \
 || [[ -z $gromacs_math_version ]] || [[ -z $gromacs_math_compiler ]] || [[ -z $gromacs_math_compiler_version ]] || [[ -z $gromacs_simd ]] \
 || [[ -z $gromacs_mpi ]] || [[ -z $gromacs_mpi_version ]] || [[ -z $gromacs_mpi_compiler ]] || [[ -z $gromacs_mpi_compiler_version ]];
then
        gromacs_usage
        exit
fi
manditory_options=12
if [[ $n_arg -gt ${manditory_options} ]];
then
        load_check_flags $[$n_arg-${manditory_options}] gromacs_cflags gromacs_cxxflags gromacs_mpi_cflags gromacs_mpi_fcflags gromacs_mpi_cxxflags
        if [ $? == 0 ];
        then
            echo "Flags specified incorrecly, Exiting... "
            gromacs_usage
            exit
        fi
fi

DIR_STR=gromacs/$gromacs_version/$gromacs_simd/$gromacs_compiler/$gromacs_compiler_version/$gromacs_math/$gromacs_math_version/$gromacs_math_compiler/$gromacs_math_compiler_version/$gromacs_mpi/$gromacs_mpi_version/$gromacs_mpi_compiler

build_check $DIR_STR/$gromacs_mpi_compiler_version CFlags:CXXFlags "$gromacs_cflags:$gromacs_cxxflags"
export rebuilt=$?
if [ $rebuilt == 0 ];
then
        print_line found GROMACS
        module load $DIR_STR/$gromacs_mpi_compiler_version
else
        mkdir -p ${home_dir}/log_files/${DIR_STR}
        {
        print_line not_found GROMACS
        print_line hostname $hostname
        lock_check "$DIR_STR/$gromacs_mpi_compiler_version"
        build_check $DIR_STR/$gromacs_mpi_compiler_version CFlags:CXXFlags "$gromacs_cflags:$gromacs_cxxflags"
        rebuilt=$?
        if [ $rebuilt == 0 ];
        then
                print_line found GROMACS
                module load $DIR_STR/$gromacs_mpi_compiler_version
                exit
        fi
        locked_files=""
        trap 'unlock "$locked_files"' EXIT SIGINT
        lock "$DIR_STR/$gromacs_mpi_compiler_version"
        rm -rf $home_dir/module_files/$DIR_STR/$gromacs_mpi_compiler_version
        # Check if the module is present else build the module
        export gromacs_cur_dir=$PWD
        cd $home_dir/scripts
        bash ${home_dir}/scripts/mathlib.sh --math=$gromacs_math --math_version=$gromacs_math_version --math_compiler=$gromacs_math_compiler --math_compiler_version=$gromacs_math_compiler_version
        cd $gromacs_cur_dir
        module load $gromacs_math/$gromacs_math_version/$gromacs_math_compiler/$gromacs_math_compiler_version
        lock "$gromacs_math/$gromacs_math_version/$gromacs_math_compiler/$gromacs_math_compiler_version"
        case $gromacs_math in
                mkl | intel-mkl | intel-oneapi-mkl)
                        echo " Using mkl"
                        export EXTRA_OPTS="-DGMX_FFT_LIBRARY=MKL $EXTRA_OPTS"
                ;;
                aocl)
                        echo " Using aocl"
                        export FFTWROOT=$MATHLIBROOT
                        export EXTRA_OPTS="-DGMX_FFT_LIBRARY=FFTW3 -DFFTWF_INCLUDE_DIR=$FFTWROOT/include -DFFTWF_LIBRARY=$FFTWROOT/lib/libfftw3f.so.3 -DCMAKE_INCLUDE_PATH=$FFTWROOT/include $EXTRA_OPTS"
                ;;
                *)
                        echo "$gromacs_math option is not included"
                        exit
                ;;
        esac

        export gromacs_cur_dir=$PWD
        cd $home_dir/scripts
        bash ${home_dir}/scripts/mpi.sh --mpi_cflags="$gromacs_mpi_cflags" --mpi_cxxflags="$gromacs_mpi_cxxflags" --mpi_fcflags="$gromacs_mpi_fcflags" --mpi=$gromacs_mpi --mpi_version=$gromacs_mpi_version --mpi_compiler=$gromacs_mpi_compiler --mpi_compiler_version=$gromacs_mpi_compiler_version

        cd $gromacs_cur_dir

        module load $gromacs_mpi/$gromacs_mpi_version/$gromacs_mpi_compiler/$gromacs_mpi_compiler_version
        lock "$gromacs_mpi/$gromacs_mpi_version/$gromacs_mpi_compiler/$gromacs_mpi_compiler_version"

        export gromacs_cur_dir=$PWD
        cd $home_dir/scripts
        bash $home_dir/scripts/compiler.sh --compiler_name=$gromacs_compiler --compiler_version=$gromacs_compiler_version
        cd $gromacs_cur_dir
        module load $gromacs_compiler/$gromacs_compiler_version
        lock "$gromacs_compiler/$gromacs_compiler_version"
        case $gromacs_compiler in
                aocc)
                        echo "Using AOCC compiler"
                        export CC=clang
                        export CXX=clang++
                        if [[ -z $gromacs_cflags ]];
                        then
                            echo "Gromacs_cflags is not defined. Choosing default CFLAGS"
                            export gromacs_cflags="-O3 -march=znver4 -mprefer-vector-width=512 -flto -ffast-math -mllvm -unroll-threshold=8 -flv-function-specialization "
                            export Type_CFlags=default
                        else
                            export Type_CFlags=custom
                        fi
                        if [[ -z $gromacs_cxxflags ]];
                        then
                            echo "Gromacs_cxxflags is not defined. Choosing default CXXFLAGS"
                            export gromacs_cxxflags="-O3 -march=znver4 -mprefer-vector-width=512 -flto -ffast-math -mllvm -unroll-threshold=8 -flv-function-specialization "
                            export Type_CXXFlags=default
                        else
                            export Type_CXXFlags=custom
                        fi
                        export MPFLAG=-fopenmp
                ;;
                gcc)
                        echo "Using GCC compiler"
                        export CC=gcc
                        export CXX=g++
                        if [[ -z $gromacs_cflags ]];
                        then
                            echo "Gromacs_cflags is not defined. Choosing default CFLAGS"
                            export gromacs_cflags="-O3 -Ofast -ffast-math -march=znver4"
                            export Type_CFlags=default
                        else
                            export Type_CFlags=custom
                        fi
                        if [[ -z $gromacs_cxxflags ]];
                        then
                            echo "Gromacs_cxxflags is not defined. Choosing default CXXFLAGS"
                            export gromacs_cxxflags="-O3 -Ofast -ffast-math -march=znver4"
                            export Type_CXXFlags=default
                        else
                            export Type_CXXFlags=custom
                        fi
                        export MPFLAG=-fopenmp
                ;;
                icc | intel-oneapi-compilers-classic | intel-oneapi-compilers)
                        echo "Using ICC compiler"
                        export CC=icc
                        export CXX=icpc
                        if [[ -z $gromacs_cflags ]];
                        then
                            echo "Gromacs_cflags is not defined. Choosing default CFLAGS"
                            export gromacs_cflags="-O3 -march=skylake-avx512 -qopt-zmm-usage=high -fp-model fast=2 -no-prec-div"
                            export Type_CFlags=default
                        else
                            export Type_CFlags=custom
                        fi
                        if [[ -z $gromacs_cxxflags ]];
                        then
                            echo "Gromacs_cxxflags is not defined. Choosing default CXXFLAGS"
                            export gromacs_cxxflags="-O3 -march=skylake-avx512 -qopt-zmm-usage=high -fp-model fast=2 -no-prec-div"
                            export Type_CXXFlags=default
                        else
                            export Type_CXXFlags=custom
                        fi
                        export MPFLAG=-qopenmp
                ;;
        esac
        export source_dir=$home_dir/source_codes/$DIR_STR/$gromacs_mpi_compiler_version
        rm -rf $source_dir
        mkdir -p $source_dir
        cd $source_dir
        wget ftp://ftp.gromacs.org/gromacs/gromacs-${gromacs_version}.tar.gz
        if [ -e $PWD/gromacs-${gromacs_version}.tar.gz ];
        then
                echo "Gromacs source file downloaded successfully"
        else
                echo "Gromacs source file not found. Exiting..."
                exit
        fi
        tar -xf gromacs-${gromacs_version}.tar.gz
        cd gromacs-${gromacs_version}
        export build_dir=$PWD/gromacs_build
        mkdir -p $build_dir
        cd $build_dir
        export install_dir=$home_dir/apps/$DIR_STR/$gromacs_mpi_compiler_version
        mkdir -p $install_dir
        cmake $source_dir/gromacs-${gromacs_version} \
            -DGMX_SIMD="$gromacs_simd" \
            -DOpenMP_C_FLAGS="$MPFLAG" \
            -DOpenMP_CXX_FLAGS="$MPFLAG" \
            -DGMX_OPENMP=on \
            -DGMX_MPI=on \
            -DGMXAPI=OFF \
            -DCMAKE_C_COMPILER=$CC \
            -DCMAKE_CXX_COMPILER=$CXX \
            -DCMAKE_C_FLAGS="$gromacs_cflags" \
            -DCMAKE_CXX_FLAGS="$gromacs_cxxflags" \
            -DCMAKE_INSTALL_PREFIX=$install_dir $EXTRA_OPTS
        make -j $(nproc)
        make install
        if [ -e $install_dir/bin/gmx_mpi ];
        then
                print_line success GROMACS        
        else
                print_line failed GROMACS
                exit
        fi
        mkdir -p $home_dir/module_files/$DIR_STR
        echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
        puts stderr "sets the GROMACSROOT path"
    }
    module-whatis \"sets the GROMACSROOT path
    Type_CFlags:    $Type_CFlags
    CFlags:         $gromacs_cflags
    Type_CXXFlags:  $Type_CXXFlags
    CXXFlags:       $gromacs_cxxflags
    \"
    setenv     GROMACSROOT   $install_dir
    " > $home_dir/module_files/$DIR_STR/$gromacs_mpi_compiler_version
        rm -rf $source_dir
        unlock "$locked_files"
        } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$gromacs_mpi_compiler_version_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

