# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'
# csvに書き出すためのライブラリの読み込み
require 'csv'
require 'json'

class SCRAPING_URL
  def get_url
    urls = ["https://www5.atwiki.jp/gesen/pages/5.html",
        "https://www5.atwiki.jp/gesen/pages/6.html",
        "https://www5.atwiki.jp/gesen/pages/7.html",
        "https://www5.atwiki.jp/gesen/pages/8.html",
        "https://www5.atwiki.jp/gesen/pages/9.html",
        "https://www5.atwiki.jp/gesen/pages/18.html",
        "https://www5.atwiki.jp/gesen/pages/10.html"]
    url = 'https://www5.atwiki.jp/gesen/'
    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
    # htmlをパース(解析)してオブジェクトを生成
    doc = Nokogiri::HTML.parse(html, nil, charset)
    table = doc.xpath('//table')
    ts= table.search('.//tr[position()>1]')
    table.search('.//tr[position()>1]').each do |tr|
      tr.search('.//td/a').each do |td|
        urls.push("https:"+td[:href])
      end
    end
    puts urls
    return urls
  end
end

# スクレイピング先のURL
scraping_url = SCRAPING_URL.new
urls = scraping_url.get_url

urls.each do |url|
  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end
  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)
  csv = ""
  #File.open("text_write_test.json","w") do |json|
  File.open("text_write_test.txt","a") do |text|
    #doc.xpath('//table').each do |node|
    table = doc.xpath('//table')
    table.search('.//tr[position()>1]').each do |tr|
      arr = Array.new()
    	tr.search('.//td').each do |td|
    		arr.push(td.text)
    	end
    	csv << arr.to_csv
    end
    	text.write csv
    end
end




#    puts node.css('tr').inner_text
#    split = node.css('tr').inner_text.gsub(/\R/, "<br/>")
#    splits = node.css('tr').inner_text.split(/\R/)
#    splits.each do |s|
#      puts s.gsub!(/\t/, "")
#      text.put(s)
#    end
#    to_json = splits.to_json
#    json.puts(to_json.chomp)
#  end
	#p node.css('td').inner_text
	#p node.css('img').attribute('src').value
	#p node.css('a').attribute('href').value
