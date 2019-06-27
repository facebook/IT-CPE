AutoPkg Runner
=====

This is an [AutoPkg](https://github.com/autopkg/autopkg/) wrapper script creates a separate git feature branch and puts up a commit for each item that is imported into a git-managed Munki repo.


Requirements
---
* Your Munki repo must be within a git repo. 
* AutoPkg must be installed and executable by the user account running the AutoPkg script.
* The user account that is running the AutoPkg script must have read/write permissions to the Munki repo.
* This script assumes that you have a working AutoPkg installation with all the recipes you intend to run in the RECIPE_SEARCH_DIRS.  
* You will need to write your own notification code in the `create_task()` function to send an email, file a task/ticket, or generate some notification. This script will still work as is, but obviously won't generate any notifications unless that function is populated.


Usage
---
autopkg_tools.py can be used to run a single AutoPkg recipe, a list of recipe passed in as arguments, or a list of recipes from a file in JSON or plist format.

These recipes will be run in sequence, *not as a group*, and MakeCatalogs.munki will *not* be run.

For each run, the following steps will happen:  

Each recipe will be run in sequence. For each recipe:
  1. Create a feature branch in the git repo
	2. Run the recipe and store the output as a plist.
	3. Parse the report plist for results.
	4. If the recipe failed, file a task/ticket.
  5. If the recipe succeeded, run the binary middleware functionality.
	6. Git commit the changes (anything considered dirty by your .gitignore rules, which is typically just the pkginfo).
	7. Rename the branch to match the item name and version.
	8. File a task/ticket indicating recipe succeeded and imported something.
	9. Switch back to the master branch.

Single recipe:

    autopkg_tools.py -r Firefox.munki

Single recipe with pre-downloaded package:

    autopkg_tools.py -r Firefox.munki -p Firefox.dmg

Multiple recipes:

    autopkg_tools.py -r Firefox.munki GoogleChrome.munki

Multiple recipes stored in a file:

    autopkg_tools.py -l MyRecipeList.plist

All of the command line arguments can also be stored as preferences in the `com.facebook.CPE.autopkg` preference domain.

    defaults write com.facebook.CPE.autopkg RunList -array Firefox.munki GoogleChrome.munki

Preferences that are used:

* RunList (equivalent to a `-l` argument)
* GitRepo (by default this is AutoPkg's MUNKI_REPO preference, equivalent to `-g`)
* DebugMode (equivalent to `-v`)
* UseArcanist (equivalent to `--arc`)
