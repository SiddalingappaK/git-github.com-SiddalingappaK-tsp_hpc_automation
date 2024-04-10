#!/bin/bash
if [[ -z $home_dir ]];
then
        cd ..
        export home_dir=$PWD
        cd -
fi

unset MODULEPATH
module use ${home_dir}/module_files

load()
{
    arg=$*
    index=$(echo "$arg{}" | awk '{print index($0, "=")}')
    key=${arg:2:$[$index-3]}
    value=${arg:$index}
    value="$(echo -e "${value}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    value="$(echo -e "${value}" | tr -s '[:space:]')"
    if [[ "${value}" == "" ]]; then
        return 0
    fi
    export $key="$value"
    echo "$key : $value"
    return 1
}


load_check_flags()
{
    flags_count=$1
    count=0
    shift 1
    for flag in $*;
    do
        if [[ ${!flag} ]];
        then
            count=$[$count+1]
        fi
        if [[ $count == $flags_count ]];
        then
            return 1
        fi
    done
    return 0
}

build_check()
{
    #build_check <path_to_module_file> CFlags:CXXFlags:FCFlags <CFlags>:<CXXFlags>:<FCFlags
    combination=$1
    module_file=$home_dir/module_files/$combination
    n_flags=$(echo $2 | awk 'BEGIN{RS=":"}{}END{print NR}')
    rebuilt=0
    if [[ -f $module_file ]];
    then
        for((i=1; i<=$n_flags; i++));
        do
            flag=$(echo $2 | cut -d ":" -f $i)
            old=$(cat $module_file | grep "^ *$flag" | cut -d ":" -f 2)
            new=$(echo $3 | cut -d ":" -f $i)
            type=$(cat $module_file | grep "Type_$flag" | grep "default" )
            if [[ -z $old ]];
            then
                rebuilt=0
                break
            fi
            if [[ -z $new ]];
            then
                if [[ -z $type ]];then
                    rebuilt=1
                    break
                fi
                continue
            fi
            old_wc=$(echo $old | awk '{$1=$1} 1' | awk '{print NF}')
            new_wc=$(echo $new | awk '{$1=$1} 1' | awk '{print NF}')
            if [[ $old_wc == $new_wc ]];
            then
                for j in $new
                do
                    old=$(echo $old | grep "\\$j")
                done
                if [[ -z $old ]];
                then
                    rebuilt=1
                    break
                fi
            else
                rebuilt=1
                break
            fi
        done
    else
        rebuilt=1
    fi
    return $rebuilt
}
lock_check()
{
    combination=$1
    module_file=$home_dir/module_files/$combination
    in_use=$(cat $home_dir/lock | grep "^$combination")
    if [[ -n $in_use ]];
    then
        echo "The combination is Locked.Wait until lock gets release"
        echo "Waiting..."
    fi
    while [[ -n $in_use ]];
    do
        in_use=$(cat $home_dir/lock | grep "^$combination")
        if [[ -z $in_use ]];
        then
            echo "Lock Released"
        else
            sleep 5
        fi
    done
}

lock()
{
    for file in $*;
    do
        locked_files="$locked_files $file"
        echo "$file" >> $home_dir/lock
    done
}
unlock()
{
    for file in $*;
    do
        n=$(cat $home_dir/lock | grep -n "^$file$" | awk 'BEGIN{FS=":"}{print $1}' | head -n 1);sed -i "${n}d" $home_dir/lock
    done
}
restart-lock()
{
    echo "" > $home_dir/lock
}
print_line()
{
    status=$1
    value=$2
    first_line="#=====================================================================================#"
    case $status in
    found)
        text="REQUESTED $value IS PRESENT IN MODULES LOADING MODULE"
        ;;
    not_found)
        text="$value IS NOT FOUND IN MODULES BUILDING $value"
        ;;
    failed)
        text="$value BUILD FAILED"
        ;;
    success)
        text="$value BUILD SUCCESSFUL"
        ;;
    hostname)
        text="HOSTNAME:    $(hostname)"
        ;;
    header)
        text="$value SCRIPT"
        ;;
    spack)
        text="BUILDING $value THROUGH SPACK AND ADDING MODULE FILE"
        ;;
    esac
    space_length=$[85-${#text}]
    left_padding=$(( space_length/2 ))
    right_padding=$[$space_length-$left_padding]
    echo $first_line
    printf "#%*s#\n" 85
    printf "#%*s%s%*s#\n" $left_padding "" "$text" $right_padding ""
    printf "#%*s#\n" 85
    echo $first_line
    
}

