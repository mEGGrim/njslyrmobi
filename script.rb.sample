# encoding: utf-8
require './njslyr_getter.rb'
require './njslyr_util.rb'

NJSLYR_Util.get_episodes './list'
Dir.glob('./ep/*#1.txt').each do |e|
	NJSLYR_Util.join_episodes e
end
