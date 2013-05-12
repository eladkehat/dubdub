COMMANDS = %w( import parse probe generate )
opts = Trollop::options do
  opt :env, "Environment; one of: development, test, production", :default => 'development'
  opt :root, "Root directory of the application", :default => File.absolute_path(File.join(File.dirname(__FILE__), '..'))
  opt :file, "Input file with text to parse", :type => :string
  opt :str,  "String to parse", :type => :string
end

require 'dubdub/config/config.rb'
Dubdub::Config.config do
  parameters *opts.keys
  opts.each do |key, value|
    send key, value
  end
end

require 'yaml'
require 'dubdub/util/deep_actions'
require 'dubdub/util/files'
require 'dubdub/names'
require 'dubdub/name_parser'
require 'dubdub/name_tokenizer'
require 'dubdub/stop_words'

def parse_names(str)
  name_parser = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(str))
  { :input => str, 
    :names => name_parser.parse_names, 
    :offsets => name_parser.name_offsets, }
end

str = if opts[:str]
  opts[:str]
elsif opts[:file]
  File.read(opts[:file])
end

unless str
  puts "No input supplied. Please provide an input string or a file name."
  exit(1)
end

Dubdub::Names.load!
Dubdub::StopWords.load!

res = parse_names(str)
puts res.inspect
