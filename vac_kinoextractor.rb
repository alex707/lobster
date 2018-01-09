#===================================================================================================
#
# ������ ��������� ������ � ��������� ��:
# rss hh:
#
# @author: "���������� �.�. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2017-12-24
# @version = "0.0.1"
#
#===================================================================================================

require 'telegram/bot'
require 'sdbm'
require 'rss/2.0'

require "./set_env.rb"

donors_arr = [
  "235842",   # ������
  "34827",    # 20� ��� ����
  "90249",    # ������
  "578467",   # ��������
  "108855",   # ������� ����������
  "31672",    # ������
  "31647",    # ��������
  "2404145",  # ��������
  "574817",   # ���� �������
  "213729",   # ���������
  "1116814",  # �������� �������� ���
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

  # �������� �� ������������� � ��
  # �����. true, ���� ���.
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
  # ������� ��-�� � ��
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




# ����������� ��� � ����
# � �������� 15 �����
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
