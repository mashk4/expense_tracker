# frozen-string_literal: true

require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    let(:app) { described_class.new(ledger: ledger) }
    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:expense) { { 'some' => 'data' } }
    let(:parsed_body) { JSON.parse(last_response.body) }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))

          post '/expenses', JSON.generate(expense)
        end

        it 'responds with a 200' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the expense id' do
          expect(parsed_body).to include('expense_id' => 417)
        end
      end

      context 'when the expense fails validation' do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))

          post '/expenses', JSON.generate(expense)
        end

        it 'responds with 422' do
          expect(last_response.status).to eq(422)
        end

        it 'returns an error message' do
          expect(parsed_body).to include('errors' => 'Expense incomplete')
        end
      end
    end

    describe 'GET /expenses/:date' do
      let(:expense) do
        {
          'id' => 25,
          'payee' => 'Coffee',
          'amount' => 2.25,
          'date' => '2022-10-13'
        }
      end

      context 'when expenses exist on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2022-10-13')
            .and_return([expense])

          get '/expenses/2022-10-13'
        end

        it 'responds with 200' do
          expect(last_response.status).to eq(200)
        end

        it 'returns the expense records as JSON' do
          expect(parsed_body).to include(include('date' => '2022-10-13'))
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2022-12-26').and_return([])

          get 'expenses/2022-12-26'
        end

        it 'responds with 200' do
          expect(last_response.status).to eq(200)
        end

        it 'returns an empty array as JSON' do
          expect(parsed_body).to eq([])
        end
      end
    end
  end
end
