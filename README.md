# stuff_arc - supports Rails portable data dump and restore

stuff_arc adds class level archiving and unarchiving of an ActiveRecord object
a Rails app.

Archives are JSON data, one line per model instance with the 'id' value omitted so that
the data can be restored w/o worrying about primary key clashes.

Restoration is performed by instantiating the model and then calling save!. **save!** exceptions
are trapped and generate simple error messages, thus Rails validations can be used to avoid
data duplication and data clobbering.

These methods are designed to be used in a Rails Console, not programatically.

## Install

    gem install stuff_arc

## Usage

Include into models in which you want to create archives.

    app/models/foo.rb:
    
    require 'stuff_arc'

    class Foo < ActiveRecord::Base
      include StuffArc
      
      . . .
    end

This will add two class methods to Foo:

* Foo.archive - which will create the file 'foo.json' containing JSON serializations
of every record retrieved by Foo.all with the 'id' entry is excluded.
* Foo.unarchive - which reads the file 'foo.json', decodes each record and attempts
to save! them to the database.

This creates a portable dump and restore facility for each model in which StuffArc is
included.

