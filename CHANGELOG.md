## v.1.0 (July 25, 2015)

[onmiauth-orcid 1.0](https://github.com/lagotto/lagotto/releases/tag/v.1.0) was released on July 25, 2015 with the following changes:

* changed default scope to `authenticate`, and use the public API `https://pub.orcid.org` by default. These settings work for non-members.
* added `name` and `email` to the `info` hash returned by omniauth (`email` will be empty in almost all cases)
* cleaned up documentation in `README.md`
