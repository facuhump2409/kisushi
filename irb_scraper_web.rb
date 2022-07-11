# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'open-uri'
# require '/item'
require 'csv'
folder = "/Users/lsalerno/kisushi/"
require "#{folder}item"

def create_product(id, title, specific_category, price, image, general_category, description)
  product_link = 'https://tepido.com.ar/restaurantes?q=kizushi'
  final_price = "ARS #{price}"
  separator = ' &amp;gt; '
  # general_category = "Home &amp;gt; Rolls"
  rolls_product_type = if specific_category.nil? || specific_category.empty?
                         general_category
                       else
                         "#{general_category}#{separator}#{specific_category}"
                       end
  identifier_exists = 'no'
  facebook_product = Item.new
  facebook_product.id = id
  facebook_product.availability = 'in stock'
  facebook_product.condition = 'new'
  facebook_product.image_link = image
  facebook_product.link = product_link
  facebook_product.title = title
  facebook_product.price = final_price
  facebook_product.product_type = rolls_product_type
  facebook_product.identifier_exists = identifier_exists
  facebook_product.description = description

  facebook_product
end

puts 'Starting new iteration'

# rss = Rss.load_from_file("exampleFeed.xml")

list_xpath = '//li/figure'
image_link = 'https://kizushi.com.ar/'
id = 1
normal_cases = [['https://kizushi.com.ar/rolls.html', 'Home &amp;gt; Rolls'],
                ['https://kizushi.com.ar/entradas.html', 'Home &amp;gt; Entradas'],
                ['https://kizushi.com.ar/platos.html', 'Home &amp;gt; Platos'],
                ['https://kizushi.com.ar/salads.html', 'Home &amp;gt; Poke Salads'],
                ['https://kizushi.com.ar/veggie.html', 'Home &amp;gt; Veggie']]
rare_cases = [['https://kizushi.com.ar/tablas.html', 'Home &amp;gt; Tablas'],
              ['https://kizushi.com.ar/veggie.html', 'Home &amp;gt; Veggie']]
products = []
description_xpath = ".//p"
default_image = "https://i.ibb.co/q7jXtmc/nuevo.png"
normal_cases.each do |url|
  document = begin
               Nokogiri::HTML(URI.open(url[0]))
             rescue StandardError
               return
             end
  document.xpath(list_xpath).each do |detail|
    title_xpath = ".//span[contains(@class, 'text-extra-dark-gray')]"
    specific_category_xpath = ".//span[contains(@class, 'text-small')]"
    price_xpath = ".//span[contains(@class, 'text-extra-dark-gray')][2]" # quedarte con el segundo precio
    image_xpath = './/img/@src'
    title = detail.at_xpath(title_xpath).text.gsub(" ", "")
    specific_category = begin
                          detail.at_xpath(specific_category_xpath).text
                        rescue StandardError
                          ''
                        end
    price = begin
              detail.xpath(price_xpath)[1].text
            rescue StandardError
              detail.xpath(price_xpath)[0].text
            end
    if price.count('$') > 1
      prices = price.split '$'
      price = prices[2]
    end
    price = price.sub('$', '').strip
    image = begin
              "#{image_link}#{detail.at_xpath(image_xpath).text}"
            rescue StandardError
              default_image
            end
    price = price.sub('.', '')
    description = begin
                    detail.at_xpath(description_xpath).text.gsub("\n", ", ")
                  rescue
                    nil
                  end
    products << create_product(id, title, specific_category, price, image, url[1], description)
    id += 1
  end
end
rare_cases.each do |url|
  document = begin
               Nokogiri::HTML(URI.open(url[0]))
             rescue StandardError
               return
             end
  list_xpath = "//div[contains(@class,'margin-five')]"
  document.xpath(list_xpath).each do |detail|
    title_xpath = ".//div[contains(@class,'text-uppercase')]"
    price_xpath = ".//strong|.//span[contains(@class,'text-normal')]"
    title = begin
              detail.at_xpath(title_xpath).text
            rescue StandardError
              ''
            end
    next if title.empty?

    price = begin
              detail.xpath(price_xpath)[1].text.sub('$', '').strip
            rescue StandardError
              detail.xpath(price_xpath)[0].text.sub('$', '').strip
            end
    price = price.sub('.', '')
    description = begin
                    text = detail.at_xpath(description_xpath).text
                    texts = text.split(/\b/)
                    texts.delete_if { |x| x == " " }
                    array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"]
                    final_texts = texts.map do |x|
                      if (array.include? x[-1] and !array.include? x[-2])
                        number = x[-1]
                        x[-1] = " "
                        x = x + number
                      end
                      if (array.include? x[-1] and array.include? x[-2])
                        number = x[-2]
                        second_number = x[-1]
                        x[-2] = " "
                        x[-1] = number
                        x = x + second_number
                      end
                      x
                    end
                    final_texts.join(" ").strip.gsub("\n", ", ").gsub("  ", "")
                  rescue
                    nil
                  end
    products << create_product(id, title, nil, price, default_image, url[1], description)
    id += 1
  end
end
headers = %w[id availability condition image_link link title price product_type
             identifier_exists description]
CSV.open("#{folder}products.csv", 'w') do |csv|
  csv << headers
  products.each do |product|
    csv << [product.id, product.availability, product.condition, product.image_link, product.link, product.title,
            product.price, product.product_type, product.identifier_exists, product.description]
  end
end
p products
# channel.item = products
# rss.channel = channel
# xml = rss.save_to_xml
# xml.write($stdout, 2)
