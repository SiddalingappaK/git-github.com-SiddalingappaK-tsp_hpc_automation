#!/bin/bash
if [ -z $home_dir ];
then
    source ./env_set.sh
else
    source $home_dir/scripts/env_set.sh
fi
print_line header HPL
hpl_usage()
{
    echo "
    Usage: ./hpl.sh --hpl_version=<hpl_version> \\
                    --hpl_compiler=<hpl_compiler> \\
                    --hpl_compiler_version=<hpl_compiler_version> \\
                    --hpl_math=<hpl_math_lib_vendor> \\
                    --hpl_math_version=<hpl_math_version> \\
                    --hpl_math_compiler=<hpl_math_compiler> \\
                    --hpl_math-compiler_version=<hpl_math_compiler_version> \\
                    --hpl_mpi=<hpl_mpi> \\
                    --hpl_mpi_version=<hpl_mpi_version> \\
                    --hpl_mpi_compiler=<hpl_mpi_compiler> \\
                    --hpl_mpi_compiler_version=<hpl_mpi_compiler_version> \\
                    --hpl_mpi_cflags=<hpl_mpi_cflags> \\
                    --hpl_mpi_cxxflags=<hpl_mpi_cxxflags> \\
                    --hpl_mpi_fcflags=<hpl_mpi_fcflags> \\
                    --hpl_cflags=<hpl_cflags>
    Builds the HPL benchmark of specified version with specified compiler specifications, mpi specifications and math library specification.

    Example: ./hpl.sh --hpl_version=2.3 --hpl_compiler=aocc --hpl_compiler_version=4.0.0 --hpl_math=aocl --hpl_math_version=4.0 \\
             --hpl_math_compiler=aocc --hpl_math_compiler_version=4.0.0 --hpl_mpi=openmpi --hpl_mpi_version=4.1.4 \\
             --hpl_mpi_compiler=aocc --hpl_mpi_compiler_version=4.0.0

    <hpl_version>:                  specify the version to build hpl

    <hpl_compiler>:                 specify the name of compiler to build hpl.The following the the availbale compilers:
                                    aocc
                                    gcc
                                    intel-oneapi-compilers-classic

    <hpl_compiler_version>:         specify the vesrion of <hpl_compiler>
                                    for "aocc" as <hpl_compiler> the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <hpl_math_lib_vendor>:          specify the math library vendor to build hpl.The follwoing are available math libarary vendors:
                                    aocl
                                    intel-mkl
                                    intel-oneapi-mkl

    <hpl_math_version>:             specify the version of <hpl_math_lib_vendor>
                                    for aocl as <math_lib_vendor>, the following are the available versions:
                                        4.0
                                        3.2.0


    <hpl_math_compiler>:            specify the compiler to build <hpl_math_lib_vendor>.The following are the available compilers:
                                    aocc
                                    gcc
                                    intel-oneapi-compilers-classic

    <hpl_math_compiler_version>:    specify the version of <hpl_math_compiler>
                                    for "aocc" as <hpl_math_compiler> the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <hpl_mpi>:                      specify the mpi to build hpl.
                                    **NOTE: For intel-mpi and intel-oneapi-mpi no flags are required as it will be build with spack.
                                    The following are the available mpi:
                                    openmpi
                                    intel-mpi
                                    intel-oneapi-mpi

    <hpl_mpi_version>:              specify the version of <hpl_mpi>

    <hpl_mpi_compiler>:             specify the compiler to build <hpl_mpi>.
                                    **NOTE: For the two <hpl_mpi>s intel-mpi and intel-oneapi-mpi, <hpl_mpi_compiler> will be used
                                            as 'wrapper compiler' and not to be used to build <hpl_mpi> through spack.
                                    The following are the available compilers:
                                    aocc
                                    gcc
                                    intel-oneapi-compilers-classic

    <hpl_mpi_compiler_version>:     specify the version of <hpl_mpi_compiler>
                                    for "aocc" as <compiler> the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <hpl_mpi_cflags> [optional]:    specify the CFLAGS to build <hpl_mpi>
                                    default CFLAGS for <hpl_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <hpl_mpi_cxxflags> [optional]   specify the CXXFLAGS to build <hpl_mpi>
                                    default CXXFLAGS for <hpl_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <hpl_mpi_fcflags> [optional]:   specify the FCFLAGS to build <hpl_mpi>
                                    default FCFLAGS for <hpl_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <hpl_cflags> [optional]:        specify the CFLAGS to build hpl
                                    default CFLAGS for <hpl_compiler>
                                        aocc:             '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        gcc:              '-O3 -funroll-loops -march=znver4 -fopenmp'
                                        intel-oneapi-compilers-classic: '-O3 -funroll-loops -march=skylake-avx512 -qopenmp'

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
if [[ -z $hpl_version ]] || [[ -z $hpl_compiler ]] || [[ -z $hpl_compiler_version ]] || [[ -z $hpl_math ]] || [[ -z $hpl_math_version ]] || [[ -z $hpl_math_compiler ]] || [[ -z $hpl_math_compiler_version ]] || [[ -z $hpl_mpi ]] || [[ -z $hpl_mpi_version ]] || [[ -z $hpl_mpi_compiler ]] || [[ -z $hpl_mpi_compiler_version ]] ;
then
    hpl_usage
    exit
fi
manditory_options=11
if [[ $n_arg -gt ${manditory_options} ]];
then
    load_check_flags $[$n_arg-${manditory_options}] hpl_mpi_cflags hpl_mpi_cxxflags hpl_mpi_fcflags hpl_cflags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        hpl_usage
        exit
    fi
fi
DIR_STR=hpl/${hpl_version}/${hpl_compiler}/${hpl_compiler_version}/${hpl_math}/${hpl_math_version}/${hpl_math_compiler}/${hpl_math_compiler_version}/${hpl_mpi}/${hpl_mpi_version}/${hpl_mpi_compiler}
date=$(date | perl -pe 's/\s+/_/g;s/_$//;s/://g')
build_check $DIR_STR/$hpl_mpi_compiler_version CFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$hpl_cflags:$hpl_mpi_cflags:$hpl_mpi_cxxflags:$hpl_mpi_fcflags"
export rebuilt=$?
if [ $rebuilt == 0 ];
then
    print_line found HPL
    module load ${DIR_STR}/${hpl_mpi_compiler_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    print_line not_found HPL
    print_line hostname $hostname
    lock_check "${DIR_STR}/${hpl_mpi_compiler_version}"
    build_check $DIR_STR/$hpl_mpi_compiler_version CFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$hpl_cflags:$hpl_mpi_cflags:$hpl_mpi_cxxflags:$hpl_mpi_fcflags"
    rebuilt=$?
    if [ $rebuilt == 0 ];
    then
        print_line found HPL
        module load ${DIR_STR}/${hpl_mpi_compiler_version}
        exit
    fi
    locked_files=""
    trap 'unlock "$locked_files"' EXIT SIGINT
    lock "${DIR_STR}/${hpl_mpi_compiler_version}"
    rm -rf $home_dir/module_files/${DIR_STR}/${hpl_mpi_compiler_version}
    # Check if the compiler is present else build the module
    hpl_cur_dir=$PWD
    cd $home_dir/scripts
    bash $home_dir/scripts/compiler.sh --compiler_name=$hpl_compiler --compiler_version=$hpl_compiler_version
    cd $hpl_cur_dir
    module load $hpl_compiler/$hpl_compiler_version
    lock "$hpl_compiler/$hpl_compiler_version"
    case $hpl_compiler in
    aocc)
        echo "using AOCC compiler"
        export CC=clang
        if [[ -z $hpl_cflags ]];
        then
            export hpl_cflags="-O3 -funroll-loops -march=znver4 -fopenmp"
            export Type_CFlags=default
        else
            export Type_CFlags=custom
        fi
        export archiver=llvm-ar
        export arflags=r
        export ranlib=llvm-ranlib
        unset ARCH
    ;;

    gcc)
        echo "using GCC compiler"
        export CC=gcc
        if [[ -z $hpl_cflags ]];
        then
            export hpl_cflags="-O3 -funroll-loops -march=znver4 -fopenmp"
            export Type_CFlags=default
        else
            export Type_CFlags=custom
        fi
        export archiver=ar
        export arflags=r
        export ranlib=gcc-ranlib
        unset ARCH
        ;;
    intel-oneapi-compilers-classic)
        echo "using ICC compiler"
        export CC=icc
        if [[ -z $hpl_cflags ]];
        then
            export hpl_cflags="-O3 -funroll-loops -march=skylake-avx512 -qopenmp"
            export Type_CFlags=default
        else
            export Type_CFlags=custom
        fi
        export archiver=ar
        export arflags=r
        export ranlib=echo
        unset ARCH
    ;;
    esac
    hpl_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/mathlib.sh --math=$hpl_math --math_version=$hpl_math_version --math_compiler=$hpl_math_compiler --math_compiler_version=$hpl_math_compiler_version
    cd $hpl_cur_dir
    module load $hpl_math/$hpl_math_version/$hpl_math_compiler/$hpl_math_compiler_version
    lock "$hpl_math/$hpl_math_version/$hpl_math_compiler/$hpl_math_compiler_version"
    case $hpl_math in
        intel-mkl | intel-oneapi-mkl)
            echo " using mkl"
            export laDir=$MATHLIBROOT
            export laInc="-I\$(LAdir)/include"
            if [ $hpl_compiler == "gcc" ];
            then
                export laLib="-L \$(LAdir)/lib/intel64 -Wl,--start-group \$(LAdir)/lib/intel64/libmkl_gf_lp64.a \$(LAdir)/lib/intel64/libmkl_gnu_thread.a \$(LAdir)/lib/intel64/libmkl_core.a -Wl,--end-group -lpthread -ldl -lm"
            else
                export laLib="-L \$(LAdir)/lib/intel64 -Wl,--start-group \$(LAdir)/lib/intel64/libmkl_intel_lp64.a \$(LAdir)/lib/intel64/libmkl_intel_thread.a \$(LAdir)/lib/intel64/libmkl_core.a -Wl,--end-group -lpthread -ldl -lm"
            fi
            unset F2CDEFS
            unset lm
        ;;
        aocl)
            echo " using aocl"
            export laDir=$MATHLIBROOT
            export laInc="-I\$(LAdir)/include"
            export laLib="\$(LAdir)/lib/libblis-mt.so"
            export F2CDEFS="-Dadd__ -DF77_INTEGER=int -DStringSunStyle"
            export lm="-lm"
        ;;
        blis)
            echo "using blis "
            export laDir=$MATHLIBROOT
            export laInc="-I\$(LAdir)/include"
            export laLib="\$(LAdir)/lib/libblis.a"
            export F2CDEFS="-Dadd__ -DF77_INTEGER=int -DStringSunStyle"
            export lm="-lm"
        ;;
    esac

    hpl_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/mpi.sh --mpi_cflags=$hpl_mpi_cflags -mpi_cxxflags=$hpl_mpi_cxxflags -mpi_fcflags=$hpl_mpi_fcflags \
    --mpi=$hpl_mpi --mpi_version=$hpl_mpi_version --mpi_compiler=$hpl_mpi_compiler --mpi_compiler_version=$hpl_mpi_compiler_version
    cd $hpl_cur_dir

    module load $hpl_mpi/$hpl_mpi_version/$hpl_mpi_compiler/$hpl_mpi_compiler_version
    lock "$hpl_mpi/$hpl_mpi_version/$hpl_mpi_compiler/$hpl_mpi_compiler_version"
    unset GCCROOT # because it will conflict for icc compiler
    mpi_mf=$home_dir/module_files/$hpl_mpi/$hpl_mpi_version/$hpl_mpi_compiler/$hpl_mpi_compiler_version
    Type_mpi_CFlags=$(cat $mpi_mf| grep "^ *Type_CFlags" | cut -d ":" -f 2)
    Type_mpi_CXXFlags=$(cat $mpi_mf | grep "^ *Type_CXXFlags" | cut -d ":" -f 2)
    Type_mpi_FCFlags=$(cat $mpi_mf | grep "^ *Type_FCFlags" | cut -d ":" -f 2)
    mpi_CFlags=$(cat $mpi_mf | grep "^ *CFlags" | cut -d ":" -f 2)
    mpi_CXXFlags=$(cat $mpi_mf | grep "^ *CXXFlags" | cut -d ":" -f 2)
    mpi_FCFlags=$(cat $mpi_mf | grep "^ *FCFlags" | cut -d ":" -f 2)
    if [ $hpl_mpi == "intel-mpi" ] || [ $hpl_mpi == "intel-oneapi-mpi" ];
    then
        export mplib=\$\(MPdir\)/lib/release_mt/libmpi.so
    elif [ $hpl_mpi == "openmpi" ];
    then
        export mplib=\$\(MPdir\)/lib/libmpi.so
    fi
    export HPL_SOURCE=${home_dir}/source_codes/hpl
    export HPL_BUILD=${home_dir}/apps/$DIR_STR/$hpl_mpi_compiler_version

    mkdir -p $HPL_SOURCE
    mkdir -p $HPL_BUILD
    cd $HPL_SOURCE
    rm -rf $HPL_SOURCE/*
    rm -rf $HPL_BUILD/*
    wget https://www.netlib.org/benchmark/hpl/hpl-$hpl_version.tar.gz
    tar -xf hpl-$hpl_version.tar.gz -C $HPL_BUILD

    cd $HPL_BUILD/hpl-$hpl_version

    echo "compiler used to build $CC"

    echo "########################################################################
    SHELL        = /bin/sh
    CD           = cd
    CP           = cp
    LN_S         = ln -s
    MKDIR        = mkdir
    RM           = /bin/rm -f
    TOUCH        = touch
    ARCH         = \$(arch)
    TOPdir       = ../../..
    INCdir       = \$(TOPdir)/include
    BINdir       = \$(TOPdir)/bin/\$(ARCH)
    LIBdir       = \$(TOPdir)/lib/\$(ARCH)
    HPLlib       = \$(LIBdir)/libhpl.a
    MPdir        = ${MPIROOT}
    MPinc        = -I\$(MPdir)/include
    MPlib        = $mplib
    LAdir        = $laDir
    LAinc        = $laInc
    LAlib        = $laLib
    F2CDEFS      = $F2CDEFS
    HPL_INCLUDES = -I\$(INCdir) -I\$(INCdir)/\$(ARCH) \$(LAinc) \$(MPinc)
    HPL_LIBS     = \$(HPLlib) \$(LAlib) \$(MPlib) $lm
    HPL_OPTS     = -DHPL_PROGRESS_REPORT
    HPL_DEFS     = \$(F2CDEFS) \$(HPL_OPTS) \$(HPL_INCLUDES)
    CC           = ${CC}
    CCNOOPT      = \$(HPL_DEFS)
    CCFLAGS      = \$(HPL_DEFS) -fomit-frame-pointer $hpl_cflags
    LINKER       = \$(CC)
    LINKFLAGS    = -L\$(CCFLAGS)
    ARCHIVER     = $archiver
    ARFLAGS      = $arflags
    RANLIB       = $ranlib
    " > Make.zen
     make arch=zen

    if [ -e $HPL_BUILD/hpl-$hpl_version/bin/zen/xhpl ]
    then
       print_line success HPL
       mkdir -p ${home_dir}/module_files/$DIR_STR
        echo "#%Module1.0#####################################################################
        proc ModulesHelp { } {
            puts stderr "\tsets the HPLROOT path"
        }
        module-whatis \"sets the HPLROOT path
        Type_CFlags:        $Type_CFlags
        CFlags:             $hpl_cflags
        Type_mpi_CFlags:    $Type_mpi_CFlags
        mpi_CFlags:         $mpi_CFlags
        Type_mpi_CXXFlags:  $Type_mpi_CXXFlags
        mpi_CXXFlags:       $mpi_CXXFlags
        Type_mpi_FCFlags:   $Type_mpi_FCFlags
        mpi_FCFlags:        $mpi_FCFlags
        \"
        setenv     HPLROOT   $HPL_BUILD/hpl-$hpl_version
        " > ${home_dir}/module_files/$DIR_STR/$hpl_mpi_compiler_version
        module load $DIR_STR/$hpl_mpi_compiler_version
    else
        print_line failed HPL
        cd ${home_dir}
        exit
    fi
    unlock "$locked_files"
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$hpl_mpi_compiler_version_${date}.log
fi

