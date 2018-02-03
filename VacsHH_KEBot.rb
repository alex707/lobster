#===================================================================================================
#
# Класс извлекает данные о вакансиях из:
# rss hh:
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2017-12-24
# @version = "0.2.0"
#
#===================================================================================================

require 'telegram/bot'
require 'rss/2.0'

require "./DB_Exec.rb"
require "./TG_Sender.rb"


class VacsHH_KEBot
  def initialize (url, link_name)
    @tg       = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_1']
    @url      = url
    @db       = DB_Exec.new(link_name)
  end


  def sync
    feed = RSS::Parser.parse(@url, false)
    feed.items.each do |item|
      if !@db.check_exists_in_DB?(item.link, item.pubDate.to_i)
        @db.insert_to_DB(item.link, item.pubDate.to_i)
        @tg.tg_send(
          "#{item.link}\n"
        )
      end
    end
  end
end
