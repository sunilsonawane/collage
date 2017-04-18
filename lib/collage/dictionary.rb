module Collage
  class Dictionary
    attr_accessor :dict_filename

    def initialize(dict_filename = nil)
      self.dict_filename = dict_filename || '/usr/share/dict/words'
    end

    def read_file_lines
      IO.readlines(dict_filename)
    end

    def random_word
      lines = read_file_lines
      number  = Random.new.rand(1..lines.count).to_i
      lines[number].chomp
    end
  end
end