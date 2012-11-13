# activerecord_chronological_records [![Build Status](https://secure.travis-ci.org/tmikoss/activerecord_chronological_records.png)](http://travis-ci.org/tmikoss/activerecord_chronological_records)

Provides a set of helper methods for dealing with chronological records that have common primary key and date columns denoting when the record is active (example: Oracle EBS tables).

## Usage

### Invocation

To add the helper methods, invoke `has_chronological_records` method on your ActiveRecord model:

    class Employee < ActiveRecord::Base
      has_chronological_records
    end

This will assume you have `start_date` and `end_date` columns on the model. To change the column names, pass them as arguments:

    class Employee < ActiveRecord::Base
      has_chronological_records :start_date, :end_date
    end

### Class methods

Following scopes are defined at class level that return all records matching specific condition:

* `Class.current` - records valid at current date
* `Class.effective_at(date)` - records valid at given date

### Instance methods

Following instance methods are defined for navigation between versions or record. Can return nil if no version matches the condition.

* `instance.current` - version of instance valid at current date
* `instance.effective_at(date)` - version of instance valid at given date
* `instance.earliest` - first version of record
* `instance.latest` - last version of record
* `instance.previous` - version before the one method is being called on
* `instance.next` - version after the one method is being called on

Additonally, following helper methods are available:

* `instance.current?` - checks whether instance is valid at current date

## Installation

Add the following line to your `Gemfile`

    gem 'activerecord_chronological_records'

and run the `bundle install` command.

## Contributing to activerecord_chronological_records

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Toms Mikoss. See LICENSE.txt for
further details.

