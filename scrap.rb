require 'nokogiri'
require 'open-uri'
require 'json'

BASE_URL = 'https://eski.tbd.org.tr/index.php?sayfa=sozluk&mi1'.freeze
DICT_TYPES = {
  'tren' => "abcdefghijklmnoprstuvyz".upcase.chars.push('%C7', '%DE'), # Ç and Ş
  'entr' => "abcdefghijklmnopqrstuvwxyz".upcase.chars
}

def save_dict_to_file tr_type, char, dict
  File.open("#{tr_type}/#{char}.json","w") do |f|
    f.write(JSON.pretty_generate(dict))
  end
end

def get_word_translations html
  dictionary = {}
  selected_nodes = html.css('table tbody tr')
  selected_nodes.shift
  
  selected_nodes.each do |tr_node|
    td_nodes = tr_node.css('td')
    dictionary[td_nodes[0].children.text]= td_nodes[1].children.text
  end
  dictionary
end

def make_requests
  DICT_TYPES.each do |translation_type, chars|
    chars.each do |char|
      html = Nokogiri::HTML(URI.open("#{BASE_URL}&tipi=#{translation_type}&harf=#{char}"))
  
      dictionary = get_word_translations(html)
      save_dict_to_file(translation_type, char, dictionary)
    end
  end
end

def main
  make_requests
end

main