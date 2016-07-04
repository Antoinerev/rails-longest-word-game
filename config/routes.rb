Rails.application.routes.draw do

  root to: 'word_game#game'
  get 'game', to: 'word_game#game'

  get 'score', to: 'word_game#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
