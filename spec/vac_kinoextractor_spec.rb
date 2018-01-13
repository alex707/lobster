#===================================================================================================
#
# Скрипт тестирования класса Vac_KEBot
#
# @author: "Григоренко А.О. (mailto:alex.grigorenko2942@yandex.ru)"
# @date: 2017-12-29
# @version = "0.0.1"
#
#===================================================================================================

require_relative '../vac_kinoextractor.rb'
require 'sdbm'

describe Vac_KEBot do
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

    # элемент для проверки на его обновление
    @test_3_vPubDate  = "1514405900"
    # SDBM.open "#{@link_name}_db" do |db|
      # db.update("#{@test_1_kLink}" => @test_3_vPubDate)
    # end
  end


  # "Должно найти имеющийся элемент в БД и вернуть true"
  it "should to find existing elem in db and return true" do
    a = Vac_KEBot.new(@link, @link_name, "-")
      .check_exists_in_DB?(@test_1_kLink, @test_1_vPubDate)
    expect( a ).to be true
  end

  # Должен вставить новый элемент в бд. Вернуть true.
  it "should to insert not existing elem in db. should be true" do
    Vac_KEBot.new(@link, @link_name, "-")
      .insert_to_DB(@test_2_kLink, @test_2_vPubDate)

    a = Vac_KEBot.new(@link, @link_name, "-")
      .check_exists_in_DB?(@test_2_kLink, @test_2_vPubDate)
    expect( a ).to be true
  end

end