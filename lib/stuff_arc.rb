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
require 'active_model'
# require 'pry'

module StuffArc
  VERSION = "0.0.5.pre1"

  def self.included(mod)
    mod_lowercase = mod.to_s.underscore.pluralize
    tmp =<<-EOF
    def self.archive options = {}
      unless (lib_dir = options.delete(:lib_dir))
        if Rails.public_path
          lib_dir =  File.join( File.dirname(::Rails.public_path), 'lib', 'stuff_arc' )
          Dir.mkdir(lib_dir) unless File.exists? lib_dir
        else
          lib_dir = '.'
        end
      end
      fname = options.delete(:fname) || '#{mod_lowercase}.json'
      fname = File.join(lib_dir, fname) unless fname[0] == File::SEPARATOR
      
      if File.exists? fname
        back_name = fname + '~'
        File.unlink back_name if File.exists? back_name
        File.rename fname, back_name
      end
      f = File.open(fname, 'w')
      list = self.all
      list.each do |#{mod_lowercase}|
        # as_json returns a hash, which we have to change to a JSON string
        f.write #{mod_lowercase}.as_json.to_json + "\n"
      end
      f.close
      list.length
    end
    EOF
    
    mod.instance_eval tmp, __FILE__, __LINE__

    tmp =<<-EOF
    def self.unarchive options = {}
      unless (lib_dir = options.delete(:lib_dir))
        if Rails.public_path
          lib_dir =  File.join( File.dirname(::Rails.public_path), 'lib', 'stuff_arc' )
          Dir.mkdir(lib_dir) unless File.exists? lib_dir
        else
          lib_dir = '.'
        end
      end
      fname = options.delete(:fname) || '#{mod_lowercase}.json'
      fname = File.join(lib_dir, fname) unless fname[0] == File::SEPARATOR

      return nil unless File.exists? fname

      f = File.new fname

      counter = 0
      f.lines do |line|
        #{mod_lowercase} = #{mod}.new.from_json(line.chomp)
        begin
          #{mod_lowercase}.save!
          counter += 1
        rescue Exception => e
          puts "exception unarchiving #{mod_lowercase}: \#{e}\n"
        end
      end

      f.close
      counter
    end
    EOF
    
    mod.instance_eval tmp, __FILE__, __LINE__

  end
end
