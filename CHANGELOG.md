## v.1.1.4 (May 14, 2016)

[onmiauth-orcid 1.1.4](https://github.com/datacite/omniauth-orcid/releases/tag/v.1.1.4) was released on May 14, 2016 with the following changes:

* default scope depends on member status, `/authenticate` for non-members and `/orcid-profile/read-limited /orcid-works/create /orcid-bio/external-identifiers/create /affiliations/create /funding/create` for members

* added `/orcid-bio/external-identifiers/create /affiliations/create /funding/create` to the default scope

## v.1.0 (July 25, 2015)

[onmiauth-orcid 1.0](https://github.com/datacite/omniauth-orcid/releases/tag/v.1.0) was released on July 25, 2015 with the following changes:

* changed default scope to `authenticate`, and use the public API `https://pub.orcid.org` by default. These settings work for non-members.
* added `name` and `email` to the `info` hash returned by omniauth (`email` will be empty in almost all cases)
* cleaned up documentation in `README.md`
