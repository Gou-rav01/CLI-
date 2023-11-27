#!/usr/bin/env ruby

require 'csv'
require 'geocoder'
require 'titleize'

Geocoder.configure(lookup: :nominatim, timeout: 10)

class CsvProcessor
  def validate_row(row)
    
    # Validate conditions
    return false if row['Email'].to_s.empty? || row['First Name'].to_s.empty? || row['Last Name'].to_s.empty?
    return false if (row['Residential Address Street'].to_s.empty? || row['Residential Address Locality'].to_s.empty? || row['Residential Address State'].to_s.empty? || row['Residential Address Postcode'].to_s.empty?) || (row['Postal Address Street'].to_s.empty? || row['Postal Address Locality'].to_s.empty? || row['Postal Address State'].to_s.empty? || row['Postal Address Postcode'].to_s.empty?)
    residential_address = row['Residential Address Locality'].to_s + ',' + row['Residential Address State'].to_s
    return false unless validate_location?(residential_address, row['Residential Address Postcode'].to_s)
    postal_address = row['Postal Address Locality'].to_s + ',' + row['Postal Address State'].to_s
    return false unless  validate_location?(postal_address, row['Postal Address Postcode'].to_s)
    true
  end

  def validate_location?(locality, postal_code)
    #validate Address
    results = Geocoder.search("#{locality}, #{postal_code}")
    return  false if results&.empty?
    results.each do |result|
      if result.data['display_name'].include?(locality.split(',').first.titleize)
        return  !result.data['lat'].to_s.empty? && !result.data['lon'].to_s.empty?
      end
    end
  end

  def process_csv(file_data)
    # Process csv data
    output_rows = []
    CSV.parse(file_data, headers: true) do |row|
      @headers = row.headers
      if validate_row(row)
        output_rows << row
      end
    end
    {output_rows: output_rows, headers: @headers}
  end
end
