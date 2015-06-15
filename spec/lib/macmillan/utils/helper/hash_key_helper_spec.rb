require 'spec_helper'

describe Macmillan::Utils::Helper::HashKeyHelper do
  include Macmillan::Utils::Helper::HashKeyHelper

  describe '#convert_keys_to_snakecase_and_symbols' do
    context 'when it is a flat hash' do
      let(:example) do
        { 'aKey' => 'woo', '_debug' => {} }
      end

      let(:expected) do
        { a_key: 'woo', _debug: {} }
      end

      it 'converts all the keys to snake_case and symbols' do
        result = convert_keys_to_snakecase_and_symbols(example)
        expect(result).to eq(expected)
      end
    end

    context 'a hash containing child hashes' do
      let(:example) do
        { 'aKey' => { 'someKey' => 'woo', 'someKey2' => 'woo' } }
      end

      let(:expected) do
        { a_key: { some_key: 'woo', some_key2: 'woo' } }
      end

      it 'converts all the keys to snake_case and symbols' do
        result = convert_keys_to_snakecase_and_symbols(example)
        expect(result).to eq(expected)
      end
    end

    context 'a hash containing arrays of hashes as values' do
      let(:example) do
        {
          'aKey' => [
            { 'someKey' => 'woo' },
            { 'someKey2' => 'waa' }
          ]
        }
      end

      let(:expected) do
        {
          a_key: [
            { some_key: 'woo' },
            { some_key2: 'waa' }
          ]
        }
      end

      it 'converts all the keys to snake_case and symbols' do
        result = convert_keys_to_snakecase_and_symbols(example)
        expect(result).to eq(expected)
      end
    end

    context 'with a monster' do
      let(:example) do
        {
          'aKey' => [
            { 'someKey' => 'woo' },
            { 'someKey2' => 'waa' },
            [
              { 'someKey' => 'woo' },
              {
                'argh' => [
                  { 'someKey' => 'woo' }
                ]
              }
            ]
          ]
        }
      end

      let(:expected) do
        {
          a_key: [
            { some_key: 'woo' },
            { some_key2: 'waa' },
            [
              { some_key: 'woo' },
              {
                argh: [
                  { some_key: 'woo' }
                ]
              }
            ]

          ]
        }
      end

      it 'converts all the keys to snake_case and symbols' do
        result = convert_keys_to_snakecase_and_symbols(example)
        expect(result).to eq(expected)
      end
    end
  end

  describe '#convert_key_to_singular' do
    context 'when the key is :summaries' do
      let(:key) { :summaries }

      it 'converts the key to :summary' do
        expect(convert_key_to_singular(key)).to eq(:summary)
      end
    end

    context 'when the key is NOT :summaries' do
      let(:articles_key)              { :articles }
      let(:primary_article_types_key) { :primary_article_types }

      it 'converts the key to singular' do
        expect(convert_key_to_singular(articles_key)).to eq(:article)
        expect(convert_key_to_singular(primary_article_types_key)).to eq(:primary_article_type)
      end
    end
  end
end
