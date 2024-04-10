#!/bin/bash
if [ -z $home_dir ];
then
        source ./env_set.sh
else
        source $home_dir/scripts/env_set.sh
fi
print_line header MPI
mpi_usage()
{
    echo "
    Usage: ./mpi.sh --mpi=<mpi> \\
                    --mpi_version=<mpi_version> \\
                    --mpi_compiler=<mpi_compiler> \\
                    --mpi_compiler_version=<mpi_compiler_version> \\
                    --mpi_cflags=<mpi_flags> \\
                    --mpi_cxxflags=<mpi_cxxflags> \\
                    --mpi_fcflags=<mpi_fcflags>
    Builds the mpi with specified version and specified compiler specifications.

    Example: ./mpi.sh --mpi=openmpi --mpi_version=4.1.4 --mpi_compiler=aocc --mpi_compiler_version=4.0.0

    <mpi>:                    specify the name of mpi to build.
                              **NOTE: For intel-mpi and intel-oneapi-mpi no flags are required as it will be build with spack.
                              The following are the available mpi:
                              openmpi
                              intel-mpi
                              intel-oneapi-mpi

    <mpi_version>:            specify the version of the <mpi>

    <mpi_compiler>:           specify the name of compiler to build <mpi>.
                              **NOTE: For the two <mpi>s intel-mpi and intel-oneapi-mpi,
                                      <mpi_compiler> will be used as 'wrapper compiler' and not to be used to build <mpi> through spack.
                              The following are the available compilers:
                              aocc
                              gcc
                              intel-oneapi-compilers-classic

    <mpi_compiler_version>:   specify the version of <mpi_compiler> to build <mpi>

    <mpi_cflags> [optional]:  specify the CFLAGS to build mpi.
                              default CFLAGS for <mpi_compiler>
                              aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                              gcc:                            ' -ffast-math'
                              intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <mpi_cxxflags> [optional]:specify the CXXFLAGS to build mpi.
                              default CXXFLAGS for <mpi_compiler>
                              aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                              gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                              intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'

    <mpi_fcflags> [optional]: specify the FCFLAGS to build mpi.
                              default FCFLAGS for <mpi_compiler>
                              aocc:                           '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                              gcc:                            '-O3 -march=znver4 -fopenmp -fPIC -ffast-math'
                              intel-oneapi-compilers-classic: '-O3 -march=core-avx512 -qopenmp -fPIC'


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
if [[ -z $mpi ]] || [[ -z $mpi_version ]] || [[ -z $mpi_compiler ]] || [[ -z $mpi_compiler_version ]] ;
then
        mpi_usage
        exit
fi

if [[ $mpi == "openmpi" ]];
then
        manditory_options=4
        if [[ $n_arg -gt ${manditory_options} ]];
        then
            load_check_flags $[$n_arg-${manditory_options}] mpi_cflags mpi_cxxflags mpi_fcflags
            if [ $? == 0 ];
            then
                echo "Flags specified incorrecly, Exiting... "
                mpi_usage
                exit
            fi
        fi
elif [[ $mpi == intel-oneapi-mpi ]] || [[ $mpi == intel-mpi ]];
then
        unset mpi_cflags
        unset mpi_cxxflags
        unset mpi_fcflags
fi
DIR_STR=$mpi/$mpi_version/$mpi_compiler/$mpi_compiler_version
build_check $DIR_STR CFlags:CXXFlags:FCFlags "$mpi_cflags:$mpi_cxxflags:$mpi_fcflags"
export rebuilt=$?
if [ $rebuilt == 0 ];
then
        print_line found MPI
        module load $DIR_STR
else
        mkdir -p $home_dir/log_files/$mpi/$mpi_version/$mpi_compiler
        {
        print_line not_found MPI
        print_line hostname $hostname
        lock_check "$DIR_STR"
        build_check $DIR_STR CFlags:CXXFlags:FCFlags "$mpi_cflags:$mpi_cxxflags:$mpi_fcflags"
        rebuilt=$?
        if [ $rebuilt == 0 ];
        then
            print_line found MPI
            module load $DIR_STR
            exit
        fi
        locked_files=""
        trap 'unlock "$locked_files"' EXIT SIGINT
        lock "$DIR_STR"
        rm -rf $home_dir/apps/$DIR_STR $home_dir/module_files/$DIR_STR 
        if [ $mpi == "openmpi" ];
        then
                echo "Calling compiler script..."
                openmpi_cur_dir=$PWD
                cd $home_dir/scripts
                bash ${home_dir}/scripts/compiler.sh --compiler_name=$mpi_compiler --compiler_version=$mpi_compiler_version
                cd $openmpi_cur_dir
                module load $mpi_compiler/$mpi_compiler_version
                lock "$mpi_compiler/$mpi_compiler_version"
                export comp_path=$(ml show ${mpi_compiler}/${mpi_compiler_version} | awk '{ if ( $2 == "PATH" ) print $0 }')
                if [ $mpi_compiler == "aocc" ];
                then
                        export CC=clang
                        export CXX=clang++
                        export FC=flang
                        if [[ -z $mpi_cflags ]];
                        then
                                echo "mpi_cflags is not defined. Choosing default CFLAGS"
                                export mpi_cflags="-O3 -march=znver4 -fopenmp -fPIC -ffast-math"
                                export Type_CFlags=default
                        else
                                export Type_CFlags=custom
                        fi
                        if [[ -z $mpi_cxxflags ]];
                        then
                                echo "mpi_cxxflags is not defined. Choosing default CXXFLAGS"
                                export mpi_cxxflags="-O3 -march=znver4 -fopenmp -fPIC -ffast-math"
                                export Type_CXXFlags=default
                        else
                                export Type_CXXFlags=custom
                        fi
                        if [[ -z $mpi_fcflags ]];
                        then
                                echo "mpi_fcflags is not defined. Choosing default FCFLAGS"
                                export mpi_fcflags="-O3 -march=znver4 -fopenmp -fPIC -ffast-math"
                                export Type_FCFlags=default
                        else
                                export Type_FCFlags=custom
                        fi
                elif [ $mpi_compiler == "gcc" ];
                then
                        export CC=gcc
                        export CXX=g++
                        export FC=gfortran
                        if [[ -z $mpi_cflags ]];
                        then
                                echo "mpi_cflags is not defined. Choosing default CFLAGS"
                                export mpi_cflags="-O3 -march=znver4 -fopenmp -fPIC -ffast-math"
                                export Type_CFlags=default
                        else
                                export Type_CFlags=custom
                        fi
                        if [[ -z $mpi_cxxflags ]];
                        then
                                echo "mpi_cxxflags is not defined. Choosing default CXXFLAGS"
                                export mpi_cxxflags="-O3 -march=znver4 -fopenmp -fPIC -ffast-math"
                                export Type_CXXFlags=default
                        else
                                export Type_CXXFlags=custom
                        fi
                        if [[ -z $mpi_fcflags ]];
                        then
                                echo "mpi_fcflags is not defined. Choosing default FCFLAGS"
                                export mpi_fcflags="-O3 -march=znver4 -fopenmp -fPIC -ffast-math"
                                export Type_FCFlags=default
                        else
                                export Type_FCFlags=custom
                        fi
                elif [ $mpi_compiler == "intel-oneapi-compilers-classic" ];
                then
                        export CC=icc
                        export CXX=icpc
                        export FC=ifort
                        if [[ -z $mpi_cflags ]];
                        then
                                echo "mpi_cflags is not defined. Choosing default CFLAGS"
                                export mpi_cflags="-O3 -march=core-avx512 -qopenmp -fPIC"
                                export Type_CFlags=default
                        else
                                export Type_CFlags=custom
                        fi
                        if [[ -z $mpi_cxxflags ]];
                        then
                                echo "mpi_cxxflags is not defined. Choosing default CXXFLAGS"
                                export mpi_cxxflags="-O3 -march=core-avx512 -qopenmp -fPIC"
                                export Type_CXXFlags=default
                        else
                                export Type_CXXFlags=custom
                        fi
                        if [[ -z $mpi_fcflags ]];
                        then
                                echo "mpi_fcflags is not defined. Choosing default FCFLAGS"
                                export mpi_fcflags="-O3 -march=core-avx512 -qopenmp -fPIC"
                                export Type_FCFlags=default
                        else
                                export Type_FCFlags=custom
                        fi
                else
                        echo "$mpi_compiler not found"
                        exit 1
                fi
                export CFLAGS=$mpi_cflags
                export CXXFLAGS=$mpi_cxxflags
                export FCFLAGS=$mpi_fcflags
                mkdir -p $home_dir/apps/$DIR_STR
                mkdir -p $home_dir/source_codes/$DIR_STR
                cd $home_dir/source_codes/$DIR_STR
                rm -rf *
                wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-${mpi_version}.tar.gz
                tar -xf openmpi-${mpi_version}.tar.gz
                cd openmpi-${mpi_version}
                echo "#==============================================CONFIGURATION================================================#"
                echo "#                                                                                                           #"
                echo "CC=$CC , CXX=$CXX , FC=$FC , CFLAGS=$CFLAGS ,  CXXFLAGS=$CXXFLAGS  , FCFLAGS=$FCFLAGS "
                echo "which \$CC is= $(which $CC)"
                echo "#                                                                                                           #"
                echo "#===========================================================================================================#"
                if [[ -d /opt/mellanox/hcoll ]];
                then
                        options="--with-hcoll=/opt/mellanox/hcoll"
                fi
                if [[ -d /opt/knem-1.1.4.90mlnx1 ]];
                then
                        options="$options --with-knem=/opt/knem-1.1.4.90mlnx1"
                fi
                if [[ -d /home/software/ucc/1.2.0 ]];
                then
                        options="$options --with-ucc=/home/software/ucc/1.2.0"
                fi
                if [[ -d /home/software/ucx/1.14.0_mt ]];
                then
                        options="$options --with-ucx=/home/software/ucx/1.14.0_mt"
                fi
                if [[ -d /home/software/xpmem/2.3.0 ]];
                then
                        options="$options --with-xpmem=/home/software/xpmem/2.3.0"
                fi
                if [[ -d /cm/shared/apps/slurm/20.02.6 ]];
                then
                        options="$options --with-pmi=/cm/shared/apps/slurm/20.02.6"
                fi
                if [[ -d /home/software/hwloc/2.3.0s ]];
                then
                        options="$options --with-hwloc=/home/software/hwloc/2.3.0s"
                fi
                echo "configure:    ./configure --prefix=$home_dir/apps/$DIR_STR CC=${CC} CXX=${CXX} FC=${FC} CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" FCFLAGS="$FCFLAGS" --enable-mpi-fortran $options"
                ./configure --prefix=$home_dir/apps/$DIR_STR CC=${CC} CXX=${CXX} FC=${FC} CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" FCFLAGS="$FCFLAGS" --enable-mpi-fortran $options

                make -j $(nproc)
                make install
                if [ -e $home_dir/apps/$DIR_STR/bin/mpirun ];
                then
                        print_line success MPI        
                else
                        print_line failed MPI
                        exit 1
                fi
                mkdir -p $home_dir/module_files/$mpi/$mpi_version/$mpi_compiler
                echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "Adds openmpi to your environment variables"
                    }
module-whatis \"Adds $mpi/$mpi_version/$mpi_compiler/$mpi_compiler_version
Type_CFlags:    $Type_CFlags
CFlags:         $mpi_cflags
Type_CXXFlags:  $Type_CXXFlags
CXXFlags:       $mpi_cxxflags
Type_FCFlags:   $Type_FCFlags
FCFlags:        $mpi_fcflags
\"
set             root                    $home_dir/apps/$DIR_STR
setenv          OPENMPIROOT             \$root
setenv          MPIROOT                 \$root
setenv          MPI_DIR                 \$root
prepend-path    PATH                    \$root/bin
prepend-path    LD_LIBRARY_PATH         \$root/lib
prepend-path    LIBRARY_PATH            \$root/lib
prepend-path    C_INCLUDE_PATH          \$root/include
prepend-path    CPLUS_INCLUDE_PATH      \$root/include
prepend-path    INCLUDE                 \$root/include
prepend-path    CPATH                   \$root/include
prepend-path    FPATH                   \$root/include
prepend-path    MANPATH                 \$root/share/man
prepend-path    PKG_CONFIG_PATH         \$root/lib/pkgconfig
setenv          MPI_HOME                \$root
$comp_path
        " > $home_dir/module_files/$mpi/$mpi_version/$mpi_compiler/$mpi_compiler_version
                rm -rf $home_dir/source_codes/$DIR_STR
        elif [ $mpi == "intel-mpi" ] || [ $mpi == "intel-oneapi-mpi" ];
        then
                print_line spack INTEL-MPI
                if [[ -d $home_dir/spack ]];
                then
                        echo "In $home_dir spack is already exist Installing mpi with spack"
                else
                        echo "spack is not found in $home_dir"
                        intel_cur_dir=$PWD
                        cd $home_dir
                        git clone https://github.com/spack/spack.git
                        cd $intel_cur_dir
                fi
                if [[ -z $(which spack) ]] && [[ -f $home_dir/spack/share/spack/setup-env.sh ]];
                then
                        source $home_dir/spack/share/spack/setup-env.sh
                else
                        echo "Check spack dir and Environment"
                fi

                available_cmp=$(spack compilers)
                available_cmp=$(echo $available_cmp | grep "Available compilers")
                if [[ -z $available_cmp ]];
                then
                        echo "Base compiler is not found in spack, adding base compiler"
                        spack compiler find
                fi
                mpi_valid=$(spack list ${mpi})
                if [[ -z $mpi_valid ]];
                then
                        echo "$mpi is not available in spack. Exit..."
                        exit
                fi
                mpi_version_valid=$(spack versions ${mpi})
                mpi_version_valid=$(echo $mpi_version_valid | grep $mpi_version)
                if [[ -z $mpi_version_valid ]];
                then
                        echo "$mpi_version_valid mpi version is not found in spack"
                        exit
                fi
                echo "Installing MPI thropugh spack ......."
                spack install -vvv ${mpi}@${mpi_version}
                mpi_installation_confirm=$(spack find ${mpi}@${mpi_version})
                if [[ -z $mpi_installation_confirm ]];
                then
                        echo "MPI Installation is failed. Exiting ..."
                        exit
                else
                        echo "$mpi is installed with spack installing wrapper compiler"
                        $home_dir/scripts/compiler.sh --compiler_name=$mpi_compiler --compiler_version=$mpi_compiler_version
                        export comp_path=$(ml show ${mpi_compiler}/${mpi_compiler_version} | awk '{ if ( $2 == "PATH" ) print $0 }')
                        if [[ -f $home_dir/module_files/$mpi_compiler/$mpi_compiler_version ]];
                        then
                                echo "Wrapper compiler installed successfully"
                        else
                                echo "Wrapper compiler installation failed"
                                exit
                        fi
                        echo "Creating module file for $mpi"
                        cur_dir=$PWD
                        spack cd -i ${mpi}@${mpi_version}
                        mpi_inst_root=$PWD
                        mkdir -p $home_dir/module_files/$mpi/$mpi_version/$mpi_compiler
                        if [[ $mpi == "intel-mpi" ]];
                        then
                                cd $mpi_inst_root
                                cd impi
                                cd $mpi_version
                                cd intel64
                                export mpi_inst_root=$PWD
                                cd $cur_dir
                                if [ -e $mpi_inst_root/bin/mpiicc ];
                                then
                                        print_line success MPI        
                                else
                                        print_line falied MPI
                                        exit 1
                                fi
                                echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
    puts stderr "\tAdds ${mpi} to your environment variables"
}
module-whatis \"Adds $mpi/$mpi_version/$mpi_compiler/$mpi_compiler_version
Type_CFlags:   default
CFlags:
Type_CXXFlags:  default
CXXFlags:
Type_FCFlags:   default
FCFlags:
\"
set             mpi_root           $mpi_inst_root
setenv          MPIROOT            \$mpi_root
setenv          MPI_DIR            \$mpi_root
setenv          INTELMPIROOT       \$mpi_root
prepend-path    PATH               \$mpi_root/bin
prepend-path    PATH               \$mpi_root/libfabric/bin
prepend-path    INCLUDE            \$mpi_root/include
prepend-path    CPATH              \$mpi_root/include
prepend-path    C_INCLUDE_PATH     \$mpi_root/include
prepend-path    CPLUS_INCLUDE_PATH \$mpi_root/include
prepend-path    FPATH              \$mpi_root/include
prepend-path    LIBRARY_PATH       \$mpi_root/lib
prepend-path    LD_LIBRARY_PATH    \$mpi_root/lib
prepend-path    CLASSPATH          \$mpi_root/lib/mpi.jar
prepend-path    LIBRARY_PATH       \$mpi_root/lib/release_mt
prepend-path    LD_LIBRARY_PATH    \$mpi_root/lib/release_mt
prepend-path    LIBRARY_PATH       \$mpi_root/libfabric/lib
prepend-path    LD_LIBRARY_PATH    \$mpi_root/libfabric/lib
prepend-path    LIBRARY_PATH       \$mpi_root/libfabric/lib/prov
prepend-path    LD_LIBRARY_PATH    \$mpi_root/libfabric/lib/prov
$comp_path
        " > ${home_dir}/module_files/${mpi}/${mpi_version}/${mpi_compiler}/${mpi_compiler_version}
                        else
                                cd $mpi_inst_root
                                cd mpi
                                cd $mpi_version
                                export mpi_inst_root=$PWD
                                cd $cur_dir
                                if [ -e $mpi_inst_root/bin/mpiicc ];
                                then
                                        print_line success MPI        
                                else
                                        print_line failed MPI
                                        exit 1
                                fi
                                echo "#%Module1.0#####################################################################
