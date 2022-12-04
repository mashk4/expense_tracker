# frozen-string-literal: true

require 'sinatra/base'
require 'json'

module ExpenseTracker
  class API < Sinatra::Base
    post '/expenses' do
      JSON.generate('expense_id' => rand(10))
    end

    get '/expenses/:date' do
      JSON.generate([])
    end
  end
end
