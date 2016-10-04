require_relative 'data_rider'
require_relative '../../useful_support/condition_files/err_raiser'
require_relative '../../useful_support/formatting_files/cosmetics'
require 'yaml'
require 'erb'

# == Include YamlRider and use the erb_eval methods with proper Binding!
# Namespace for classes and modules that handle +erb_eval+ing files with +binding+
module YamlRider

# @param [String] file_path the full path to the file.
# @return [String] just the file name (without +extensions+)
# @example Just get the file name
#   "c:\svn\some_file.yml" #=> "some_file"
# @deprecated Wrote this a loong time back.. just use absolute file paths.. don't need this!
  def get_file_name file_path
    file_path[/\\|\/(\w+)\.\w+$/, 1]
    # str[/\\|\/(\w+)\.yml$/, 1] redundant filter for yml if needed.. well, is never gonna be :(
  end


  # All the yml files are Heavily <% erb %>-ized and this method centralized handling them..
  # Try not to use any Direct YAML.load or other methods as this also does a lot of handling and such

  # @return [Hash] just contains all strings.. +Keys+ and +Values+
  # @param [String] path full file path to the yml to 'erb evaluate' with the binding
  # @param [Object,{#binding}] obj binds all the erb methods with +this binding+
  #
  # @raise [BadInputDataError] if the path is not a string.. silly check, i know, but you'll be +surprised+
  # @raise [MissingFileError] if no such file exists!
  # @raise [YamlLoadError] There is a bunch of handles in here that try to tell you where the +Exact Error+ is, but worst case.....
  #
  # @example Just to get the erb'd result of the +YML+ file
  #   self.erb_eval("c:\svn\some_file.yml") #=> {'key' => 'some_str_val' , 'hash_key' => [123,'abc',:kkk]}

  def erb_eval(path, obj=binding)
    # use know_where_to_look
    raise BadInputDataError, "Exp : String\nGot : #{path.class}\n#{path}\n" unless path.is_a? String
    raise MissingFileError, "Missing file #{path}\n" unless path or File.exists?(path)
    begin
      a = YAML.load((ERB.new(File.selective_read(path)).result(obj)).gsub("=>", ": "))
    rescue Exception => e
      begin
        p "Check all your Rules for valid Element Definitions and such..", :r
        p 'File Path:', :br
        p path, :r
        p 'File content:', :br
        p (lines = (File.read(path))), :w
        p 'ERBd content:', :br
        lines.split("\n").each_with_index { |line, n|
          begin
            pr "#{n}."
            a = ((ERB.new(line).result(obj)).gsub("=>", ": "))
            b = YAML.load(a)
          rescue Exception => ee
            p("\n Errored in - line #{n} : #{line}\n#{ee}\n", :y)
          end
        }
      rescue Exception => eee
        p "\nwierd.. maybe you have some \"/sdf.sdf/\" kinda thing?#{eee}\n in #{path}\n", :y
      end
      raise YamlLoadError, "\n#{e}\n in #{path}\n"
    end
    # a || {} # doing below for better handling
    return a if a
    p "empty #{path}\n" #if verbose_mode
    {}
  end

end

class File
  # Removes the commented out lines in the yml file..
  # @param [String] file_path file_path of the yml file that you can just {File#readlines}
  # @return [String] File String WITHOUT those #-commented lines
  #
  # @example Just to get the erb'd result of the +YML+ file
  #   file_path for file with #-commented lines #=> file_path content WITHOUT those #-commented lines

  def self.selective_read file_path
    ary=readlines(file_path)
    ary.delete_if { |lin| lin[/^(\s*#)/, 1] } # to delete commented lines
    ary.join "\n"
  end
end

# World YamlRider if __FILE__ != $0

# warn: hmm.. are these gonna be out unit test suites?
# +LOCAL UNIT TEST+ .. could be a thing! one day...

if __FILE__ == $0 # warn: hmm.. are these gonna be out unit test suites?
  #
  # require 'active_support/time'
  # require_relative '../../useful_support/condition_files/err_raiser'
  #
  # def offset(p = {}, strf_pattern = nil)
  #   a=(p[:from] or Time.now).advance(:days => p[:d]||p[:days], :months => p[:m]||p[:months], :years => p[:y]||p[:years])
  #   a.strftime(strf_pattern || "%m/%d/%Y")
  # end
  def env_state
    'env_state'
  end

  ENV["color"] = "y"
  require 'yaml'
  require 'erb'
  include YamlRider
  YamlLoadError = Class.new(StandardError)
  file_loc      = File.dirname(__FILE__)
  # $emailid = "sadf"
  # p path = (Dir[file_loc+"/../../pages/**/*year*.yml"].first)
  # p path = (Dir[file_loc+"/../../**/03_Gen*/**/*AR.yml"].first)
  # path          = (Dir[file_loc+"/../../../**/02*/**/happy*.yml"].first)
  # path          = (Dir[file_loc+"/../../../**/10*/**/tex*.yml"].first)
  # path          = (Dir[file_loc+"/../../../**/00_04*/**/tex*.yml"].first)
  # path          = (Dir[file_loc+"/../../../**/db_q*.yml"].first)
  path          = (Dir[file_loc+"/../../../**/exp_GA_east*.yml"].first)
  # path          = (Dir[file_loc+"/../../**/ebi_exp*.yml"].first)
  # path          = (Dir[file_loc+"/../../../**/10*/**/exp_common.yml"].first)
  p "Files:\n#{path}"
  erb = erb_eval(path)
  p erb
  p erb.to_yaml

  # kk=[]
  # erb.each{|k,v|kk << v['DYNAMIC'].split}
  #
  # p kk
  # p kk.flatten.uniq
end
