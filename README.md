# geant4_builds

## Purpose
These are some scripts to encapsulate the configuration and building of Geant4 under various scenarios.   Builds using `gmake` split the resulting libraries at a more "granular" level than those using `cmake` (so called "global" libraries).  Builds can either create shared object libraries, or "static" link libraries.

The `doitall.sh` script, by default, builds all four variants. For the `cmake` cases it launches `ctest` to exercise various tests and examples.  For the `gmake` case there are a few chosen examples/test built and run by hand.


## To-Do
* The script contains a few hard-coded version strings ... it shouldn't
* This script relies on too many FNAL specific things
