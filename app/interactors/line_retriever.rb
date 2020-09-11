require_relative '../services/cache/redis_manager'

class LineRetriever
  attr_reader :file_manager, :line_number

  def initialize(file_manager, line_number)
    @file_manager = file_manager
    @line_number = line_number
  end

  def self.run(file_manager, line_number)
    self.new(file_manager, line_number).run
  end

  def run
    # line number validation
    if file_manager.invalid_line_number?(line_number)
      return build_response_for_invalid_line_number
    end

    # Checks cache
    cache = RedisManager.new
    line_cached = cache.get_value("line_#{line_number}")

    if line_cached.nil?
      # Gets the requested line
      line = file_manager.retrieve_line_from_file(line_number)

      # Update cache
      cache.set_key_value_pair("line_#{line_number}", line)

      build_success_response(line)
    else
      build_success_response(line_cached)
    end
  end

  private

  def build_response_for_invalid_line_number
    if file_manager.line_number_beyond_the_end_of_the_file?(line_number)
      { message: 'Requested line is beyond the end of the file.', status: 413 }
    else
      { message: 'Invalid parameter.', status: 422 }
    end
  end

  def build_success_response(line)
    { message: line, status: 200 }
  end
end