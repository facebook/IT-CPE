# CPE tools
The CPE ("Client Platform Engineering") repo contains a suite of
[Chef](https://www.chef.io/) cookbooks used to manage Facebook's client fleet.

We aim for compatibility with the latest public releases of the operating
systems we manage.

## Presentations
* Watch our [presentation at MacIT](http://www.youtube.com/watch?v=Z3gMXUxI0Hs)
* Watch our [presentation at MacADUK](https://www.youtube.com/watch?v=VIzgMavUFRQ)

## Join the CPE community
* [Facebook IT Website](https://fb.com/it)
* [Facebook group] (https://fb.com/groups/TheITThinkTank)

## License
Old IT-CPE tools are BSD-licensed with an additional patent grant; see `LICENSE`
and `PATENTS`.

New Chef cookbooks in the `itchef` directory are under the Apache 2.0 license.

# Old "chef" vs. New "itchef" folder

We are working on improving the way our Chef cookbooks get published on GitHub,
and the way we review and merge pull requests.

Cookbooks that are currently in `chef/cookbooks` will gradually be replaced by
those in `itchef/cookbooks` as they get reviewed and refactored.

*We will not consider any issues or PRs against anything in the "chef" folder - it's
purely for legacy only until we migrate everything over.*
