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

module StuffArc
  VERSION = "0.0.7"
  module Base
    def archive options = {}
      return self.class.archive options unless self.class == Class
      mod_lowercase = self.to_s.underscore.pluralize
      
      unless (lib_dir = options.delete(:lib_dir))
        if Rails.public_path
          lib_dir =  File.join( File.dirname(::Rails.public_path), 'lib', 'stuff_arc' )
          Dir.mkdir(lib_dir) unless File.exists? lib_dir
        else
          lib_dir = '.'
        end
      end
      fname = options.delete(:fname) || "#{mod_lowercase}.json"
      fname = File.join(lib_dir, fname) unless fname[0] == File::SEPARATOR
    
      if File.exists? fname
        back_name = fname + '~'
        File.unlink back_name if File.exists? back_name
        File.rename fname, back_name
      end
      f = File.open(fname, 'w')
      list = self.all
      save_include_root_in_json = include_root_in_json
      self.include_root_in_json = false
      list.each do |instance|
        # as_json returns a hash, which we have to change to a JSON string
        f.write instance.as_json.to_json + "\n"
      end
      self.include_root_in_json = save_include_root_in_json
      f.close
      list.length
    end

    def unarchive options = {}
      return self.class.unarchive options unless self.class == Class
      mod_lowercase = self.to_s.underscore.pluralize

      unless (lib_dir = options.delete(:lib_dir))
        if Rails.public_path
          lib_dir =  File.join( File.dirname(::Rails.public_path), 'lib', 'stuff_arc' )
          Dir.mkdir(lib_dir) unless File.exists? lib_dir
        else
          lib_dir = '.'
        end
      end
      fname = options.delete(:fname) || "#{mod_lowercase}.json"
      fname = File.join(lib_dir, fname) unless fname[0] == File::SEPARATOR

      return nil unless File.exists? fname

      f = File.new fname

      counter = 0
      f.lines do |line|
        tmp = self.new
        hash =  ActiveSupport::JSON.decode(line.chomp)
        hash.each { |k,v| tmp.send("#{k}=".to_sym, v) }
        begin
          tmp.save!
          counter += 1
        rescue Exception => e
          puts "exception unarchiving #{self}: #{e}\n"
        end
      end

      f.close
      counter
    end

    def self.included(mod)
      # if I'm included, then I want to extend myself
      puts "I'm being included in #{mod}!!!!"
      mod.send :extend, self
    end
  end
end
