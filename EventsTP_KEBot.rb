#===================================================================================================
#
# Класс извлекает данные о событиях из:
# api timepad
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-13
# @version = "0.2.0"
#
#===================================================================================================

require 'net/http'
require 'json'

require "./DB_Exec.rb"
require "./TG_Sender.rb"

class EventsTP_KEBot
  def initialize (url, link_name)
    @tg             = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_2']
    @limit_at_time  = 1    # макс. число событий за раз
    @url            = url
    @db             = DB_Exec.new(link_name)
  end

  def sync
    uri       = URI(@url)
    response  = JSON.parse(Net::HTTP.get_response(uri).body)["values"]

    count     = 0
    response.each do |event|
      # Выдавать за раз не более 5
      break if count >= @limit_at_time

      link = event['url']
      time = Time.parse(event['starts_at']).to_i

      if !@db.check_exists_in_DB?(link, time)
        @db.insert_to_DB(link, time)

        # title1 = "Дата/Время:".to_s
        # title2 = "Место:".to_s
        message = <<-MESSAGE
          #{link}
          <i>#{event['name'].to_s}</i>
          <b>Description:</b> #{event['description_short'].to_s if event['description_short']}
          <b>Date/Time:</b> #{Time.at(time).strftime("%d.%m.%Y %H:%M")}
          <b>Location:</b> #{event['location']['city'].to_s}, #{event['location']['address'].to_s}
        MESSAGE

        @tg.tg_send( "#{message}\n" )
        count += 1
      else
      end
    end
  end

end
