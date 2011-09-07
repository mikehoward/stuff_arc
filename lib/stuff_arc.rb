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
# require 'pry'
# require 'active_support'
# require 'active_support/inflector'
# require 'active_support/json'

module StuffArc
  VERSION = "0.0.2"

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
        json_str = ActiveSupport::JSON.encode #{mod_lowercase}, :include_root_in_json => false, :except => :id
        f.write json_str + "\n"
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

      f.lines do |line|
        #{mod_lowercase} = self.new Hash[ActiveSupport::JSON.decode(line).map { |k,v| [k.to_sym, v] }]
        begin
          #{mod_lowercase}.save!
        rescue Exception => e
          puts "exception unarchiving #{mod_lowercase}: \#{e}\n"
        end
      end

      f.close
    end
    EOF
    
    mod.instance_eval tmp, __FILE__, __LINE__

  end
end
