#!/bin/bash
if [ -z $home_dir ];
then
    source ./env_set.sh
else
    source $home_dir/scripts/env_set.sh
fi
print_line header HPCG
hpcg_usage(){
    echo "
    Usage: ./hpcg.sh --hpcg_version=<hpcg_version>\\
                     --hpcg_compiler=<hpcg_compiler>\\
                     --hpcg_compiler_version=<hpcg_compiler_version>\\
                     --hpcg_mpi=<hpcg_mpi>\\
                     --hpcg_mpi_version=<hpcg_mpi_version>\\
                     --hpcg_mpi_compiler=<hpcg_mpi_compiler>\\
                     --hpcg_mpi_compiler_version=<hpcg_mpi_compiler_version>\\
                     --hpcg_mpi_cflags=<hpcg_mpi_cflags> \\
                     --hpcg_mpi_cxxflags=<hpcg_mpi_cxxflags> \\
                     --hpcg_mpi_fcflags=<hpcg_mpi_fcflags> \\
                     --hpcg_cxxflags=<hpcg_flags>

    Example: ./hpcg.sh --hpcg_version=3.1 --hpcg_compiler=aocc --hpcg_compiler_version=4.0.0 --hpcg_mpi=openmpi --hpcg_mpi_version=4.1.4 --hpcg_mpi_compiler=aocc \\
             --hpcg_mpi_compiler_version=4.0.0

    <hpcg_version> :                 Specify the version of hpcg

    <hpcg_compiler>:                 specify the name of compiler to build hpcg.The following the the availbale compilers:
                                     aocc
                                     gcc
                                     intel-oneapi-compilers-classic

    <hpcg_compiler_version>:         specify the vesrion of <hpcg_compiler>
                                     for "aocc" as <hpcg_compiler> the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <hpcg_mpi> :                     Specify the mpi to build hpcg
                                     **NOTE: For intel-mpi and intel-oneapi-mpi no flags are required as it will be build with spack.
                                     The following are the available mpi options :
                                     openmpi
                                     intel-mpi
                                     intel-oneapi-mpi

    <hpcg_mpi_version> :             Specify the version to build <hpcg_mpi>

    <hpcg_mpi_compiler> :            Specify the compiler to build <hpcg_mpi>
                                     **NOTE: For the two <hpcg_mpi>s intel-mpi and intel-oneapi-mpi,
                                      <hpcg_mpi_compiler> will be used as 'wrapper compiler' and not to be used to build <hpcg_mpi> through spack.
                                     The following are the available compiler names :
                                     aocc
                                     gcc
                                     intel-oneapi-compilers-classic

    <hpcg_mpi_compiler_version>  :   Specify the version to build <hpcg_mpi_compiler>
                                     for <openfoam_mpi_compiler> as "aocc" the following are the supported versions:
                                     3.2.0
                                     4.0.0

    <hpcg_mpi_cflags> [optional]:    specify the CFLAGS to build <hpcg_mpi>
                                     default CFLAGS for <hpcg_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <hpcg_mpi_cxxflags> [optional]   specify the CXXFLAGS to build <hpcg_mpi>
                                     default CXXFLAGS for <_hpcg_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <hpcg_mpi_fcflags> [optional]:   specify the FCFLAGS to build <hpcg_mpi>
                                     default FCFLAGS for <hpcg_mpi_compiler>
                                        aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                                        intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


    <hpcg_cxxflags> [Optional] :     specify the CXXFLAGS to build hpcg
                                     default CXXFLAGS for <hpcg_compiler>
                                     aocc:                           '-O3 -funroll-loops -march=znver4 -fopenmp -fPIC -ffast-math'
                                     gcc:                            '-O3 -funroll-loops -march=znver4 -fopenmp -fPIC -ffast-math'
                                     intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC -no-prec-div'


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
if [[ -z ${hpcg_version} ]] || [[ -z ${hpcg_compiler} ]] || [[ -z ${hpcg_compiler_version} ]] || [[ -z ${hpcg_mpi} ]] || [[ -z ${hpcg_mpi_version} ]] || [[ -z ${hpcg_mpi_compiler} ]] || [[ -z ${hpcg_mpi_compiler_version} ]] ;
then
    hpcg_usage
    exit
fi
manditory_options=7
if [[ $n_arg -gt ${manditory_options} ]];
then
    load_check_flags $[$n_arg-${manditory_options}] hpcg_mpi_cflags hpcg_mpi_cxxflags hpcg_mpi_fcflags hpcg_cxxflags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        hpcg_usage
        exit
    fi
fi

DIR_STR=hpcg/${hpcg_version}/${hpcg_compiler}/${hpcg_compiler_version}/${hpcg_mpi}/${hpcg_mpi_version}/${hpcg_mpi_compiler}
build_check $DIR_STR/$hpcg_mpi_compiler_version HPCGFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$hpcg_flags:$hpcg_mpi_cflags:$hpcg_mpi_cxxflags:$hpcg_mpi_fcflags"
export rebuilt=$?
if [[ $rebuilt == 0 ]];
then
    print_line found HPCG
    module load ${DIR_STR}/${hpcg_mpi_compiler_version}
else
    # lock ${DIR_STR}/${hpcg_mpi_compiler_version}
    export build_log=$home_dir/log_files/$DIR_STR
    mkdir -p ${build_log}
    {
    print_line not_found HPCG
    print_line hostname $hostname
    lock_check "${DIR_STR}/${hpcg_mpi_compiler_version}"
    build_check $DIR_STR/$hpcg_mpi_compiler_version HPCGFlags:mpi_CFlags:mpi_CXXFlags:mpi_FCFlags "$hpcg_flags:$hpcg_mpi_cflags:$hpcg_mpi_cxxflags:$hpcg_mpi_fcflags"   
    rebuilt=$?
    if [[ $rebuilt == 0 ]];
    then
        print_line found HPCG
        module load ${DIR_STR}/${hpcg_mpi_compiler_version}
        exit
    fi
    locked_files=""
    trap 'unlock "$locked_files"' EXIT SIGINT
    lock "${DIR_STR}/${hpcg_mpi_compiler_version}"
    rm -rf $home_dir/module_files/${DIR_STR}/${hpcg_mpi_compiler_version}
    hpcg_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/mpi.sh --mpi_cflags=$hpcg_mpi_cflags -mpi_cxxflags=$hpcg_mpi_cxxflags -mpi_fcflags=$hpcg_mpi_fcflags \
    --mpi=$hpcg_mpi --mpi_version=$hpcg_mpi_version --mpi_compiler=$hpcg_mpi_compiler --mpi_compiler_version=$hpcg_mpi_compiler_version
    cd $hpcg_cur_dir

    module load $hpcg_mpi/$hpcg_mpi_version/$hpcg_mpi_compiler/$hpcg_mpi_compiler_version
    lock "$hpcg_mpi/$hpcg_mpi_version/$hpcg_mpi_compiler/$hpcg_mpi_compiler_version"
    mpi_mf=$home_dir/module_files/$hpcg_mpi/$hpcg_mpi_version/$hpcg_mpi_compiler/$hpcg_mpi_compiler_version
    Type_mpi_CFlags=$(cat $mpi_mf| grep "^ *Type_CFlags" | cut -d ":" -f 2)
    Type_mpi_CXXFlags=$(cat $mpi_mf | grep "^ *Type_CXXFlags" | cut -d ":" -f 2)
    Type_mpi_FCFlags=$(cat $mpi_mf | grep "^ *Type_FCFlags" | cut -d ":" -f 2)
    mpi_CFlags=$(cat $mpi_mf | grep "^ *CFlags" | cut -d ":" -f 2)
    mpi_CXXFlags=$(cat $mpi_mf | grep "^ *CXXFlags" | cut -d ":" -f 2)
    mpi_FCFlags=$(cat $mpi_mf | grep "^ *FCFlags" | cut -d ":" -f 2)
    if [ $hpcg_mpi == "intel-mpi" ] || [ $hpcg_mpi == "intel-oneapi-mpi" ];
    then
        export mplib="\$\(MPdir\)/lib/release -lmpi"
    elif [ $hpcg_mpi == "openmpi" ];
    then
        export mplib="\$\(MPdir\)/lib -lmpi"
    fi

    hpcg_cur_dir=$PWD
    cd $home_dir/scripts
    bash ${home_dir}/scripts/compiler.sh --compiler_name=$hpcg_compiler --compiler_version=$hpcg_compiler_version
    cd $hpcg_cur_dir
    module load $hpcg_compiler/$hpcg_compiler_version
    lock "$hpcg_compiler/$hpcg_compiler_version"
    case $hpcg_compiler in
        aocc)
            echo "using AOCC compiler"
            export CXX=clang++
            if [[ -z $hpcg_cxxflags ]];
            then
                export hpcg_cxxflags="-fomit-frame-pointer -O3 -fopenmp -march=znver4 -ffast-math -funroll-loops"
                export Type_CXXFlags=default
            else
                export Type_CXXFlags=custom
            fi
         ;;

        gcc)
            echo "using GCC compiler"
            export CXX=g++
            if [[ -z $hpcg_cxxflags ]];
            then
                export hpcg_cxxflags="-fomit-frame-pointer -O3 -fopenmp -march=znver4 -ffast-math -funroll-loops"
                export Type_CXXFlags=default
            else
                export Type_CXXFlags=custom
            fi

        ;;
        intel-oneapi-compilers-classic)
            echo "using ICC compiler"
            export CXX=icpc
            if [[ -z $hpcg_cxxflags ]];
            then
                export hpcg_cxxflags="-fomit-frame-pointer -O3 -qopenmp -march=skylake-avx512 -ffast-math -funroll-loops"
                export Type_CXXFlags=default
            else
                export Type_CXXFlags=custom
            fi
        ;;
    esac

    mkdir -p ${home_dir}/apps/${DIR_STR}/${hpcg_mpi_compiler_version}
    mkdir -p ${home_dir}/source_codes/${DIR_STR}/${hpcg_mpi_compiler_version}
    cd ${home_dir}/source_codes/${DIR_STR}/${hpcg_mpi_compiler_version}
    git clone https://github.com/hpcg-benchmark/hpcg.git
    cd hpcg
    case ${hpcg_version} in
        3.1)
            echo ""
        ;;         3.0)
            git checkout HPCG-release-3-0-branch
        ;;
        *)
            echo "Invalid --hpcg_version    Choose --hpcg_version as ( 3.0 or 3.1 )"
            unlock ${DIR_STR}/${hpcg_mpi_compiler_version};exit
        ;;
    esac
    export MAKE_FILE=$PWD/setup/Make.MPI_${hpcg_compiler}_OMP
    if [[ -f $MAKE_FILE ]];
    then
        echo "Make file is exist editing same file"
    else
        echo "Make file does not exist copying Make.MPI_GCC_OMP to Make.MPI_${hpcg_compiler}_OMP"
        cp $PWD/setup/Make.MPI_GCC_OMP $PWD/setup/Make.MPI_${hpcg_compiler}_OMP
    fi
    sed -i "s#MPdir *=.*#MPdir        = $MPIROOT#" $MAKE_FILE
    sed -i 's#MPinc *=.*#MPinc        = -I$(MPdir)/include#' $MAKE_FILE
    sed -i "s#MPlib *=.*#MPlib        = ${mplib}#" $MAKE_FILE
    sed -i 's#HPCG_LIBS *=.*#HPCG_LIBS        = -L$(MPlib)#' $MAKE_FILE
    sed -i 's#HPCG_DEFS *=.*#HPCG_DEFS        = $(HPCG_OPTS) $(HPCG_INCLUDES) $(HPCG_LIBS) #' $MAKE_FILE
    sed -i "s#CXX *=.*#CXX        = ${CXX}#" $MAKE_FILE
    sed -i "s#CXXFLAGS *=.*#CXXFLAGS        = \$(HPCG_DEFS) ${hpcg_cxxflags}#" $MAKE_FILE

    cd ${home_dir}/apps/${DIR_STR}/${hpcg_mpi_compiler_version}
    ${home_dir}/source_codes/${DIR_STR}/${hpcg_mpi_compiler_version}/hpcg/configure MPI_${hpcg_compiler}_OMP
    make -j $(nproc)
    mkdir -p ${home_dir}/module_files/${DIR_STR}
    if [ -e ./bin/xhpcg ];
    then
        rm -rf ${home_dir}/source_codes/${DIR_STR}/${hpcg_mpi_compiler_version}
        print_line success HPCG
        echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "\tsets the HPCGROOT path"
}
module-whatis \"sets the HPCGROOT path
        Type_CXXFlags:     $Type_CXXFlags
        CXXFlags:          $hpcg_cxxflags
        Type_mpi_CFlags:    $Type_mpi_CFlags
        mpi_CFlags:         $mpi_CFlags
        Type_mpi_CXXFlags:  $Type_mpi_CXXFlags
        mpi_CXXFlags:       $mpi_CXXFlags
        Type_mpi_FCFlags:   $Type_mpi_FCFlags
        mpi_FCFlags:        $mpi_FCFlags
\"
setenv     HPCGROOT   ${home_dir}/apps/${DIR_STR}/$hpcg_mpi_compiler_version
" > ${home_dir}/module_files/${DIR_STR}/$hpcg_mpi_compiler_version
        module load $DIR_STR/$hpcg_mpi_compiler_version
    else
        print_line failed HPCG
        cd ${home_dir}
        exit
    fi
    rm -rf ${home_dir}/source_codes/${DIR_STR}/${hpcg_mpi_compiler_version}
    unlock "$locked_files"
    } 2>&1 | tee ${build_log}/$hpcg_mpi_compiler_version__$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

