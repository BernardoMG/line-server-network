require 'spec_helper'
require 'file_manager'

RSpec.describe FileManager do 
  before(:all) do
    @file_manager = FileManager.new('spec/data/random_file.txt')
    @file_manager.collect_byte_offsets_of_each_line
  end

  it 'returns the requested line' do
    result = @file_manager.retrieve_line_from_file(2)

    expect(result[:success]).to be true
    expect(result[:line]).to eq("TDAeFw0xOTA4MzExOTQ0NDdaFw0yOTA4MjgxOTQ0NDdaMA0xCzAJBgNVBAYTAlBM\n")
  end

  it 'returns error due to invalid line' do
    result = @file_manager.retrieve_line_from_file(0)

    expect(result[:success]).to be false
    expect(result[:message]).to eq('Invalid parameter.')
    expect(result[:status]).to eq(422)
  end

  it 'returns error due to a request for a line beyond the end of the file' do
    result = @file_manager.retrieve_line_from_file(1000)

    expect(result[:success]).to be false
    expect(result[:message]).to eq('Requested line is beyond the end of the file.')
    expect(result[:status]).to eq(413)
  end
end