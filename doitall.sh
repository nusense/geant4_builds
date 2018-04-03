#! /usr/bin/env bash

HERE=`pwd`

build_types="gmake cmake"
if [ -n "$1" ]; then build_types="$1" ; fi

#lib_types="shared static"
#lib_types="static"
lib_types="shared"
if [ -n "$2" ]; then lib_types="$2" ; fi

unset  TESTING
unset  VERBOSE
unset  CPPVERBOSE
case $3 in
  verb* )
    export VERBOSE=1
    export CPPVERBOSE=1
    ;;
  test* )
    export TESTING=1
    ;;
  * )
    export XYZZY=1
    ;;
esac

function now() {
  date "+%Y-%m-%d %H:%M:%S"
}

function build_gmake() {
  cd $HERE
  source setup_for_gmake.sh ${LTYPE}
  echo "begin ${LTYPE} source `now`"
  cd $G4INSTALL/source
  make all > ${G4WORKDIR}/make_all_${LTYPE}.log 2>&1

  echo "begin gmake ${LTYPE} tests `now`"
  cd ${G4WORKDIR}
  echo "make gmake copy tests `now`"
  rsync --exclude='.svn/' -a ${G4INSTALL}/tests ${G4WORKDIR}
  echo "done gmake copy tests `now`"
  cd tests
  make examples_links_source
  make all > make_tests_${LTYPE}.log 2>&1
  make examples_links_binaries

  echo "begin gmake ${LTYPE} examples `now`"
  cd ${G4WORKDIR}
  echo "make gmake copy examples `now`"
  rsync --exclude='.svn/' -a ${G4INSTALL}/examples ${G4WORKDIR}
  echo "done gmake copy examples `now`"

  cd examples
  EXAMPLETOP=`pwd`
  cd ${EXAMPLETOP}/extended/physicslists/factory
  make setup
  cd ${EXAMPLETOP}/extended/physicslists/extensibleFactory
  make setup
  cd ${EXAMPLETOP}/extended/physicslists/genericPL
  make setup

  cd ${EXAMPLETOP}
  make all > make_examples_${LTYPE}.log 2>&1


  # setup_for_gmake should have added to PATH & LD_LIBRARY_PATH
  echo "run gmake examples `now`"

  RUNLOG=${EXAMPLETOP}/run_examples_${LTYPE}.log
  if [ -f ${RUNLOG} ]; then rm ${RUNLOG} ; fi

  echo "=======================================" >> ${RUNLOG}
  g4plfactory_test38 --old >> ${RUNLOG} 2>&1
  echo "=======================================" >> ${RUNLOG}
  # will fail if OLDFLG="--old" because old can't create MyPL*
  g4plfactory_test38 -f -F -c -r --defaults --env "QGSP_BERT" ${OLDFLG} QGSP_BERT_EMX MyPL1 MyPL2 myns::MyNSPL3 myns::MyNSPL4 NuBeam >> ${RUNLOG} 2>&1

  cd ${EXAMPLETOP}/extended/physicslists/factory
  echo "=======================================" >> ${RUNLOG}
  factory   -m run.mac >> ${RUNLOG} 2>&1

  cd ${EXAMPLETOP}/extended/physicslists/genericPL
  echo "=======================================" >> ${RUNLOG}
  genericPL -m run.mac >> ${RUNLOG} 2>&1

  cd ${EXAMPLETOP}/extended/physicslists/extensibleFactory
  echo "=======================================" >> ${RUNLOG}
  extensibleFactory -m run.mac >> ${RUNLOG} 2>&1
  echo "=======================================" >> ${RUNLOG}
  extensibleFactory -m run.mac -p MySpecialPhysList+G4OpticalPhysics+RADIO >> ${RUNLOG} 2>&1
  echo "=======================================" >> ${RUNLOG}

  cd ${EXAMPLETOP}

  echo "done gmake ${LTYPE} `now`"

  unsetup_all
  unsetup ups
  unset PRODUCTS
}

function build_cmake() {
  cd $HERE
  source setup_for_cmake.sh ${LTYPE}

  echo "begin cmake ${LTYPE} cmake-phase `now`"
  g4_cmake > g4_cmake_${LTYPE}.log 2>&1

  # avoid this tedious download
  TEST65_DATA=${G4WORKDIR}/cmake_build/tests/test65/Data
  if [ -L ${TEST65_DATA} ]; then rm    ${TEST65_DATA} ; fi
  if [ -d ${TEST65_DATA} ]; then rm -r ${TEST65_DATA} ; fi
  ln -s ${GEANT4_INSTALL_DATADIR}/test65_Data ${TEST65_DATA}

  echo "begin cmake ${LTYPE} build `now`"
  g4_build > g4_build_${LTYPE}.log 2>&1

  echo "begin ${LTYPE} cmake install `now`"
  make install > g4_install_${LTYPE}.log 2>&1
  if [ !  -d $G4WORKDIR/share/Geant4-10.4.0 ]; then
    mkdir -p $G4WORKDIR/share/Geant4-10.4.0
  fi
  ln -sf /geant4/app/rhatcher/gmake_testing/data $G4WORKDIR/share/Geant4-10.4.0/data
  echo "done cmake ${LTYPE} `now`"

  cd $G4CMAKEBUILD
  # ctest -C RelWithDebInfo -V -R test38
  # ctest -R test38
  # ctest
  echo "start spinoff of cmake ${LTYPE} ctest `now` in `pwd`"
  nohup ctest > ctest_${LTYPE}.log 2>&1 < /dev/null &

  unsetup_all
  unsetup ups
  unset PRODUCTS
}

export LTYPE
export BTYPE
for BTYPE in ${build_types} ; do
  for LTYPE in ${lib_types} ; do
    cd $HERE
    if [[ "$LTYPE" != "shared" && "$LTYPE" != "static" ]]; then
      echo -e "${OUTRED}don't know about libtype '$LTYPE'${OUTNOCOL}"
      continue
    fi
    case $BTYPE in
      cmake ) if [ -z "${TESTING}" ]; then
                echo -e "${OUTGREEN}build_cmake '$LTYPE'${OUTNOCOL}"
                build_cmake ${LTYPE}
              else
                echo -e "${OUTGREEN}TESTING would build_cmake '$LTYPE'${OUTNOCOL}"
              fi
              ;;
      gmake ) if [ -z "${TESTING}" ]; then
                echo -e "${OUTGREEN}build_gmake '$LTYPE'${OUTNOCOL}"
                build_gmake ${LTYPE}
              else
                echo -e "${OUTGREEN}TESTING would build_gmake '$LTYPE'${OUTNOCOL}"
              fi
              ;;
      * )
        echo -e "${OUTRED}don't know about buildtype '$BTYPE'${OUTNOCOL}"
    esac
  done
done


