# stuff_arc - supports Rails portable data dump and restore

## Version 0.0.6

stuff_arc adds class level archiving and unarchiving of an ActiveRecord object
a Rails app by Auto-Extending ActiveRecord::Base with two methods: `archive` and
`unarchive`

Archives are JSON data, one line per model instance with the 'id' value omitted so that
the data can be restored w/o worrying about primary key clashes.

Restoration is performed by instantiating the model and then calling save!. **save!** exceptions
are trapped and generate simple error messages, thus Rails validations can be used to avoid
data duplication and data clobbering.

These methods are designed to be used in a Rails Console, not programatically.

## Install

    Add `gem stuff_arc` to your Gemfile & run `bundle`

    All models (derived from ActiveRecord::Base) will now have `archive` and `unarchive`
    class methods.
    
## Usage

Assume:

    class Foo < ActiveRecord::Base

* Foo.archive(options = {}) - which will create the file 'foos.json' containing JSON serializations
of every record retrieved by Foo.all with the 'id' entry is excluded.
* Foo.unarchive(options = {}) - which reads the file 'foos.json', decodes each record and attempts
to save! them to the database.

The options are:

* :fname - name of archive file. Defaults to the _underscored_, _pluralized_ version of the
class name with the '.json' suffix.
* :lib\_dir - path to directory archives are placed/looked for in. **NOTE:** :lib\_dir is ignored if
:fname is an absolute path. Defaults to:

      &lt;app root&gt;/lib/stuff\_arc - if Rails.public\_path is defined
        
      '.' - if Rails.public\_path is not defined


This creates a portable dump and restore facility for each model in which StuffArc is
included.

## Creating an Archive

Fire up the rails console [rails c &lt;development|production&gt;] and . . .

Create an archive in the default directory with default name:

    Foo.archive
    
Create an archive in the default directory with a different name

    Foo.archive :fname => 'foobar'

Create an archive in a specified directory with the default name

    Foo.archive :lib_dir => '/tmp'
    
## Restoring an Archive

Fire up the rails console [rails c &lt;development|production&gt;] and . . .

repeat one of the commands above using **Foo.unarchive** instead of *Foo.archive*
