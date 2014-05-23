require 'simplecov'
require 'coveralls'

DATA_DIR = File.join(File.dirname(__FILE__), 'data')

def data_path(file_name)
  File.join(DATA_DIR, file_name)
end

class SimpleFormatter
  def format(result)
    puts "Coverage: #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleFormatter,
    Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
end
require 'rspec'
require 'digest/sha1'

require 'easytag'

