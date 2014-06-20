# encoding: utf-8
require './njslyr_getter.rb'


module NJSLYR_Util
	# 引数として渡したリストファイルから複数ファイルの取得を行う
	def get_episodes(listfile)
		return if !listfile
		File.open(File.expand_path(listfile), 'r') do |f|
			f.each_line do |l|
				ep = NJSLYRepisode.new(l.gsub(/\n|\s/, ''))
			end
		end
	end

	# 引数として渡したファイルの結合を行う
	def join_episodes(first_file)
		episode_title = File.basename(first_file).notNumberedTitle
		puts episode_title
		files = Dir.glob("#{File.dirname first_file}/#{episode_title}*").sort do |a, b|
			reg = /#{episode_title}[^\d]*([0-9]+)[^\d]*/
			File.basename(a).match(reg)[1].to_i <=> File.basename(b).match(reg)[1].to_i
		end
		if !files.empty?
			arr = []
			files.each do |file|
				puts "JOINING...: #{File.basename(file)}"
				arr.push File.open(file).read
			end
			joined_path = File.expand_path "#{episode_title}.txt"
			File.open(joined_path, 'w').write arr.join("\n")
			puts "JOINED: #{joined_path}"
		end
	end

	module_function :get_episodes, :join_episodes
end

class String
	def notNumberedTitle
		return self.gsub(/(#[0-9]+)|(\.txt)|\s/, '')
	end
end
