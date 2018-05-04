# csvに書き出すためのライブラリの読み込み
require 'csv'
require 'net/http'
require 'json'

#BASE_URL_GOOGLE_MAP = "http://maps.google.com/maps/api/geocode/json"
BASE_URL_GOOGLE_MAP =  "https://maps.googleapis.com/maps/api/geocode/json"
KEY = "AIzaSyANPvw4wN_PQoPc6iFHsnGtGEUYNxq36R4"

# Google Map API
def geocode_google_map(address)

  puts "Start Geocode by Google Map API"
  address = URI.encode(address)
  hash = Hash.new
  reqUrl = "#{BASE_URL_GOOGLE_MAP}?address=#{address}&key=#{KEY}"
  try = 0
  begin
  try += 1
  response = Net::HTTP.get_response(URI.parse(reqUrl))
  rescue
    puts "#{try}回失敗しました。リトライ処理を行います。"
    retry if try < 10
    puts "10回実行しましたが、ダメでした。ダミーデータを格納します。"
    hash['latitude'] = 0.00
    hash['longitude'] = 0.00
    return hash
  end
  # レスポンスコードのチェック
  # 詳細は http://magazine.rubyist.net/?0013-BundledLibraries
  case response # 200 OK
  when Net::HTTPSuccess then
    data = JSON.parse(response.body)
    p data
    if data['status'] == "OK"
      hash['latitude'] = data['results'][0]['geometry']['location']['lat']
      hash['longitude'] = data['results'][0]['geometry']['location']['lng']
      puts "success!"
    else
      hash['latitude'] = 0.00
      hash['longitude'] = 0.00
      puts "fail..."
    end
  else
    hash['latitude'] = 0.00
    hash['longitude'] = 0.00
  end
  return hash
end


puts "start..."

intro_csv = CSV.generate do |csv|
  CSV.foreach('gamecentor.csv', headers: true) do |data|
    intro_msg = [
      data["name"],
      data["address"],
      data["access"],
      data["remarks"],
    ]
    puts data["address"]
    coordinate = geocode_google_map(data["address"])
    #sleep(1)
    intro_msg.push(coordinate["latitude"],coordinate["longitude"])
    csv << intro_msg
  end
end

File.open("intro.csv", 'a') do |file|
  file.write(intro_csv)
end

puts "complete! See intro.csv."
