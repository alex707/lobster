#===================================================================================================
#
# ������ ��������� ���� �� ��������� �������
#
# @author: "���������� �.�. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-14
# @version = "0.2.0"
#
#===================================================================================================


require "./set_env.rb"
require "./EventsTP_KEBot.rb"
require "./EventsTVKR_KEBot.rb"
require "./VacsHH_KEBot.rb"
require "./VacsTVKR_KEBot.rb"


# ����, �������, ���
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
  "85848",    # ��� ������� ������
  "1185297",  # ��������� ������� ������
  "609694",   # Star Media ������ ��������
  "970302",   # ��� ���������� ��.�.��������
  "962026",   # ���������� �������������� ���� ���
  "910572",   # ����������� �����
  "125249",   # ��������
  "136916",   # ��������
  "592111",   # ������������ ���
  "73462",    # ������������ ����� ������ �������������
  "2481588",  # ���� ����
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

# ���������� ��������
exec_parsing
