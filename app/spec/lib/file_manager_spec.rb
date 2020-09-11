require 'spec_helper'
require 'file_manager'

RSpec.describe FileManager do 
  before(:all) do
    @file_manager = FileManager.new('spec/data/random_file.txt')
    @file_manager.collect_byte_offsets_for_each_line
  end

  it 'returns the requested line' do
    line = @file_manager.retrieve_line_from_file(2)

    expect(line).to eq("TDAeFw0xOTA4MzExOTQ0NDdaFw0yOTA4MjgxOTQ0NDdaMA0xCzAJBgNVBAYTAlBM\n")
  end

  it 'should collect all byte offsets' do
    # file has 44 lines
    line = @file_manager.retrieve_line_from_file(44)

    expect(line).to eq("1K77y7FOJPh3vIikjSwV04jMnrC8zxoYDHDTIbdh1raQTjT44AQoumYlwzXjA8aO")
  end

  it 'returns invalid line number for 0 value' do
    result = @file_manager.invalid_line_number?(0)

    expect(result).to be true
  end

  it 'returns valid line number' do
    result = @file_manager.line_number_beyond_the_end_of_the_file?(5)

    expect(result).to be false
  end

  it 'returns invalid when line number is beyond the end of the file' do
    result = @file_manager.line_number_beyond_the_end_of_the_file?(10000)

    expect(result).to be true
  end
end