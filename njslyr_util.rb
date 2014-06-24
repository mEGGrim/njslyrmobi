# encoding: utf-8
require './njslyr_getter.rb'


module NJSLYR_Util
	# 引数として渡したリストファイルから複数ファイルの取得を行う
	def get_episodes(listfile)
		return if !listfile
		File.open(File.expand_path(listfile), 'r') do |f|
			f.each_line do |l|
				l.gsub! /\n|\s/, ''
				if l =~ /http:\/\/togetter.com\/li\/[0-9]+/
					NJSLYRepisode.new(l)
				else
					Logger.new(STDOUT).debug("Getting from Wiki Page...")
					get_togetter_list(l).each do |ep|
						NJSLYRepisode.new(ep)
					end
				end
				# リストに記載されていたのがタイトルかWikiの場合はリスト取得する
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

	# 対象のWikiページからTogetterのURLリストを取得する
	def get_togetter_list(url)
		parsed_url = url
		if parsed_url !~ %r|https?://.*|
			parsed_url = "「#{parsed_url}」" if parsed_url !~ %r|\A「.*」\z|
			parsed_url = "http://wikiwiki.jp/njslyr/?#{parsed_url}"
		end

		Logger.new(STDOUT).debug("GET...#{parsed_url}")
		doc = Nokogiri::HTML::parse open(URI.encode parsed_url.encode('EUC-JP'))
		mokuji = doc.xpath('//div[@id="body"]/p').first
		flag = true
		mokuji.children.map{|child|
			if child.text =~ /.*実況.*/ then flag = false
			elsif child.text =~ /.*まとめ.*/ then  flag = true end
			child.attribute('href').value if flag and child.attribute('href')
		}.compact
	end
	module_function :get_episodes, :join_episodes, :get_togetter_list
end

class String
	def notNumberedTitle
		return self.gsub(/(#[0-9]+)|(\.txt)|\s/, '')
	end
end
