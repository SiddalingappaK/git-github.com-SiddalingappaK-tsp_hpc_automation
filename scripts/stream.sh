#!/bin/bash
if [ -z $home_dir ];
then
    source ./env_set.sh
else
    source $home_dir/scripts/env_set.sh
fi
print_line header STREAM
stream_usage()
{
        echo "
        Usage : ./stream.sh --stream_compiler=<stream_compiler> \\
                            --stream_compiler_version=<stream_compiler_version> \\
                            --stream_array_size=<stream_array_size> \\
                            --stream_cflags=<stream_flags>

        Example:./stream.sh --stream_compiler=aocc --stream_compiler_version=4.0.0 --stream_array_size=1342214144 \\
                 --stream_cflags=\"-O3 -mcmodel=large -DSTREAM_TYPE=double -mavx2 -DNTIMES=10 -ffp-contract=fast -march=znver4 -lomp -fopenmp\"

        <stream_compiler>:              Specify the compiler to build stream
                                        The following are the available compilers :
                                        aocc
                                        gcc
                                        intel-oneapi-compilers-classic

        <stream_compiler_version>:      Specify the version to the <stream_compiler>
                                        for <openfoam_mpi_compiler> as "aocc" the following are the supported versions:
                                        3.2.0
                                        4.0.0

        <stream_array_size> [optional]: Specify the array size to build the stream

        <stream_cflags> [optional] :    Specify the flags to build the stream
                                        Default flags:
                                        for aocc or gcc:
                                             -O3 -mcmodel=large -DSTREAM_TYPE=double -mavx2 -DNTIMES=10 -ffp-contract=fast -march=znver4 -lomp -fopenmp
                                        for intel-oneapi-compilers-classic :
                                             -O3 -mcmodel=large -DSTREAM_TYPE=double -mavx2 -DNTIMES=10 -ffp-contract=fast -march=znver4 -lomp -qopenmp

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
if [ -z $stream_compiler ] || [ -z $stream_compiler_version ];
then
        stream_usage
        exit
fi
manditory_options=2
if [[ $n_arg -gt ${manditory_options} ]];
then
    load_check_flags $[$n_arg-${manditory_options}] stream_cflags stream_array_size
    if [ $? == 0 ];
    then
        echo "Flags specified incorrecly, Exiting... "
        stream_usage
        exit
    fi
fi
export DIR_STR=stream/$stream_compiler/$stream_compiler_version

if [ -z $stream_array_size ]; then
        total_cores=`lscpu | grep "Core(s) per socket" | cut -d ":" -f 2`
        total_sockets=`lscpu | grep "Socket(s)" | cut -d ":" -f 2`
        l3cache_size=`lscpu | grep "L3 cache" | cut -d ":" -f 2`
        stream_array_size=`echo "(4*($total_cores/8)*$total_sockets*$l3cache_size*1024)/8" | bc`
fi
build_check $DIR_STR/$stream_array_size CFlags "$stream_cflags"
export rebuilt=$?
if [[ $rebuilt == 0 ]];then
        print_line found STREAM
        module load $DIR_STR/$stream_array_size
        exit
else
        mkdir -p $home_dir/log_files/$DIR_STR
        {
        print_line not_found STREAM
        print_line hostname $hostname
        lock_check "$DIR_STR/$stream_array_size"
        build_check $DIR_STR/$stream_array_size CFlags "$stream_cflags"
        export rebuilt=$?
        if [ $rebuilt == 0 ];
        then
            print_line found STREAM
            module load $DIR_STR/$stream_array_size
            exit
        fi
        locked_files=""
        trap 'unlock "$locked_files"' EXIT SIGINT
        lock "$DIR_STR/$stream_array_size"
        rm -rf $home_dir/apps/$DIR_STR/$stream_array_size $home_dir/module_files/$DIR_STR/$stream_array_size
        export STREAM_BUILD=$home_dir/apps/$DIR_STR/$stream_array_size
        mkdir -p $STREAM_BUILD
        stream_cur_dir=$PWD
        cd $home_dir/scripts
        bash $home_dir/scripts/compiler.sh --compiler_name=$stream_compiler --compiler_version=$stream_compiler_version
        cd $stream_cur_dir
        module load $stream_compiler/$stream_compiler_version
        lock "$stream_compiler/$stream_compiler_version"
        if [ -e $home_dir/source_codes/stream ];
        then
                echo "STREAM source code is already exits and compilation starts...."
        else
                cd $home_dir/source_codes/
                git clone https://github.com/jeffhammond/STREAM.git
        fi

        case $stream_compiler in
                aocc)
                        export CC=clang
                        if [[ -z $stream_cflags ]];
                        then
                            echo "stream_cflags is not defined. Choosing default CFLAGS"
                            export stream_cflags="-O3 -mcmodel=large -DSTREAM_TYPE=double -mavx2 -DNTIMES=10 -ffp-contract=fast -march=znver4 -lomp -fopenmp"
                            export Type_CFlags=default
                        else
                            export Type_CFlags=custom
                        fi
                        ;;
                gcc)
                        export CC=gcc
                        if [[ -z $stream_cflags ]];
                        then
                            echo "stream_cflags is not defined. Choosing default CFLAGS"
                            export stream_cflags="-O3 -mcmodel=large -DSTREAM_TYPE=double -mavx2 -DNTIMES=10 -ffp-contract=fast -march=znver4 -lomp -fopenmp"
                            export Type_CFlags=default
                        else
                            export Type_CFlags=custom
                        fi
                        ;;
                intel-oneapi-compilers-classic)
                        export CC=icc
                        if [[ -z $stream_cflags ]];
                        then
                            echo "stream_cflags is not defined. Choosing default CFLAGS"
                            export stream_cflags="-O3 -mcmodel=large -DSTREAM_TYPE=double -mavx2 -DNTIMES=10 -diag-disable=10441 -lomp -qopenmp"
                            export Type_CFlags=default
                        else
                            export Type_CFlags=custom
                        fi
                        ;;
        esac
        cd $home_dir/source_codes/STREAM
        $CC -DSTREAM_ARRAY_SIZE=$stream_array_size $stream_cflags stream.c -o $STREAM_BUILD/stream_01
        if [ -e $STREAM_BUILD/stream_01 ];
        then
                print_line success STREAM
                mkdir -p ${home_dir}/module_files/$DIR_STR
                echo "#%Module1.0#####################################################################
                proc ModulesHelp { } {
                puts stderr "\tsets the STREAMROOT path"
                }
                module-whatis \"sets the STREAMROOT path
                Type_CFlags:    $Type_CFlags
                CFlags:         $stream_cflags \"
                setenv     STREAMROOT   $STREAM_BUILD
                " > ${home_dir}/module_files/$DIR_STR/$stream_array_size
        else
                print_line failed STREAM
                cd $home_dir
                exit
        fi
        unlock "$locked_files"
        } 2>&1 | tee $home_dir/log_files/$DIR_STR/$stream_array_size_$(date | awk '{print $1 $2 $3 $4 $5 $6}').log
fi

