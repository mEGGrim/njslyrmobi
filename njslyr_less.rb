# encoding: utf-8

require './njslyr_getter.rb'
require 'tempfile'

ARGV.each do |arg|
	ep = NJSLYRepisode.new(arg) if arg =~ /\Ahttp://.*/ 
	tf = Temfile.open(TempFile.ep.title)

end
