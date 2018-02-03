#===================================================================================================
#
# Класс извлекает данные о событиях из:
# tvkinoradio
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-02-02
# @version = "0.0.1"
#
#===================================================================================================

require "net/http"
require 'openssl'
require 'nokogiri'

require "./TG_Sender.rb"
require "./DB_Exec.rb"

class VacsTVKR_KEBot
  def initialize(max_num = 5)
    @max_num  = max_num
    @url = "https://tvkinoradio.ru/job?" +
      "Vacancy[title]=" +
      "&Vacancy[industries][]=1" +
      "&Vacancy[industries][]=5" +
      "&Vacancy[industries][]=2" +
      "&Vacancy[industries][]=10" +
      "&Vacancy[industries][]=11" +
      "&Vacancy[industries][]=6" +
      "&Vacancy[industries][]=3" +
      "&Vacancy[salarySince]=" +
      "&page="
    @par  = 1
    @db   = DB_Exec.new("tvkr_vacs")
    @tg   = TG_Sender.new ENV['TGBK_1'], ENV['TGBCh_1']
  end

  def sync
    tries_count   = 0
    comlete_count = 0
    until comlete_count >= @max_num
      # запрос на получение страницы с вакансиями
      vacs_per_page_doc = to_do_request "#{@url}#{@par.to_s}", true

      # получение ссылок со страницы
      current_links = events_thumbnail_links vacs_per_page_doc

      # если нет доступных ссылок на странице, то меняется номер стр. на следующий.
      if current_links.empty?
        par_up 
        puts "par_up"
      else
        current_links.each do |vac|
          # выход из цикла, если отправлено достаточное число ссылок
          break if comlete_count >= @max_num

          vac.each do |link, time|
            if !@db.check_exists_in_DB?(link, time)
              @db.insert_to_DB(link, time)

              @tg.tg_send link
              comlete_count += 1
            end
          end
        end
      end

      raise "next pages are empty!!!" if tries_count > 31
      tries_count += 1
    end
  end

private
  def events_thumbnail_links day_events_doc
    # собирает краткую информацию (требуются ссылки) о событиях текущей стр.
    links_arr = []

    if !day_events_doc.css("div[class='mj-preview']").nil?
      day_events_doc.css("div[class='mj-preview']").each do |event|
        link      = event.css("a").last["href"]
        diff_time = event.css("div[class='mj-preview-date']").text.split(' ')
        time      = Time.local(
          diff_time[2].to_i,
          def_month( diff_time[1].to_s ),
          diff_time[0]
        ).to_i

        if !@db.check_exists_in_DB?(link, time)
          # сбор ссылок, которые ещё не опубликованы
          links_arr << {link => time}
        end
      end

    else
      # сообщение о том, что вакансий на тек. стр. нет
      puts "none"
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

    Nokogiri::HTML(res.body, nil, Encoding::UTF_8.to_s)
  end


  def def_month month
    # возвращает цифру месяца
    # TODO: разобраться, почему не прокатило с case/when

    # я
    if month[0].bytes == [209, 143]
      1

    # ф
    elsif month[0].bytes == [209, 132]
      2

    # м
    elsif month[0].bytes == [208, 188]
      # р
      if month[2].bytes == [209, 128]
        3
      # я
      elsif month[2].bytes == [209, 143]
        5
      else
        raise "Month #{month} is not correct"
      end

    # а
    elsif month[0].bytes == [208, 176]
      # р
      if month[2].bytes == [209, 128]
        4
      # г
      elsif month[2].bytes == [208, 179]
        8
      else
        raise "Month #{month} is not correct"
      end

    # и
    elsif month[0].bytes == [208, 184]
      # н
      if month[2].bytes == [208, 189]
        6
      # л
      elsif month[2].bytes == [208, 187]
        7
      else
        raise "Month #{month} is not correct"
      end

    # с
    elsif month[0].bytes == [209, 129]
      9

    # о
    elsif month[0].bytes == [208, 190]
      10

    # н
    elsif month[0].bytes == [208, 189]
      11

    # д
    elsif month[0].bytes == [208, 180]
      12

    else
      raise "Month #{month} is not correct"
    end

  end

  def par_up
    @par += 1
  end
end

# File.open("lopata.txt", "w") do |i|
  # i.write(ev)
# end
