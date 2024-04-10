#!/bin/bash
echo "#===========================================================================================================#"
echo "#                                                                                                           #"
echo "#                                       JEMALLOC BUILD SCRIPT                                               #"
echo "#                                                                                                           #"
echo "#===========================================================================================================#"

jemalloc_usage()
{
    echo "
    Usage: ./jemalloc.sh [OPTIONS] [ARGS]
    Eg:    ./jemalloc.sh --jemalloc_version=<jemalloc_version>\\
                     --jemalloc_compiler=<jemalloc_compiler>\\
                     --jemalloc_compiler_version=<jemalloc_mpi_version>\\
                     --jemalloc_flags=<jemalloc_flags>
    Builds the jemalloc Module of specified version with specified compiler specifications.

    Example: ./jemalloc.sh --jemalloc_version=5.2.1 --jemalloc_compiler=aocc --jemalloc_compiler_version=4.0.0
             --jemalloc_mpi_flags
             --jemalloc_flags
    <jemalloc_version>:             specify the version of jemalloc
                                    Recommended version : 5.2.1
                                    Latest version : 5.3.0

    <jemalloc_compiler>:            specify the mpi to build jemalloc.The following are the available mpi:
                                    aocc
                                    gcc
				    intel-oneapi-compilers-classic

    <jemalloc_compiler_version>:    Specify the version to build <jemalloc_compiler>
                                    for "aocc" as <jemalloc_compiler> the following are the supported versions:
                                        3.2.0
                                        4.0.0

    <jemalloc_flags> [optional]:    specify the jemalloc flags to build jemalloc
                                    default jemalloc_flags for <jemalloc_compiler>
                                    aocc:   '-O3  -march=znver4 -fopenmp'
                                    gcc:    '-O3  -march=znver4 -fopenmp'
                                    intel-oneapi-compilers-classic: '-O3 -march=skylake-avx512 -qopenmp'

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
if [[ -z ${jemalloc_version} ]]  || [[ -z ${jemalloc_compiler} ]] || [[ -z ${jemalloc_compiler_version} ]] ;
then
    jemalloc_usage
    exit
fi
min_options=3
if [[ $n_arg -gt ${min_options} ]];
then
    load_check_flags $[$n_arg-${min_options}] jemalloc_flags
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        openfoam_usage
        exit
    fi
fi
            
export build_packname=jemalloc-${jemalloc_version}
export jemalloc_packname=$build_packname

date=$(date | perl -pe 's/\s+/_/g;s/_$//;s/://g')
buildlog=buildlog.$jemalloc_packname.$USER.$(hostname -s).$(hostname -d).$date.txt

DIR_STR=jemalloc/${jemalloc_version}/${jemalloc_compiler}
build_check ${DIR_STR}/${jemalloc_compiler_version} "${jemalloc_flags}"

export rebuilt=$?
if [ $rebuilt == 0 ];
then
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                      JEMALLOC-${jemalloc_version} IS PRESENT LOADING MODULE ........                      #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    module load ${DIR_STR}/${jemalloc_compiler_version}
else
    mkdir -p ${home_dir}/log_files/${DIR_STR}
    {
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                       JEMALLOC-${jemalloc_version} IS NOT PRESENT IN MODULES                              #"
    echo "#                               Building JEMALLOC-${jemalloc_version}                                       #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    echo "#===========================================================================================================#"
    echo "#                                                                                                           #"
    echo "#                                       HOSTNAME:    $(hostname)                                            #"
    echo "#                                                                                                           #"
    echo "#===========================================================================================================#"
    set -eux
    jemalloc_vers=${jemalloc_version}.tar.gz
    jemalloc_archive=${jemalloc_packname}.tar.gz
    export JEMALLOC_SOURCE=${home_dir}/source_codes/$DIR_STR/jemalloc
    export JEMALLOC_BUILD=${home_dir}/apps/$DIR_STR/${jemalloc_compiler_version}
    mkdir -p ${JEMALLOC_SOURCE}
    mkdir -p ${JEMALLOC_BUILD}

    bash $home_dir/scripts/compiler.sh --compiler_name=$jemalloc_compiler --compiler_version=$jemalloc_compiler_version
    module load $jemalloc_compiler/$jemalloc_compiler_version

    if [  -e ${JEMALLOC_SOURCE}/$jemalloc_archive ]
    then
        echo "${jemalloc_packname} source file found in ${JEMALLOC_SOURCE}"
    else
        echo "Downloading ${jemalloc_packname}"
        wget -P ${JEMALLOC_SOURCE} https://github.com/jemalloc/jemalloc/archive/refs/tags/${jemalloc_vers}
        cd ${JEMALLOC_SOURCE}
        mv ${jemalloc_vers} ${jemalloc_archive}
    fi

    cd $JEMALLOC_BUILD
    rm -rf ${jemalloc_packname}

    tar -xf ${JEMALLOC_SOURCE}/$jemalloc_archive
    cd ${jemalloc_packname}

    ./autogen.sh CC=gcc CFLAGS="-O3" CXX=g++ CXXFLAGS="-O3" --prefix=${JEMALLOC_BUILD} |tee autoconf_$buildlog.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    ./configure  CC=gcc CFLAGS="-O3" CXX=g++ CXXFLAGS="-O3" --prefix=${JEMALLOC_BUILD} |tee configure_$buildlog.log

    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make -j 2>&1|tee make.log
    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    make install 2>&1|tee make_install.log
    rc=${PIPESTATUS[0]}
    [[ $rc -eq 0 ]] || exit $rc

    #Checking for installtion success
    if [ -e "$JEMALLOC_BUILD/lib/libjemalloc.so" ] || [ -e "$JEMALLOC_BUILD/lib64/libjemalloc.so" ];
    then
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                               ${jemalloc_packname} BUILD SUCCESSFUL                                       #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
            export LD_LIBRARY_PATH=$JEMALLOC_BUILD/lib:$JEMALLOC_BUILD/li64:$LD_LIBRARY_PATH
            export C_INCLUDE_PATH=$JEMALLOC_BUILD/include:$C_INCLUDE_PATH
            mkdir -p ${home_dir}/module_files/$DIR_STR

            echo "#%Module1.0#####################################################################
    proc ModulesHelp { } {
                puts stderr "\tAdds Jemalloc to your environment variables"
            }
            module-whatis \"sets the Jemalloc_root path
            Build flags:       $jemalloc_flags
            Build type:        $build_type\"
            set             root           ${JEMALLOC_BUILD}
            setenv          JEMALLOC_ROOT               \$root
            setenv          JEMALLOC_DIR                \$root
            setenv          JEMALLOC                    \$root
            prepend-path    LD_LIBRARY_PATH         \$root/lib
            prepend-path    C_INCLUDE_PATH          \$root/include
            " > ${home_dir}/module_files/$DIR_STR/$jemalloc_compiler_version

            module load $DIR_STR/$jemalloc_compiler_version
    else
            echo "#===========================================================================================================#"
            echo "#                                                                                                           #"
            echo "#                            Building ${jemalloc_packname} is UNSUCCESSFUL                                  #"
            echo "#                                                                                                           #"
            echo "#===========================================================================================================#"
            cd ${home_dir}
            exit 1
    fi
    } 2>&1 | tee ${home_dir}/log_files/${DIR_STR}/$jemalloc_compiler_version${date}.log

fi

