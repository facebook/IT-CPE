# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

ChefSpec.define_matcher :cpe_choco_bootstrap
ChefSpec.define_matcher :cpe_choco_configure
ChefSpec.define_matcher :cpe_choco_apps

if defined?(ChefSpec)
  def bootstrap_cpe_choco(name)
    ChefSpec::Matchers::ResourceMatcher.
      new(:cpe_choco_bootstrap, :install, name)
  end

  def configure_cpe_choco(name)
    ChefSpec::Matchers::ResourceMatcher.
      new(:cpe_choco_configure, :change, name)
  end

  def manage_cpe_choco_apps(name)
    ChefSpec::Matchers::ResourceMatcher.
      new(:cpe_choco_apps, :change, name)
  end
end
