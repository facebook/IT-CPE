Description
==================
Configures a machine to be a an imaging server

Usage
-----
Ensure the machine has the /Library/CPE/tags/is_imaging_server
and include `cpe_imaging_servers` in your node's `run_list`:

```json
{
  if node.is_imaging_server
    scope += ["Imaging server"]
    run_list += ["cpe_imaging_servers"]
  end
}
```
