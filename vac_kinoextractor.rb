#===================================================================================================
#
# Скрипт извлекает данные о вакансиях из:
# rss hh:
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2017-12-24
# @version = "0.0.1"
#
#===================================================================================================

require 'telegram/bot'
require 'sdbm'
require 'rss/2.0'

require "./set_env.rb"

donors_arr = [
  "235842",   # Вольга
  "34827",    # 20й век фокс
  "90249",    # Дисней
  "578467",   # Мельница
  "108855",   # Централ Партнершип
  "31672",    # Амедиа
  "31647",    # Базилевс
  "2404145",  # Мосфильм
  "574817",   # Каро Премьер
  "213729",   # Кинопоиск
  "1116814",  # Голливуд Репортер рус
  "1122923",  # Russian World Vision
  "2444097",  # MEGOGO.NET
]

class Vac_KEBot
  def initialize (url, link_name)
    if ENV['TGBK_1'].nil?
      puts "Bot is not set."
      exit 0
    else
      puts "ENV is ready."
    end

    if !ENV['TGBCh_1'].nil? && (/@[a-z]/ =~ ENV['TGBCh_1']) == 0
      puts "Channel is ready."
    else
      puts "Channel is not set."
      exit 0
    end

    @url      = url
    @db       = "#{link_name}_db"
  end

  def sync
    feed = RSS::Parser.parse(@url, false)
    feed.items.each do |item|
      # puts "#{!check_exists_in_DB?(item.link, item.pubDate.to_i)}    #{item.link}"
      if !check_exists_in_DB?(item.link, item.pubDate.to_i)
        insert_to_DB(item.link, item.pubDate.to_i)
        tg_send(
          "#{item.link}\n"
        )
      end
    end
  end

  # проверка на существование в БД
  # возвр. true, если сущ.
  def check_exists_in_DB? (link, pubDate)
    exists = false
    SDBM.open @db do |db|
      db.select do |kLink, vPubDate|
        if kLink == link && vPubDate.to_i == pubDate.to_i
          exists = true
          break
        end
      end
    end

    exists
  end

private
  # вставка эл-та в бд
  def insert_to_DB (link, pubDate)
    SDBM.open @db do |db|
      db[link] = pubDate.to_s
    end
  end

  def tg_send(message)
    Telegram::Bot::Client.run(ENV['TGBK_1']) do |bot|
      if bot.api.sendMessage(chat_id: "#{ENV['TGBCh_1']}", text: message)
        puts "Message was send successful."
        true
      else
        puts "Message was not send. See log."
        false
      end
    end
  end

end




# отправление его в цикл
# с ожиднием 15 минут
_sleep_time = 15 * 60
loop do

  donors_arr.each do |ll|
    link = "https://hh.ru/search/vacancy/rss?no_magic=true&employer_id=#{ll}&isAutosearch=true"
    # puts link
    a = Vac_KEBot.new link, "hh"
    a.sync
  end
  sleep _sleep_time

end
