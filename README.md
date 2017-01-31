# gitlab_freebsd

This Cookbook installs a standalone GitLab including postgresql on a FreeBSD Server

**WARNING: This is currently a pretty basic version. It will get cleaned up and refined in the next versions. So please treat
it as software in alpha stage**

**INFO:** If you install Gitlab in a Jail, please make sure that sysvipc is actiated in order for postgresql to work!

## Supported

 - FreeBSD >=10.3
 
## TODOs

 - Refinements
 - Specs
 - Inspec
 - Documentation
 - Make Postgresql server optional
 - Add possibility to set/change root password during converge run
 - what about updating?

## License and Authors

Author: Stefan Wendler (<stefan@binarysun.de>)
License: Apache License, Version 2.0 (January 2004 - http://www.apache.org/licenses/)
