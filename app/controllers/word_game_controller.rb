require 'open-uri'
require 'json'
require 'time'

class WordGameController < ApplicationController

  def game
    @grid = generate_grid(9)

  end

  def score
    @start_time = params[:start_time].to_f
    @end_time = Time.now.tv_sec.to_f
    @attempt = params[:query]
    p @grid = params[:grid].split(" ")

    @start_time_alt = Time.parse(params[:start_time_alt])
    @end_time_alt = Time.now

    run_game
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game
    @result = { time: @end_time - @start_time }
    @result[:time_alt] = @end_time_alt - @start_time_alt

    @result[:translation] = get_translation
    @result[:score], @result[:message] = score_and_message(
      @result[:translation], @result[:time])

    # result
  end

  def get_translation
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{@attempt.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

  def score_and_message(translation, time)
    if translation
      if included?(@attempt.upcase)
        score = compute_score(time)
        [score, "well done"]
      else
        [0, "not in the grid"]
      end
    else
      [0, "not an english word"]
    end
  end

  def included?(guess)
    the_grid = @grid.clone
    guess.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    @grid.size == guess.size + the_grid.size
  end

  def compute_score(time_taken)
    (time_taken > 60.0) ? 0 : @attempt.size * (1.0 - time_taken / 60.0)
  end

end
