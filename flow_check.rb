
require 'fileutils'
require 'yaml'
require 'erb'
require './stupid_stuff.rb'
$paths = 'flow_paths.yml'

class FlowCheck
  def initialize
      erb = ERB.new(File.read($paths)).result @bin
      yp erb
      hsh = YAML.load erb.gsub("=>", ": ")
      yp hsh
  end
end

f = FlowCheck.new