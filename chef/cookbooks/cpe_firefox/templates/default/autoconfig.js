// The first line must be a comment: https://developer.mozilla.org/en-US/Firefox/Enterprise_deployment_before_60
pref("general.config.filename", "<%= node['cpe_firefox']['cfg_file_name'] %>");
pref("general.config.obscure_value", 0);
