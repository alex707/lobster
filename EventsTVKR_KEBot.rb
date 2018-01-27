#===================================================================================================
#
# Класс извлекает данные о событиях из:
# tvkinoradio
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-20
# @version = "0.0.1"
#
#===================================================================================================

require "net/http"
require 'openssl'
require 'nokogiri'
require 'date'

require "./TG_Sender.rb"
require "./DB_Exec.rb"

ENV['SSL_CERT_FILE']  = './cacert.pem'

class EventsTVKR_KEBot
  def initialize(max_num = 5)
    @max_num  = max_num
    @url  = 'https://tvkinoradio.ru/events?date[start]='
    @par  = Date.today
    @db   = DB_Exec.new("tvkr")
    @tg   = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_2']
  end

  def sync
    all_links = []

    tries_count = 0 # число попыток
    # число ссылок должно быть не меньше желаемого
    while all_links.size <= @max_num do
      # извлечение всех событий на день.
      events_per_date_doc = to_do_request "#{@url}#{@par.to_s}", true

      # парсинг данных. извлечение ссылок.
      all_links += events_thumbnail_links events_per_date_doc
      par_up
      raise "next mounth is empty!!!" if tries_count > 31
      tries_count += 1
    end

    all_links.first(@max_num).each do |link|
      # переход на страницу с событием
      event_detailed_doc = to_do_request link

      # хз. что писать в дату публикации, т.к. она не задаётся
      # буду надеятся, что повторно одни и те же страницы ресурс не используют.
      time = nil
      if !@db.check_exists_in_DB?(link, time)
        @db.insert_to_DB(link, time)

        # извлечение события
        message = extract_event_info event_detailed_doc

        @tg.tg_send message
      end
    end
  end

private
  def events_thumbnail_links day_events_doc
    # собирает краткую информацию (требуются ссылки) о событиях текущего дня
    links_arr = []
    if day_events_doc.css("p[class='no-events-text']")[0].nil?
      # самая первая запись в теге section по классу 'col-xs-12 index-list' содержит события на текущий день.
      current_day = day_events_doc.css("section[class='col-xs-12 index-list']")[0]

      # инфа о каждом событии в текущем дне хранится в теге div в классе 'preview-info'.
      # извлекаются только ссылки (и только нужное их количество).
      current_day.css("div[class='preview-info']").each do |event|
        link            = event.css("h2[class='preview-title']").css("a")[0]["href"].prepend("https://tvkinoradio.ru")

        # дата публикации события в tvkinoradio не найдена. проставляется nil.
        time = nil
        if !@db.check_exists_in_DB?(link, time)
          # сбор ссылок, которые ещё не опубликованы
          links_arr << link
        end
      end

    else
      # сообщение о том, что событий на тек. день нет
      day_events_doc.css("p[class='no-events-text']")[0].text
    end

    links_arr
  end

  def to_do_request link, flag = false
    # выполняет запрос по ссылке.
    # возвращет строку (тело ответа)
    # flag == true - добавляет параметр 'XMLHttpRequest' в заголовок
    uri = URI(link)

    req = Net::HTTP::Get.new(uri)
    req['X-Requested-With'] = 'XMLHttpRequest' if flag

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true, :veryfi_mode => OpenSSL::SSL::VERIFY_NONE, :ca_file => ENV['SSL_CERT_FILE'] ) do |http|
      http.request(req)
    end

    Nokogiri::HTML(res.body.force_encoding("UTF-8"))
  end


  def extract_event_info doc_from_event
    # извлекает по ссылке всю информацию о событии
    link      = doc_from_event.css("link[rel='canonical']").first['href'].to_s.strip
    puts link
    title     = doc_from_event.css("h2[class='page-h']").text
    time1     = doc_from_event.css("span[class='item-h event-date-day']").first.text.strip
    time2     = doc_from_event.css("span[class='guide-grey-dark event-date-weekday']").first
    descr     = doc_from_event.css("div[class='view-category']").first.text
    location1 = doc_from_event.css("span[class='event-place-address guide-grey-dark displayblock']").first.text
    location2 = doc_from_event.css("span[class='event-place-name item-h displayblock']").first.text

    message = <<-MESSAGE
      #{link}
      <i>#{title}</i>
      <b>Description:</b> #{descr if descr}
      <b>Date/Time:</b> #{time1} #{?, unless time2.nil?} #{time2.text.strip.to_s.gsub(/\s+/, ' ') unless time2.nil?}
      <b>Location:</b> #{location1}, #{location2}
    MESSAGE
  end

  def par_up
    @par += 1
  end
end

# File.open("lopata.txt", "w") do |i|
  # i.write(ev)
# end
