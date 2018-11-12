require 'spec_helper'

module Spree
  module Mollie
    RSpec.describe MoneyFormatter do
      let(:test_class) do
        Class.new do
          include MoneyFormatter

          def display_total
            Spree::Money.new(14_308.86, currency: 'USD')
          end

          def formatted_money
            format_money(display_total.money)
          end
        end
      end

      describe '.format_money_methods' do
        context 'with currency USD' do
          it 'returns money as a string' do
            expect(test_class.new.formatted_money).to eq '14308.86'
          end
        end

        context 'with currency EUR' do
          before do
            test_class.class_eval do
              def display_total
                Spree::Money.new(14_308.86, currency: 'EUR')
              end
            end
          end

          it 'returns money as a string' do
            expect(test_class.new.formatted_money).to eq '14308.86'
          end
        end

        context 'with currency JPY' do
          before do
            test_class.class_eval do
              def display_total
                Spree::Money.new(14_308.86, currency: 'JPY')
              end
            end
          end

          it 'returns money as a string' do
            expect(test_class.new.formatted_money).to eq '14309'
          end
        end
      end
    end
  end
end
