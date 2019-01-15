Pantri
=====

Pantri is an wrapper script to manage package repos hosted in OpenStack Object Storage ("Swift") via source control(git).


Requirements
---
* Git repo
* Swift Object Store
*Third Modules installed in scripts/external_deps
  * dirsync>=2.2.2
  * GitPython>=2.0.5
  * python-swiftclient>=3.0.0

Config
---
Default settings are in scripts/lib/config.py. Most values can be applied via
CLI.


Terminology
---
Store = Upload
Retrieve = Download or sync
Shelf = Shelf is a package repo or team directory underneath "shelves".

Usage
---
Pantri has two functions:
**Store (upload)**
```
$ ./pantri.py store --help
usage: pantri.py store [-h] [objects [objects ...]]

positional arguments:
  objects     list of files or directories to store(upload)

optional arguments:
  -h, --help  show this help message and exit
 ```

 **Retrieve (download or sync):**
 ```
 $ ./pantri.py retrieve  --help
usage: pantri.py retrieve [-h] [-s SHELF] [-f] [-d DEST_SYNC]

optional arguments:
  -h, --help            show this help message and exit
  -s [SHELF [SHELF ...]], --shelf [SHELF [SHELF ...]]
                        Shelf(s) to retrieve
  -f, --force           Force syncing if repo is up-to-date
  -j, --json_output     Write status of updated objects to
                        scripts/{shelf}_updated_objects.json
  -d DEST_SYNC, --dest_sync DEST_SYNC
                        Location to sync files
  -i PITEM, --pitem PITEM
                        Use to reterirve one item
  -p, --password_file   Use password file for auth
  ```
### Installation
Pantri is dependent *python-swiftclient* to sync files to the object store.  Install all required modules listed in scripts/requirements.txt into scripts/external_deps


