# encoding: utf-8

# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'
# NKF
require 'nkf'
require 'logger'


class NJSLYRepisode
	@texts
	attr_accessor :texts, :episodetitle

	def initialize(url)
		@texts =  Array.new
		pagenum = 1

		# 分割ページに対応するためにループ
		loop do
			numberedurl = "#{url}?page=#{pagenum.to_s}"
			page = openPage(numberedurl)
			# リダイレクトが発生した場合は最初のページに戻されているので終了
			break if(!page)
			doc = Nokogiri::HTML::parse(page)
			# 当該エピソードのタイトルを取得する
			@episodetitle = getEpTitle(doc)
			Logger.new(STDOUT).debug("#{@episodetitle} page:#{pagenum.to_s}")
			# コメント欄もdiv.tweetなのでサニタイズする
			tweets = doc.xpath('//div[@class="tweet"]').map{|e| e if e.css('span').empty?}
			# 各tweetを取得
			tweets.each do |e|
				@texts.push e.children.text.gsub(/　/, ' ') if e and e.children
			end
			pagenum += 1
			sleep 5
		end
		saveFile
	end

	def openPage(target_url)
		begin
			open(target_url, :redirect => false, "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53")
		rescue
			nil
		end
	end

	def getEpTitle(doc)
		if ms = NKF::nkf('-Wwxm0Z0', doc.title).match(/\A(.*) - Togetterまとめ\z/) 
			ms[1].gsub(/[「」]|\s/, '')
		else 
			''
		end
	end

	def saveFile(filename = @episodetitle)
		File.open("./ep/#{filename}.txt", 'w') do |f|
			@texts.each do |t|
				f.puts t
			end
		end
	end
end
