require 'open-uri'
require 'nokogiri'

namespace :db do
  desc "Fill database with data from zlacnene.sk"
  task fillup: :environment do
#zlacnene.sk
    (1..56).each do |id|
      #puts "Strana cislo #{id}"
      html = open("http://www.zlacnene.sk/tovar/hladaj/sk-potraviny/p/#{id}")
      doc = Nokogiri::HTML(html)
      doc.search('.zboziVypis').each do |produkt|
        meno = produkt.search('h2 a').text
        #puts meno
        cena = produkt.search('.cena').text.split(' ')
        obchod = produkt.search('.prodejnaName').text
        #platnostDo = produkt.search('.platiDo').text
       # puts cena[1] +" "+obchod +" "+ platnostDo
        temp = cena[1].sub(',','.').to_f

        item = Product.find_by(name: meno)
        if item.nil? then
          item = Product.create(name: meno)
          item.prices.create!(price: temp, shop: obchod)
        else
          if item.prices.where("price = ? AND shop = ?", temp, obchod).nil?
            item.prices.create!(price: temp, shop: obchod)
          end
        end
      end
    end
  end
end