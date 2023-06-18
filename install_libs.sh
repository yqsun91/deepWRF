#!/bin/bash
# Script for installing the libraries needed before WRF and WPS compile

# Load system modules
module reset # Should include intel/18.0.2 impi/18.0.2
module load netcdf/4.6.2 pnetcdf/1.11.0 phdf5/1.10.4

export DIR=$PWD/LIBRARIES
mkdir -f $DIR
cd $DIR
export CC=icc
export CXX=icpc
export FC=ifort
export FCFLAGS=-m64
export F77=ifort
export FFLAGS=-m64
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include


# We're using the system NetCDF module
export NETCDF=${TACC_NETCDF_DIR}

# We're using the system MVAPICH2 implementation

# zlib

wget https://zlib.net/fossils/zlib-1.2.7.tar.gz

tar -xzvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$DIR/grib2
make
make install
cd ..

#libpng
wget https://sourceforge.net/projects/libpng/files/libpng12/older-releases/1.2.50/libpng-1.2.50.tar.gz

tar -xzvf libpng-1.2.50.tar.gz
cd libpng-1.2.50
./configure --prefix=$DIR/grib2
make
make install
cd ..

# Jasper 1.900.1
#wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
#tar xzvf jasper-1.900.1.tar.gz

wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip

cd jasper-1.900.1
./configure --prefix=$DIR/grib2
make
make install
cd ..
