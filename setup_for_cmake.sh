######################################
#
export UPSBOOT=/cvmfs/fermilab.opensciencegrid.org/products/common/etc/setup
source ${UPSBOOT}

export PRODUCTS=${PRODUCTS}:/cvmfs/dune.opensciencegrid.org/products/dune:/cvmfs/fermilab.opensciencegrid.org/products/larsoft:/geant4/app/users/rhatcher/externals

setup cmake
setup gcc v6_3_0
setup root v6_10_08b -q e14:debug:nu
# this will bring CLHEP v2_3_4_5a -q e14:debug:nu
setup xerces_c v3_1_4b -q e14:debug

export CCFORCE="env CC=gcc CXX=g++ FC=gfortran"

export INSTALLDATA="OFF"
export BEXAMPLES="ON"
export BTESTS="ON"

export MYG4TOP="/geant4/app/rhatcher/gmake_testing"
# try to avoid needless downloads
export GEANT4_INSTALL_DATADIR="${MYG4TOP}/data"
export G4DATA=${GEANT4_INSTALL_DATADIR}

export G4SYSTEM="Linux-g++" # "Darwin-clang"
echo "On this machine the G4SYSTEM=$G4SYSTEM"
# default for Linux+g++ is G4USE_STD11, also G4USE_STD14, G4USE_STD17
# G4OPTIMISE (yes "S"), G4DEBUG, G4PROFILE, G4OPTDEBUG
# G4MULTITHREADED
export G4USE_STD14=1
export CXXSTD="c++14"
export G4DEBUG=1

export G4FQ=Linux-gcc-${CXXSTD}

# make G4 runtime more verbose
#export G4VERBOSE=1

# make _build_ (compile) more verbose
#export CPPVERBOSE=1

#
# g4shared vs BUILD_STATIC_LIBS
#
unset G4CMAKEFLGS
export G4CMAKEFLGS="-DGEANT4_INSTALL_DATADIR=${GEANT4_INSTALL_DATADIR}"
if [ "$1" != "static" ]; then
  export BTYPE=shared
  export G4LIB_BUILD_SHARED=1
  unset  G4LIB_BUILD_STATIC
  G4CMAKEFLGS="$G4CMAKEFLGS -DBUILD_SHARED_LIBS=ON"
  G4CMAKEFLGS="$G4CMAKEFLGS -DBUILD_STATIC_LIBS=OFF"
else
  export BTYPE=static
  unset  G4LIB_BUILD_SHARED
  export G4LIB_BUILD_STATIC=1
  G4CMAKEFLGS="$G4CMAKEFLGS -DBUILD_SHARED_LIBS=OFF"
  G4CMAKEFLGS="$G4CMAKEFLGS -DBUILD_STATIC_LIBS=ON"
fi
echo "On this machine the G4LIB_BUILD_SHARED=$G4LIB_BUILD_SHARED"
echo "On this machine the G4LIB_BUILD_STATIC=$G4LIB_BUILD_STATIC"

# rwh is this the source dir? assuming so
export G4INSTALL="${MYG4TOP}/geant4"
export G4SOURCE=$G4INSTALL
#  #"$HOME/Software/geant4"
echo "On this machine the G4INSTALL=$G4INSTALL"

G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_BUILD_CXXSTD=${CXXSTD}"
G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_BUILD_GRANULAR_LIBS=OFF"
G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_USE_G3TOG4=ON"
G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_USE_OPENGL_X11=ON"
# root brings in CLHEP
if [ -z "${CLHEP_BASE}" ]; then
  G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_USE_SYSTEM_CLHEP=OFF"  # was ON
else
  G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_USE_SYSTEM_CLHEP=ON"
  G4CMAKEFLGS="$G4CMAKEFLGS -DCLHEP_ROOT_DIR=${CLHEP_BASE}"
fi
if [ -z "${XERCESCROOT}" ]; then
  G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_USE_GDML=OFF"  # was ON, need xerces
else
  G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_USE_GDML=ON"  # was ON, need xerces
  G4CMAKEFLGS="$G4CMAKEFLGS -DXERCESC_ROOT_DIR=${XERCESCROOT}"
fi
G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_INSTALL_DATA=${INSTALLDATA}"
G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_ENABLE_TESTING=${BTESTS}"
G4CMAKEFLGS="$G4CMAKEFLGS -DGEANT4_BUILD_EXAMPLES=${BEXAMPLES}"

export G4_SETUP_SCRIPT=setup_g4_${BTYPE}_${G4FQ}.sh


#
export G4WORKDIR="${MYG4TOP}/geant4_wd_cmake_${BTYPE}"
if [ ! -d ${G4WORKDIR} ]; then mkdir -p ${G4WORKDIR} ; fi
# "${MYG4TOP}/geant4_wd"
echo "On this machine the G4WORKDIR=$G4WORKDIR"