proc ModulesHelp { } {
puts stderr "\tAdds ${mpi} to your environment variables"
}
module-whatis \"Adds $mpi/$mpi_version/$mpi_compiler/$mpi_compiler_version
Type_CFlags:   default
CFlags:
Type_CXXFlags:  default
CXXFlags:
Type_FCFlags:   default
FCFlags:
\"
set             mpi_root           $mpi_inst_root
setenv          MPIROOT            \$mpi_root
setenv          INTELMPIROOT       \$mpi_root
prepend-path    PATH               \$mpi_root/bin
prepend-path    PATH               \$mpi_root/libfabric/bin
prepend-path    INCLUDE            \$mpi_root/include
prepend-path    CPATH              \$mpi_root/include
prepend-path    C_INCLUDE_PATH     \$mpi_root/include
prepend-path    CPLUS_INCLUDE_PATH \$mpi_root/include
prepend-path    FPATH              \$mpi_root/include
prepend-path    LIBRARY_PATH       \$mpi_root/lib
prepend-path    LD_LIBRARY_PATH    \$mpi_root/lib
prepend-path    CLASSPATH          \$mpi_root/lib/mpi.jar
prepend-path    LIBRARY_PATH       \$mpi_root/lib/release_mt
prepend-path    LD_LIBRARY_PATH    \$mpi_root/lib/release_mt
prepend-path    LIBRARY_PATH       \$mpi_root/libfabric/lib
prepend-path    LD_LIBRARY_PATH    \$mpi_root/libfabric/lib
prepend-path    LIBRARY_PATH       \$mpi_root/libfabric/lib/prov
prepend-path    LD_LIBRARY_PATH    \$mpi_root/libfabric/lib/prov
$comp_path
        " > ${home_dir}/module_files/${mpi}/${mpi_version}/${mpi_compiler}/${mpi_compiler_version}
                        fi
                fi
        fi
        unlock "$locked_files"
        } 2>&1 | tee $home_dir/log_files/$mpi/$mpi_version/$mpi_compiler/${mpi_compiler_version}_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

