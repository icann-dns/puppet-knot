### 2017-09-26 0.3.4
* update `get_exported_titles` so it returns a sorted array

### 2017-09-26 0.3.3
* Fix version string in knot 2.x.  if hide\_version is set to false then version.server queries will recive the string hidden.  in future version we should extend this with the abbility to pass a string

### 2017-09-26 0.3.2
* use correct knotc arguments

### 2017-09-26 0.3.1
* use apt::pin to pin knot1 if force\_knot is used

### 2017-09-22 0.3.0
* add support for knot 2.x. 

### 2017-08-16 0.2.8
* change the name of the remote acl to allow localhost acls in other parts of knot

### 2017-08-16 0.2.7
* Add restart command to check config before restarting
* Remove rouge comma
* updated spec tests
* added gitlab-ci tests 

### 2017-07-27 0.2.6
* Remove a sparse comma

### 2017-07-27 0.2.5
* Add acceptance tests to check notifies are working

### 2017-07-26 0.2.4
* Change how we handle exported resources so they are all added/removed in one run

### 2017-04-26 0.2.3
* FIX: never use TSIG for notifies.  this was the default in previosu versions.  in future versions we will make tsig configueration more flexible

### 2017-04-26 0.2.2
* FIX: missing notify in statments

### 2017-04-10 0.2.1
* Fix a few typos
* Add NOKEY support

### 2017-04-06 0.2.0
* Complete rewrite of the zones hash.
* depricated the old $tsig hash now all hashs have to be defined in $tsisg and then refrenced by name in the remotes
* added new nsd::remotes define.  allows you to define data about remote servers and then refrence them by name where ever a zone paramter would require a server e.g. masters, provide_xfrs, notifis etc
* added default_tsig_name.  this specifies which nsd::tsig should be used by default
* added default_masters.  this specifies an array of nsd::remote to use by default
* added default_provide_xfrs.  this specifies an array of nsd::remote to use by default

### 2016-08-08 0.1.3
* fix variable scope for future parser

### 2016-05-06 0.1.2
* Fix refrence to nsd::tsig which should have been knot::tsig
* Fix refrence to nsd::file which should have been knot::file
* add support for slave addresses
* refactor config names and update rspec test

### 2016-05-06 0.1.1
* Add support for exporting nagis check

### 2016-05-06 0.1.0
* Initial Release