#
#  cmake .. lib64
export G4LIB="$G4WORKDIR/lib64"
#echo "On this machine the G4LIB=$G4LIB"

#
export G4INCLUDE="$G4WORKDIR/include"
export G4BIN="$G4WORKDIR/bin"
#echo "On this machine the G4BIN=$G4BIN"

export G4CMAKEBUILD="$G4WORKDIR/cmake_build"
if [  ! -d ${G4CMAKEBUILD} ]; then
  mkdir -p ${G4CMAKEBUILD}
fi

#### add to paths !!!!  but first clear out previous (if any) references
export PATH=`dropit -E -D -p "$PATH" geant4`
export LD_LIBRARY_PATH=`dropit -E -D -p "$LD_LIBRARY_PATH" geant4`
export PATH=${PATH}:${G4BIN}/${G4SYSTEM}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${G4LIB}/${G4SYSTEM}

#
export G4LEVELGAMMADATA="${MYG4TOP}/data/PhotonEvaporation5.2"
echo "On this machine the G4LEVELGAMMADATA=$G4LEVELGAMMADATA"
export G4RADIOACTIVEDATA="${MYG4TOP}/data/RadioactiveDecay5.2"
echo "On this machine the G4RADIOACTIVEDATA=$G4RADIOACTIVEDATA"
export G4LEDATA="${MYG4TOP}/data/G4EMLOW7.3"
echo "On this machine the G4LEDATA=$G4LEDATA"
export G4NEUTRONHPDATA="${MYG4TOP}/data/G4NDL4.5"
echo "On this machine the G4NEUTRONHPDATA=$G4NEUTRONHPDATA"
export G4REALSURFACEDATA="${MYG4TOP}/data/RealSurface2.1"
echo "On this machine the G4REALSURFACEDATA=$G4REALSURFACEDATA"
export G4NEUTRONXSDATA="${MYG4TOP}/data/G4NEUTRONXS1.4"
echo "On this machine the G4NEUTRONXSDATA=$G4NEUTRONXSDATA"
export G4PIIDATA="${MYG4TOP}/data/G4PII1.3"
echo "On this machine the G4PIIDATA=$G4PIIDATA"
export G4SAIDXSDATA="${MYG4TOP}/data/G4SAIDDATA1.1"
echo "On this machine the G4SAIDXSDATA=$G4SAIDXSDATA"
export G4ABLADATA="${MYG4TOP}/data/G4ABLA3.1"
echo "On this machine the G4ABLADATA=$G4ABLADATA"
export G4ENSDFSTATEDATA="${MYG4TOP}/data/G4ENSDFSTATE2.2"
echo "On this machine the G4ENSDFSTATEDATA=$G4ENSDFSTATEDATA"

export G4LENDDATA="${MYG4TOP}/data/test65_Data/g4lend"
echo "On this machine the G4LENDDATA=$G4LENDDATA"
#
# export CLHEP_BASE_DIR "${MYG4TOP}/CLHEP"
echo "On this machine the CLHEP_BASE_DIR=$CLHEP_BASE_DIR"
#
#rwh#export XERCESCROOT="/usr/local"
echo "On this machine the XERCESCROOT=$XERCESCROOT"

#
export G4UI_BUILD_XM_SESSION=1
export G4UI_USE_XM=1
echo "On this machine the G4UI_USE_XM=$G4UI_USE_XM"

#
#rwh#export QTHOME=/opt/alt/Qtx
export G4UI_BUILD_QT_SESSION=0 # was 1
unset  G4UI_BUILD_QT_SESSION
export G4UI_USE_QT=0 # was 1
unset  G4UI_USE_QT
echo "On this machine the G4UI_USE_QT=$G4UI_USE_QT"


#
# export OIVHOME "/usr/local"

export G4VIS_BUILD_OPENGLX_DRIVER=1
export G4VIS_USE_OPENGLX=1
echo "On this machine the G4VIS_USE_OPENGLX=$G4VIS_USE_OPENGLX"

export G4VIS_BUILD_OPENGLXM_DRIVER=1
export G4VIS_USE_OPENGLXM=1
echo "On this machine the G4VIS_USE_OPENGLXM=$G4VIS_USE_OPENGLXM"

#export G4VIS_BUILD_OIX_DRIVER=1
#export G4VIS_USE_OIX=1
#echo "On this machine the G4VIS_USE_OIX=$G4VIS_USE_OIX"

export G4VIS_BUILD_OPENGLQT_DRIVER=0 # was 1
unset  G4VIS_BUILD_OPENGLQT_DRIVER
export G4VIS_USE_OPENGLQT=0 # was 1
unset  G4VIS_USE_OPENGLQT
echo "On this machine the G4VIS_USE_OPENGLQT=$G4VIS_USE_OPENGLQT"

