require 'sinatra'
require './lib/file_manager'
require 'byebug'

set :port, 8080
set :bind, '0.0.0.0'

manager = FileManager.new
manager.collect_byte_offsets_of_each_line

get '/lines/:index' do
  content_type :json

  # Checks cache

  # Reads File
  result = manager.retrieve_line_from_file(params[:index].to_i)

  # Update cache if does not exist

  if result[:success]
    status 200
    return result[:line]
  else
    status result[:status]
    return result[:message]
  end

rescue StandardError => ex
  status 500
  return 'Something went wrong. Please try again or contact support team.'
end