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
