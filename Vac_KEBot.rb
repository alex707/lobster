#===================================================================================================
#
# Класс извлекает данные о вакансиях из:
# rss hh:
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2017-12-24
# @version = "0.0.2"
#
#===================================================================================================

require 'telegram/bot'
require 'rss/2.0'

require "./set_env.rb"
require "./DB_Exec.rb"


class Vac_KEBot
  def initialize (url, link_name)
    if ENV['TGBK_1'].nil?
      puts "Bot is not set."
      exit 0
    end

    if !ENV['TGBCh_1'].nil? && (/@[a-z]/ =~ ENV['TGBCh_1']) == 0
    else
      puts "Channel is not set."
      exit 0
    end

    @url      = url
    @db       = DB_Exec.new(link_name)
  end


  def sync
    feed = RSS::Parser.parse(@url, false)
    feed.items.each do |item|
      if !@db.check_exists_in_DB?(item.link, item.pubDate.to_i)
        @db.insert_to_DB(item.link, item.pubDate.to_i)
        tg_send(
          "#{item.link}\n"
        )
      end
    end
  end

private
  # отправка сообщения в ТГ
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
