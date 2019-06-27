# AutoDMG Cache Builder
----

Use [AutoDMG](https://github.com/MagerValp/AutoDMG) to build an image that includes [Munki](https://github.com/munki/munki) installs preloaded in.

The image will try to include:

* All available `managed_installs` in the provided manifest and catalogs.  
	* Items that cannot be safely installed at image time will be preloaded into the Munki cache folder (`/Library/Managed Installs/Cache`).  
* All available Munki icons.  
* Munki client customization resources.  
* Anything provided by the Org-Specific Code.

## Requirements:
----
* [AutoDMG](https://github.com/MagerValp/AutoDMG) must be installed.
* [Munki](https://github.com/munki/munki) must be installed and configured to check in to a repo.  This script will read the machine's Munki preferences to fetch Munki items.
* An OS X Installer from the App Store, present in `/Applications`. By default, it looks for `/Applications/Install OS X El Capitan.app`.
* To be safe, at least 20 GB of free disk space.
* AutoDMG Cache Builder requires administrative privileges.

## Basic Usage:
----
Since AutoDMG Cache Builder requires administrative privileges, these commands will need to be run with `sudo`, or run as root.

Most basic usage:  
`autodmg_cache_build.py`

To automatically move the built image to a [DeployStudio](https://www.deploystudio.com) repo:  
`autodmg_cache_build.py  --dsrepo /Users/Shared/Deploystudio`

To automatically move the built image to another arbitrary location (such as your root for Imagr):
`autodmg_cache_build.py  --movefile /Users/Shared/ImagrRepo

To use an Extras file (see below):  
`autodmg_cache_build.py  
  --extras except_adds.json  
  --dsrepo /Users/Shared/Deploystudio`

Use the help to see the full list of command line arguments:  
`autodmg_cache_build.py -h`


## What It Does
----

1. Query the Munki preferences for the repo and manifest.
2. Build the local cache directory and paths (`/Library/AutoDMG/`).
3. Download all `managed_installs` listed in the manifest belonging to the specified catalogs (use `-c` or `--catalog` to specify a different one) into the local cache directory.  The "Safe" vs. "Unsafe" rules are used, see below.
4. If an Extras file is provided, download any additional items into the local cache directory.
5. Download & package all the Munki icons.
6. Download & package the Munki client customization resources.
7. Run the "Org-Specific Code" to allow building custom packages to be included.
8. Build an AutoDMG template file containing all of the packages.
9. Trigger an AutoDMG "download" of Apple software updates according to the UpdateProfiles.plist if `--disableupdates` is not used.
10. Begin the AutoDMG build. Build log is stored in `/Library/AutoDMG/logs/build.log`.
11. If a DeployStudio repo is provided, automatically copy the image into the DeployStudio repo's `Masters/HFS` directory.
12. If another target location is provided, automatically copy the image into this directory.

### "Safe" vs. "Unsafe" Items
"Safe" items are:

* Standard .pkg files
* CopyFromDMG items that copy directly into /Applications

"Unsafe" items:

* Any item with a `preinstall_script`, `postinstall_script`, or `installcheck_script` is automatically considered "unsafe", since we cannot safely execute those scripts on the intended target when installing to a disk image.
* If an Extras file is provided and lists any Exceptions, those are automatically moved into the Exceptions list even if they would otherwise be considered "Safe".

Items that are considered "unsafe" are downloaded into the Exceptions folder. Exceptions are packaged up and installed into in the Munki cache folder directly so that Munki bootstrapping will not need to download them.

## Extras - Additions & Exceptions
----
A JSON file containing a list of additional items and exceptions to the "Safe" rule can be provided. This is called the Extras file.

#### Additions
The `additions` array will be added directly to the AutoDMG template and built into the image.  These can either be URLs, which will be cached locally, or local file paths.

For example, you may wish to include items from your Munki repo that are `optional_installs` to be preloaded into the image.

No checking or verification is done for these packages. AutoDMG will attempt to incorporate them at build time, so if they move are or otherwise unavailable in between the template being constructed and AutoDMG trying to access them, you'll get a build failure that will be fun to track down.

#### Exceptions

As part of the "Safe" vs. "Unsafe" rules, you can also include an `exceptions` array in the Extras file.  These should be Munki item names that you do not want to install at image time.  

If the `name` key of an item from the catalog matches an Exception, it will still be downloaded and cached locally, but will be placed into the Munki cache folder on the image.  When Munki runs, it will automatically decide what to do with the contents of its cache folder.

There are many reasons you may want to list an item as an exception. Most of those are described on the [AutoDMG Wiki page about suitable packages](https://github.com/MagerValp/AutoDMG/wiki/Packages-Suitable-for-Deployment). Generally, if the package runs any kind of postflight script, you should very carefully read it to make sure it will run on the _target disk_ properly and not on the AutoDMG host computer. Since most package postflight scripts are built with the assumption that they will only be executed by a logged in user, please carefully curate your Munki items to make sure that only safe package payloads are being incorporated into your images.

This will likely require some trial-and-error, and some admin consideration.

#### Example file

```
{
  "additions_list": [
    # These get downloaded & added directly to the AutoDMG template
    "https://munki/munki_repo/pkgs/apps/microsoft/office2016/Microsoft_Office_2016_15.22.0_160506_Installer-15.22.0.pkg",
    "https://munki/munki_repo/pkgs/profiles/Office2016-SuppressFirstRun-1.2.mobileconfig"
  ],
  "exceptions_list": [
    # These are Munki items that should be installed by Munki bootstrapping
    "BomgarClient",
    "MicrosoftOffice2016_Serializer"
  ]
}
```

Your Extras file must be valid JSON. Use a JSON linter to validate it.

## Org-Specific Code
----
If you are familiar with Python, you can add any custom code to be run into the `autodmg_org` file.  

During the normal script run, it automatically calls `autodmg_org.run_unique_code(args)`.  Anything inside that function will be run, and the entire argument object will be passed along to it. `run_unique_code()` should always return a list of packages you want added to the AutoDMG template.

The module also has access to the utility functions:

* `pkgbuild` and `build_pkg`, which offer varying levels of specificity around the construction of packages
* `run`, which is a convenience function that runs a subprocess and provides real-time output to stdout
* `populate_ds_repo`, which can be given an image path and will move it into the proper DeployStudio repo folder

#### Simple package building
A use case for the Org-Specific code is to build a package of your own unique contents and include it in the image.  The `PKG_LIST` global is a list of dictionaries of the pieces necessary to build a package of contents that lives on the AutoDMG host machine.

The `PKG_LIST` global is a list of dictionaries containing these keys:

* `pkg_name` is the name of the file (with ".pkg" as a suffix automatically appended).  
* `source` is the directory that contains the contents you wish to package up. The resulting package will recreate the *same directory paths* in the Payload.  
* `receipt` is the identifier for the package, and will be used as the receipt.  
* `comment` is what will print to stdout when this package is built by the code.

For example, let's say you have a folder full of desktop background images that you want to include in the image. These wallpapers are stored on the host machine in `/Users/Shared/Wallpapers`.  You can simply specify a dictionary like this to build it:

```
  {
    'pkg_name': 'wallpapers',
    'source': '/Users/Shared/Wallpapers',
    'receipt': 'com.facebook.wallpapers',
    'comment': 'Building Wallpapers package'
  },
```

If you populate the `PKG_LIST` global, you can invoke it like this:

```
  for package in PKG_LIST:
    pkg_list.append(
      build_pkg(
        package['source'],
        package['pkg_name'],
        package['receipt'],
        package.get('target', package['source']),
        DESTINATION,
        package['comment']
      )
    )
```

This will result in the package being built and added to the AutoDMG template.

#### Custom packages & code
You're not limited to just the simple package building. You can execute any code you want, just add it to the main `run_unique_code()` function.

You may want to build a custom package here, and include it in the image.  For example, you may want to include a package that suppresses the Apple Setup Assistant.

The sample code included in the `autodmg_org` module includes this:

```
def suppress_registration(cache_path):
  """Build a package to suppress Setup Assistant, returns path to it."""
  pkg_output_file = os.path.join(cache_path, 'suppress_registration.pkg')
  if not os.path.isfile(pkg_output_file):
    print "Building registration suppression package..."
    temp_dir = tempfile.mkdtemp(prefix='suppressreg', dir='/tmp')
    receipt = os.path.join(temp_dir, 'Library/Receipts')
    os.makedirs(receipt)
    open(os.path.join(receipt, '.SetupRegComplete'), 'a').close()
    vardb = os.path.join(temp_dir, 'private/var/db/')
    os.makedirs(vardb)
    open(os.path.join(vardb, '.AppleSetupDone'), 'a').close()
    pkgbuild(
      temp_dir,
      'com.facebook.cpe.suppress_registration',
      '1.0',
      pkg_output_file
    )
    shutil.rmtree(temp_dir, ignore_errors=True)
    if os.path.isfile(pkg_output_file):
      return pkg_output_file
    # If we failed for some reason, return None
    return None
  # Package already exists
  return pkg_output_file
```

With that function defined, you'll want to call it in the main `run_unique_code()` function, and pass in the argument containing the local cache directory:

```
  registration_pkg = suppress_registration(args.cache)
  if registration_pkg:
    pkg_list.append(registration_pkg)
```
The package will be built and added to the AutoDMG template on each run. It's up to you to decide if you want the code to be idempotent, or to rebuild each time. Regardless, you should always make the habit of verifying the package file actually exists on disk before adding it to the template.

There is lots of example code in the `autodmg_org` file, so start there.

## Caveats & Considerations
----

#### The Host With The Most
This script relies upon the Munki settings of the computer it is running on. It gets information about the repo from the Munki preferences. It invokes Munki code living on the host.

There is currently no supported way to run this against a **different** Munki repo. There are some experiments being done in the `admg_dev` branch of this Github repo if you're interested in trying the out, but there's no documentation or support of it, and I don't really intend to put a lot of work into that feature.

Because this script is running on the host, it may also trigger downloads of updates into the local Munki cache of the host.  This should never be destructive (and never does a full Munki run), but please bear in my mind that this is not sandboxed in any way.

#### AutoDMG's Safe Packages Rules
As described above, AutoDMG will run `installer` on each package in its template. If it is given a package with a postinstall script, that script will be executed *on the host computer*. If the postinstall script is not well-crafted or safe for this, keep in mind that you may be executing scripts on your host machine that do things you don't expect.

That could either lead to the image having an incomplete install (because the postinstall script for the package never ran on the image), or it could lead to unexpected behavior on the host machine (because you ran a postinstall script on it without the Payload being installed).

For example, installing the Microsoft Office 2016 Serializer package will *not* license the image. That package generates a proper license file by running an executable that gathers data about the client. Trying to install this package in AutoDMG will license the *host* machine, not the image.  That's why this is placed in the "Exceptions" list in the example above.

Packages that you are unsure about or are certain that they cannot be executed safely on a target image should always go in the "Exceptions" list, by adding them to the JSON file.

#### Munki Scripts Ain't Happenin'
The script downloads items from Munki, but does not use Munki to execute any installs. That's why all items with scripts (except uninstall scripts) are automatically considered unsafe. If you need specific behavior to take place based on scripting, it's safer to add the items to the "Exceptions" list.

#### Consider Using A Dedicated Manifest
By the same token, this script runs the "get list of managed installs" by looking at the `managed_installs` key of the provided manifest.  That means any conditional items are automatically ignored, because we can't safely process them.  *Only* items listed as `managed_installs` with no conditions are processed.

Depending on your `conditional_items` setup, this may mean that the Munki bootstrap run could involve downloading and installing things, which this script is ultimately trying to optimize.  Since there's no way to parse these conditions ahead of time, you may wish to consider creating an **additional manifest** solely to be used for this script.

A manifest made only of items that can be safely installed into an image would be a simple way of managing the use of this script.
