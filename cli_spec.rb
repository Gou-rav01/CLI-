
require './csv_processor'
require 'rspec'

RSpec.describe 'CsvProcessor' do
  let(:processor) { CsvProcessor.new }

  before do
    # Stub the Geocoder.search call for a valid address
    result = Geocoder.search("AMBLESIDE, TAS, 7310")

    allow(Geocoder).to receive(:search).with("AMBLESIDE, TAS, 7310").and_return(result)
    #   [instance_double("Geocoder::Result::Nominatim", data: {'lat' => '-41.2050163', 'lon' => '146.3748003', 'display_name' => 'Ambleside, Devonport, City of Devonport, Tasmania, 7310, Australia'})]
    # end
  
    # Stub the Geocoder.search call for an invalid address
    allow(Geocoder).to receive(:search).with("TEST AMBLESIDE, TAS, 12345").and_return([])
  end

  describe '#validate_location?' do
    it 'returns false for a valid location and postcode' do
      expect(processor.validate_location?('AMBLESIDE, TAS', '7310')).to be true
    end

    it 'returns false for an invalid location and postcode' do
      expect(processor.validate_location?('TEST AMBLESIDE, TAS','12345')).to be false
    end
  end
end