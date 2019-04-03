# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_autopkg
# Attributes:: default
#
# Copyright 2016, Nick McSpadden
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# By default, we use the 'autopkg' user. This can be overridden
# to be your own user account instead.
default['cpe_autopkg'] = {
  'install' => nil,
  'setup' => nil,
  'update' => nil,
  'user' => 'autopkg',
  'dir' => {
    'home' => '/Users/autopkg/Library/AutoPkg',
    'cache' => '/Users/autopkg/Library/AutoPkg/Cache',
    'recipeoverrides' => '/Users/autopkg/Library/AutoPkg/RecipeOverrides',
    'recipes' => '/Users/autopkg/Library/AutoPkg/Recipes',
    'reciperepos' => '/Users/autopkg/Library/AutoPkg/RecipeRepos',
  },
  # These can be anything that 'autopkg repo-add' accepts.
  # Either a convenience name for the AutoPkg org,
  # or a git address.
  'repos' => [
    'recipes',
  ],
  'munki_repo' => '/Users/Shared/munki_repo',
  'run_list_file' => '/Library/CPE/var/autopkg_run_list.json',
  'run_list' => [],
}
