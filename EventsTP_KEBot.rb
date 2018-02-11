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
  def initialize (limit_at_time = 4, region)
    # На tpad нужны пока только msk, rnd, spb
    # другие - скипать
    case region
    when 'msk'
      @rgn  = "&cities=%D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0"
      @tg   = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_2']
    when 'rnd'
      @rgn = nil # "&cities=%D0%A0%D0%BE%D1%81%D1%82%D0%BE%D0%B2-%D0%BD%D0%B0-%D0%94%D0%BE%D0%BD%D1%83"
      @tg   = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_2']
    when 'spb'
      @rgn = nil # "&cities=%D0%A1%D0%B0%D0%BD%D0%BA%D1%82-%D0%9F%D0%B5%D1%82%D0%B5%D1%80%D0%B1%D1%83%D1%80%D0%B3"
      @tg   = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_2']
    else
      @rgn = nil
      @tg   = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_2']
    end

    @limit_at_time  = limit_at_time # макс. число событий за раз
    @url            = "https://api.timepad.ru/v1/events.json?limit=50&skip=0#{@rgn}&fields=location,description_short&category_ids=374&sort=+starts_at"
    @db             = DB_Exec.new("tpad")
  end

  def sync
    # TvKinoRadio из НУЖНЫХ имеет только msk
    # другие - скипать
    return if @rgn.nil?

    uri       = URI(@url)
    response  = JSON.parse(Net::HTTP.get_response(uri).body)["values"]

    count     = 0
    response.each do |event|
      # Выдавать за раз не более 5
      break if count >= @limit_at_time

      link = event['url']
      time = Time.parse(event['starts_at']).to_i

      if !@db.check_exists_in_DB?(link, time)
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

        @db.insert_to_DB(link, time)
        count += 1
      else
      end
    end
  end

end
