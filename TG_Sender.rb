#===================================================================================================
#
# Класс для работы с TG
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-27
# @version = "0.1.0"
#
#===================================================================================================

require 'telegram/bot'

class TG_Sender
  def initialize bot_token, channel_token
   if bot_token.nil?
      puts "Bot is not set."
      exit 0
    end

    if !channel_token.nil? && (/@[a-z]/ =~ channel_token) == 0
    else
      puts "Channel is not set."
      exit 0
    end

    @bot_token      = bot_token
    @channel_token  = channel_token
  end

  def tg_send(message)
    Telegram::Bot::Client.run(@bot_token) do |bot|
      if bot.api.sendMessage(chat_id: "#{@channel_token}", text: message, parse_mode: "HTML")
        puts "Message was send successful.\n"
        true
      else
        puts "Message was not send. See log."
        false
      end
    end
  end

end
