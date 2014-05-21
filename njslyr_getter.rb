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
			doc = Nokogiri::HTML.parse(open("#{url}?page=#{pagenum.to_s}"))
			# 1ページ目なら当該エピソードのタイトルを取得する
			@episodetitle = getEpTitle(doc) if pagenum == 1
			Logger.new(STDOUT).debug("#{@episodetitle} \##{pagenum.to_s}")
			
			tweets = doc.xpath('//div[@class="tweet"]')
			# 分割ページに残データが無ければループ終了
			break if tweets.empty?
			# 各tweetを取得
			tweets.each do |e|
				@texts.push e.text
			end
			
			pagenum += 1
		end
	end

	def getEpTitle(doc)
		if ms = NKF::nkf('-Wwxm0Z0', doc.title).match(/\A(.*) - Togetterまとめ\z/) 
			ms[1].gsub(/[「」]/, '')
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
