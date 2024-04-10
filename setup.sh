#!/bin/bash
main_dir=$PWD
mkdir log_files  module_files source_codes
####################################MODULE FILE CREATION##############################
cd module_files
mkdir gmp  m4  mpc  mpfr
echo '#%Module1.0#####################################################################
module-whatis {loads gmp}' > gmp/6.2.1
echo "set    root $main_dir/apps/gmp/6.2.1" >> gmp/6.2.1
echo 'setenv    GMPROOT     $root
prepend-path    INCLUDE  $root/include
prepend-path    LD_LIBRARY_PATH  $root/lib ' >> gmp/6.2.1

echo '#%Module1.0#####################################################################
module-whatis {loads m4}' > m4/1.4.19
echo "set    root   $main_dir/apps/m4/1.4.19" >> m4/1.4.19
echo 'setenv   M4ROOT     $root
prepend-path    PATH     $root/bin' >> m4/1.4.19

echo '#%Module1.0#####################################################################
module-whatis {loads mpc}' > mpc/1.2.1
echo "set    root  $main_dir/apps/mpc/1.2.1" >> mpc/1.2.1
echo 'setenv    MPCROOT     $root
prepend-path    INCLUDE  $root/include
prepend-path    LD_LIBRARY_PATH  $root/lib' >> mpc/1.2.1

echo '#%Module1.0#####################################################################
module-whatis {loads mpfr}' > mpfr/4.2.0
echo "set root   $main_dir/apps/mpfr/4.2.0" >> mpfr/4.2.0
echo 'setenv         MPFRROOT   $root
prepend-path    PATH     $root/bin
prepend-path    MANPATH  $root/man
prepend-path    INCLUDE  $root/include
prepend-path    LD_LIBRARY_PATH  $root/lib
prepend-path    LD_LIBRARY_PATH  $root/lib64' >> mpfr/4.2.0

########################################################################################
cd $main_dir
git clone https://github.com/spack/spack.git
source $main_dir/spack/share/spack/setup-env.sh
spack compiler find
#######################################################################################
