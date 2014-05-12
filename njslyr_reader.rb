# encoding: utf-8

# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'
# NKF
require 'nkf'


class NJSLYRepisode
	@texts
	attr_accessor :texts, :episodenum, :episodetitle

	def initialize(url = 'http://togetter.com/li/241872')
		@texts =  Array.new
		pagenum = 1
		
		# 分割ページに対応するためにループ
		loop do
			doc = Nokogiri::HTML.parse(open("#{url}?page=#{pagenum.to_s}"))
			# 1ページ目なら当該エピソードのタイトル・ナンバリングを取得する
			@episodenum = getEpNum(doc) if pagenum == 1
			
			tweets = doc.xpath('//div[@class="tweet"]')
			# 分割ページに残データが無ければループ終了
			break if tweets.empty?
			# 各tweetを取得。末尾のナンバリングを掃除する
			tweets.each do |e|
				@texts.push e.text.gsub(/\s+\d+\z/,"")
			end
			
			pagenum += 1
		end
	end

	def getEpMetaData(doc)
		if ms = NKF::nkf('-Wwxm0Z0', doc.title).match(/\A(.*)\s*#(\d+)/) 
			@episodetitle =  ms[1]
		       	@episodenum = ms[2].to_i
		else 
		       	nil
		end
	end
end
