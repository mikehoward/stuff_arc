# StuffArc - supports portable Rails databases dump and restore
#
# defines two class level methods for archiving and unarchiving ActiveRecord::Base
# objects.
#
# archive - creates an archive named <class.underscore>.json containing JSON representations
# of each instance of the model
#
# unarchive - which reads a file created by **archive** (named <class.underscore>.json) and
# saves each record in the datbase.
#
# Both methods are designed to be run from a Rails Console - not programatically.


require 'rails'
require 'stuff_arc/engine'
require 'stuff_arc/stuff_arc'
