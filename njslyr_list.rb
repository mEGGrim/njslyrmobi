# encoding: utf-8

# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'
# NKF
require 'nkf'

require './njslyr_getter.rb'

File.open('./list', 'r') do |f|
	f.each_line do |l|
		ep = NJSLYRepisode.new(l.gsub("\n", ''))
		puts ep.episodetitle
		ep.saveFile
	end
end
