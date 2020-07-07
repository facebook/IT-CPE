cpe_profiles Cookbook
=====================

This cookbook facilitates using other cookbooks to manage macOS profiles in a
"modular" way. This cookbook reads profile Hashes from its node attributes
and then re-writes them back out to the node attributes of another cookbook with
an identical API. It will also rewrite the profile identifiers of those
profiles to be that of the "destination" API cookbook. See Usage section for
examples.

Attributes
----------
* node['cpe_profiles']
* node['cpe_profiles']['prefix']
* node['cpe_profiles']['default_cookbook']
* node['cpe_profiles']['cookbook_map']

Usage
-----

To add a new config profile, in your recipe, add a key matching the
profile `PayloadIdentifier` with a value that contains the hash of the profile
to `node.default['cpe_profiles']`:

```
# assume "profile" contains a fully-fleshed out profile with all requisite keys
prefix = node['cpe_profiles']['prefix']
profile = {
  # other keys in the profile here
  'ProfileIdentifier' => "#{prefix}.myprofile",
  # more keys
}
node.default['cpe_profiles]["#{prefix}.myprofile"] = profile
```

This cookbook's `default_cookbook` attribute is, by default, set to
`cpe_profiles_local`. This means that in the above example this cookbook
will re-write the above profile into the `cpe_profiles_local` cookbook's node
attribute *as if* you had specified it like this:

```
prefix = node['cpe_profiles_local']['prefix']
profile = {
  # other keys in the profile here
  'ProfileIdentifier' => "#{prefix}.myprofile",
  # more keys
}
node.default['cpe_profiles_local]["#{prefix}.myprofile"] = profile
```

This allows us to, at run-time, swap out the value of `default_cookbook` to
target another *different* cookbook that implements the same API but, say,
installs profiles completely differently. Say, via MDM for example. This also
means this cookbook should be run first before `cpe_profiles_local` in your
run list (and before any other cookbook you're intending to use).

Note that the default `prefix` attribute is a *dummy* value that will
be dynamically replaced by the desitnation cookbook's prefix using a simple
string substitution in both the top-level profile Hash key and the
`ProfileIdentifier` key in the contained profile Hash.

The `cookbook_map` attribute allows us to target specific profile identifiers
to be mapped to a different cookbook than the `default_cookbook` attribute.
This allows a migration path to move specific profiles one-at-a-time rather than
all at once with a single switchover via `default_cookbook`. Use it like this:

```
prefix = node['cpe_profiles']['prefix']
node.deafult['cpe_profiles']['cookbook_map']["#{prefix}.myprofile"] = 'mdm_profiles'
```

This would map `"#{prefix}.myprofile"` to use the `mdm_profiles` cookbook, for
exmaple instead of being re-written to use the `default_cookbook`.
