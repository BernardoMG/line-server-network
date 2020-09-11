require 'spec_helper'
require 'mock_redis'
require 'file_manager'
require_relative '../../interactors/line_retriever'

RSpec.describe LineRetriever do 
  before(:all) do
    @file_manager = FileManager.new('spec/data/random_file.txt')
    @file_manager.collect_byte_offsets_for_each_line
  end

  it 'returns a failed response due to invalid line number' do
    result = LineRetriever.run(@file_manager, 0)

    expect(result[:status]).to eq(422)
    expect(result[:message]).to eq('Invalid parameter.')
  end

  it 'returns a failed response due to a line number that is beyond the end of the file' do
    result = LineRetriever.run(@file_manager, 1000)

    expect(result[:status]).to eq(413)
    expect(result[:message]).to eq('Requested line is beyond the end of the file.')
  end

  it 'returns a success response' do
    redis_instance = MockRedis.new
    Redis.stub(:new).and_return(redis_instance)

    result = LineRetriever.run(@file_manager, 2)

    expect(result[:status]).to eq(200)
    expect(result[:message]).to eq("TDAeFw0xOTA4MzExOTQ0NDdaFw0yOTA4MjgxOTQ0NDdaMA0xCzAJBgNVBAYTAlBM\n")
  end

  it 'returns a success response for a cached line' do
    redis_instance = MockRedis.new
    redis_instance.set('line_2', "TDAeFw0xOTA4MzExOTQ0NDdaFw0yOTA4MjgxOTQ0NDdaMA0xCzAJBgNVBAYTAlBM\n")
    Redis.stub(:new).and_return(redis_instance)

    result = LineRetriever.run(@file_manager, 2)

    expect(result[:status]).to eq(200)
    expect(result[:message]).to eq("TDAeFw0xOTA4MzExOTQ0NDdaFw0yOTA4MjgxOTQ0NDdaMA0xCzAJBgNVBAYTAlBM\n")
  end
end

