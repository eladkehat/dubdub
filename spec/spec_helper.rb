require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rspec'

require 'dubdub/config/config.rb'
Dubdub::Config.config do
  parameters :env, :root
  env 'test'
  root File.absolute_path(File.join(File.dirname(__FILE__), '..'))
end

require 'dubdub/util/deep_actions'
require 'dubdub/util/files'
require 'dubdub/names'
require 'dubdub/name_parser'
require 'dubdub/name_tokenizer'
require 'dubdub/stop_words'
