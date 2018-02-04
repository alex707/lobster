#===================================================================================================
#
# Скрипт Запускает бота на обработку каналов
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-14
# @version = "0.2.0"
#
#===================================================================================================


require "./set_env.rb"
require "./EventsTP_KEBot.rb"
require "./EventsTVKR_KEBot.rb"
require "./VacsHH_KEBot.rb"
require "./VacsTVKR_KEBot.rb"


# верю, надеюсь, жду
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
  "85848",    # Арт Пикчерс Студия
  "1185297",  # Всемирные Русские Студии
  "609694",   # Star Media Группа компаний
  "970302",   # ТПО Киностудия им.М.Горького
  "962026",   # Киностудия Союзмультфильм ФГУП ТПО
  "910572",   # Ленпродакшн фильм
  "125249",   # ЛЕОПОЛИС
  "136916",   # Пирамида
  "592111",   # Кинокомпания СТВ
  "73462",    # Продюсерский центр Андрея Кончаловского
  "2481588",  # Наше Кино
  "951258",   # Sony Pictures Television
]


def exec_parsing
  puts "#{Time.now}_B_VacsHH_KEBot"
  donors_arr.each do |ll|
    link = "https://hh.ru/search/vacancy/rss?no_magic=true&employer_id=#{ll}&isAutosearch=true"
    a = VacsHH_KEBot.new link, "hh"
    a.sync
  end
  sleep 60
  puts "#{Time.now}_E_VacsHH_KEBot"


  puts "#{Time.now}_B_EventsTVKR_KEBot"
  a = EventsTVKR_KEBot.new 1
  a.sync
  sleep 60
  puts "#{Time.now}_E_EventsTVKR_KEBot"


  puts "#{Time.now}_B_VacsTVKR_KEBot"
  a = VacsTVKR_KEBot.new 6
  a.sync
  sleep 60
  puts "#{Time.now}_E_VacsTVKR_KEBot"


  puts "#{Time.now}_B_EventsTP_KEBot"
  link = "https://api.timepad.ru/v1/events.json?limit=50&skip=0&fields=location,description_short&category_ids=374&sort=+starts_at"
  a = EventsTP_KEBot.new link, "tpad"
  a.sync
  sleep 60
  puts "#{Time.now}_E_EventsTP_KEBot"
end

# выполнение скриптов
exec_parsing
