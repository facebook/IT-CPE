AutoPkg Runner
=====

This is an [AutoPkg](https://github.com/autopkg/autopkg/) wrapper script creates a separate git feature branch and puts up a commit for each item that is imported into a git-managed Munki repo.

Additionally, the idea behind this recipe is to sequester the execution of recipes into a controlled enviroment. In the environment for which this was written, the user account running AutoPkg only has a single RECIPE_SEARCH_DIR, which is a folder also located in a git repo (which allows us to control exactly what the recipes look like at time of execution). 

All recipes will be rsynced from their original source repos (specified by the preference RECIPE_REPO_DIR) into the RECIPE_SEARCH_DIR (see the Requirements below for details). This behavior can be commented out if you want to use the RECIPE_SEARCH_DIR preference key as in normal operation.

Requirements
---
* Your Munki repo must be within a git repo. 
* AutoPkg must be installed and executable by the user account running the AutoPkg script.
* The user account that is running the AutoPkg script must have read/write permissions to the Munki repo.
* This script assumes that RECIPE_SEARCH_DIR only has two entries: 
	* .
	* A path that you will execute recipes from (such as `/Users/autopkg/recipe_path`).  
* You will need to write your own notification code in the `create_task()` function to send an email, file a task/ticket, or generate some notification. This script will still work as is, but obviously won't generate any notifications unless that function is populated.
* The report plist path will be stored as "autopkg.plist" in the directory specified by RECIPE_REPO_DIR, so that directory must be writable by the user account running the AutoPkg script.

Usage
---
First, you'll need to populate the list of recipes on Line 33:  

```
  recipes = [
    'AdobeFlashPlayer.munki',
    'Firefox.munki',
    'GoogleChrome.munki',
    'OracleJava8JDK.munki',
  ]
```
These recipes will be run in sequence, *not as a group*, and MakeCatalogs.munki will be run after *each* recipe.

For each run, the following steps will happen:  

1. A list of all parent recipes necessary for execution of the recipe list will be generated.
2. All of those parent recipes will be rsynced over to the RECIPE_SEARCH_DIR as specified above (*specifically, it will rsync all the recipes into the second entry of the RECIPE_SEARCH_DIR array*).  
3. Each recipe will be run in sequence, with MakeCatalogs.munki. For each recipe:
	1. Run the recipe with MakeCatalogs.munki and store the output as a plist.
	2. Parse the report plist for results.
	3. If an item was imported, create a feature branch (switch to master first, create the feature branch).
	4. Git commit the changes (the package, the pkginfo, and the catalog changes).
	5. Switch back to master branch.
	6. Create a summary description and call `create_task()`.
	7. For any recipe that failed, create a summary description and call `create_task()`.
	
Known Issues
----
The rsync command does not use the --delete option, which means that if a file is later deleted out of a recipe repo, it won't be deleted out of your local RECIPE_SEARCH_DIR. Some manual pruning may be necessary.