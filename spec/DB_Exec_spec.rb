#===================================================================================================
#
# Скрипт тестирования класса DB_Exec
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2018-01-13
# @version = "0.1.0"
#
#===================================================================================================

require_relative '../DB_Exec.rb'
require 'sdbm'

describe DB_Exec do
  before(:all) do
    @link = "https://hh.ru/search/vacancy/rss?no_magic=true&employer_id=235842&isAutosearch=true"
    @link_name = "hh"

    # элемент для проверки на его существование
    @test_1_kLink     = "https://hh.ru/vacancy/23948514"
    @test_1_vPubDate  = "1514405844"      # 2017-12-27 23:17:24 +0300

    SDBM.open "#{@link_name}_db" do |db|
      db[@test_1_kLink] = @test_1_vPubDate
    end


    # элемент для проверки на его удаление
    @test_2_kLink     = "https://hh.ru/vacancy/23948550"
    @test_2_vPubDate  = "1514405850"

    SDBM.open "#{@link_name}_db" do |db|
      db.delete(@test_2_kLink)
    end
  end


  # "Должен найти имеющийся элемент в БД и вернуть true"
  it "should to find existing elem in db and return true" do
    db  = DB_Exec.new(@link_name)
    a   = db.check_exists_in_DB?(@test_1_kLink, @test_1_vPubDate)
    expect( a ).to be true
  end

  # Должен вставить новый элемент в бд. Вернуть true.
  it "should to insert not existing elem in db. should be true" do
    db  = DB_Exec.new(@link_name)
    db.insert_to_DB(@test_2_kLink, @test_2_vPubDate)

    a   = db.check_exists_in_DB?(@test_2_kLink, @test_2_vPubDate)
    expect( a ).to be true
  end
end
