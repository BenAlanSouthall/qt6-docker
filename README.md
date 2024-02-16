# Qt 6 docker containers for CI
### Modified for building for older distributions

This fork modifies the [upstream repository]( https://github.com/state-of-the-art/qt6-docker ) to provide for building AppImages that will run on older linux distros.

Specifically, it uses glibc2.28, needed by RHEL 8.x series.

Only the Qt 6.3 QCC recipe was changed.

Bionic beaver is used; whilst this does not use GCC 2.28, we include steps manually to downgrade to an older version, downloaded straight from the repositories, and then upgrade again when we need to use apt. This breaks the package manager, but in order to target a release on a GLIBc this far back ,there aren't many pretty solutions.


