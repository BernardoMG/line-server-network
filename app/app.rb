require 'sinatra'
require './lib/file_manager'
require './interactors/line_retriever'

set :port, 8080
set :bind, '0.0.0.0'
configure { set :server, :puma }

manager = FileManager.new
manager.collect_byte_offsets_for_each_line

get '/lines/:index' do
  content_type :json
  line_number = params[:index].to_i

  result = LineRetriever.run(manager, line_number)
  status result[:status]
  return result[:message]
rescue StandardError => ex
  status 500
  return 'Something went wrong. Please try again or contact support team.'
end