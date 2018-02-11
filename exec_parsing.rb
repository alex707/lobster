#===================================================================================================
#
# Скрипт Запускает бота на обработку каналов
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-14
# @version = "0.2.0"
#
#===================================================================================================

require 'nokogiri'

require "./set_env.rb"
require "./EventsTP_KEBot.rb"
require "./EventsTVKR_KEBot.rb"
require "./VacsHH_KEBot.rb"
require "./VacsTVKR_KEBot.rb"

def exec_parsing region = 'msk'
  puts "#{t1 = Time.now}_B_VacsHH_KEBot"
  # верю, надеюсь, жду
  doc = File.open("donors_hh.xml") { |f| Nokogiri::XML(f) }

  donors_arr = []
  doc.xpath('//code').each { |code| donors_arr << code.text}

  donors_arr.each do |ll|
    link = "https://hh.ru/search/vacancy/rss?no_magic=true&employer_id=#{ll}&isAutosearch=true"
    a = VacsHH_KEBot.new link, "hh"
    a.sync
  end
  puts "#{Time.now}_E_VacsHH_KEBot. total: #{Time.now - t1}"
  sleep 20


  puts "#{t2 = Time.now}_B_VacsTVKR_KEBot"
  a = VacsTVKR_KEBot.new 6
  a.sync
  sleep 20
  puts "#{Time.now}_E_VacsTVKR_KEBot. total: #{Time.now - t2}"


  puts "#{t3 = Time.now}_B_EventsTVKR_KEBot"
  a = EventsTVKR_KEBot.new 1, region
  a.sync
  sleep 20
  puts "#{Time.now}_E_EventsTVKR_KEBot. total: #{Time.now - t3}"


  puts "#{t4 = Time.now}_B_EventsTP_KEBot"
  a = EventsTP_KEBot.new 4, region
  a.sync
  sleep 20
  puts "#{Time.now}_E_EventsTP_KEBot. total: #{Time.now - t4}"
end

# выполнение скриптов
exec_parsing
