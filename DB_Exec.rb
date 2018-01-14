#===================================================================================================
#
# Класс для работы с БД
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-14
# @version = "0.1.0"
#
#===================================================================================================

require 'sdbm'

class DB_Exec
  def initialize link_name
    @db = SDBM.new("#{link_name}_db")

    @db.nil? ? raise('DB Error') : @db
  end

  # проверка на существование в БД
  # возвр. true, если сущ.
  def check_exists_in_DB? (link, pubDate)
    exists = false

    @db.select do |kLink, vPubDate|
      if kLink == link && vPubDate.to_i == pubDate.to_i
        exists = true
        break
      end
    end

    exists
  end

  # вставка эл-та в бд
  def insert_to_DB (link, pubDate)
    @db[link] = pubDate.to_s
  end

end
