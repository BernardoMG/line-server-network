class FileManager
  def initialize(filename = 'config/random_file.txt')
    @filename = filename
    @byte_indexes = []
    @line_counter = 0
  end

  def collect_byte_offsets_for_each_line
    file = File.open(@filename)
    @byte_indexes[0] = 0

    file.each_line do |line|
      @byte_indexes.push(file.tell)
      @line_counter += 1
    end
  end

  def retrieve_line_from_file(line_number)
    previous_line_byte_offset = @byte_indexes[line_number - 1]
    byte_interval_requested = @byte_indexes[line_number] - previous_line_byte_offset
    IO.binread(@filename, byte_interval_requested, previous_line_byte_offset)
  end

  def invalid_line_number?(line_number)
    !(line_number.positive? && line_number <= @line_counter)
  end

  def line_number_beyond_the_end_of_the_file?(line_number)
    line_number > @line_counter
  end
end 