export G4VIS_BUILD_OIQT_DRIVER=0 # was commented out as 1
unset  G4VIS_BUILD_OIQT_DRIVER
export G4VIS_USE_OIQT=0
unset  G4VIS_USE_OIQT
echo "On this machine the G4VIS_USE_OIQT=$G4VIS_USE_OIQT"

export G4VIS_BUILD_RAYTRACERX_DRIVER=1
export G4VIS_USE_RAYTRACERX=1
echo "On this machine the G4VIS_USE_RAYTRACERX=$G4VIS_USE_RAYTRACERX"

export G4VIS_BUILD_VRML_DRIVER=1
export G4VIS_USE_VRML=1
echo "On this machine the G4VIS_USE_VRML=$G4VIS_USE_VRML"

export G4VIS_BUILD_DAWN_DRIVER=1
export G4VIS_USE_DAWN=1
# unset G4VIS_BUILD_DAWN_DRIVER G4VIS_USE_DAWN
echo "On this machine the G4VIS_USE_DAWN=$G4VIS_USE_DAWN"

#

#

#

#

#

#

#
#export OGLHOME="/usr/X11R6"
#echo "On this machine the OGLHOME=$OGLHOME"

#
# Use ZLIB module
#
#export G4LIB_BUILD_ZLIB=1
#export G4LIB_USE_ZLIB=1
#echo "On this machine the G4LIB_USE_ZLIB=$G4LIB_USE_ZLIB"

#
# Use GDML module
#
export G4LIB_BUILD_GDML=1
export G4LIB_USE_GDML=1
echo "On this machine the G4LIB_USE_GDML=$G4LIB_USE_GDML"

export G4UI_USE_TCSH=1
echo "On this machine the G4UI_USE_TCSH=$G4UI_USE_TCSH"

export G4ANALYSIS_USEROOT=1
echo "On this machine the G4ANALYSIS_USEROOT=$G4ANALYSIS_USEROOT"

#####################################################################

cat > ${MYG4TOP}/${G4_SETUP_SCRIPT} <<EOF
source ${UPSBOOT}
export PRODUCTS=${PRODUCTS}

setup cmake    v3_9_6
setup gcc      v6_3_0
setup root     v6_10_08b -q e14:debug:nu
setup xerces_c v3_1_4b   -q e14:debug

export CCFORCE="env CC=gcc CXX=g++ FC=gfortran"

export MYG4TOP=${MYG4TOP}
export G4SOURCE=${G4SOURCE}
export G4FQ=${G4FQ}
export G4WORKDIR=${G4WORKDIR}
export G4CMAKEBUILD=${G4CMAKEBUILD}
export Geant4_DIR=\${G4WORKDIR}

G4CMAKEFLGS="${G4CMAKEFLGS}"

export GEANT4_INSTALL_DATADIR="${MYG4TOP}/data"
export G4LEVELGAMMADATA="${MYG4TOP}/data/PhotonEvaporation5.2"
export G4RADIOACTIVEDATA="${MYG4TOP}/data/RadioactiveDecay5.2"
export G4LEDATA="${MYG4TOP}/data/G4EMLOW7.3"
export G4NEUTRONHPDATA="${MYG4TOP}/data/G4NDL4.5"
export G4REALSURFACEDATA="${MYG4TOP}/data/RealSurface2.1"
export G4NEUTRONXSDATA="${MYG4TOP}/data/G4NEUTRONXS1.4"
export G4PIIDATA="${MYG4TOP}/data/G4PII1.3"
export G4SAIDXSDATA="${MYG4TOP}/data/G4SAIDDATA1.1"
export G4ABLADATA="${MYG4TOP}/data/G4ABLA3.1"
export G4ENSDFSTATEDATA="${MYG4TOP}/data/G4ENSDFSTATE2.2"


function g4_top() {
  cd \${MYG4TOP}
}

function g4_cmake() {
  if [ ! -d \${G4CMAKEBUILD} ]; then mkdir -p \${G4CMAKEBUILD} ; fi
  if [ ! -d \${G4WORKDIR}    ]; then mkdir -p \${G4WORKDIR}    ; fi
  cd \${G4CMAKEBUILD}
  \${CCFORCE} cmake -DCMAKE_INSTALL_PREFIX=\${G4WORKDIR} \${G4CMAKEFLGS} \${G4SOURCE}
}

function g4_build() {
  if [ ! -d \${G4CMAKEBUILD} ]; then mkdir -p \${G4CMAKEBUILD} ; fi
  if [ ! -d \${G4WORKDIR}    ]; then mkdir -p \${G4WORKDIR}    ; fi
  cd \${G4CMAKEBUILD}
  make
}

EOF

source ${MYG4TOP}/${G4_SETUP_SCRIPT}

# end-of-script
