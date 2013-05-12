require 'set'

module Dubdub::StopWords
  extend self # singleton
  include Dubdub::Util

  def load!
    env = Dubdub::Config.env
    filename = File.join(Dubdub::Config.root, 'config', 'res.yml')
    @settings = YAML::load_file(filename)[Dubdub::Config.env].deep_symbolize
    @settings[:stop_words].each_key {|key| load_file key }
  end

  def load_file(key)
    filename = File.join(Dubdub::Config.root, @settings[:files][key])
    words = load_terms_file(filename)
    attr_accessor key
    self.send "#{key}=".to_sym, words
  end

  def stop_word?(str)
    @settings[:files].each_key do |key|
      if self.send(key).include?(str)
        return true
      end
    end
    false
  end

  # First names that should be ignored
  # e.g. foreign first names that are common words in English
  def first_name_stop?(str)
    first_name_stop_words.include? str
  end

  # Last names that should be ignored
  # e.g. foreign last names that are common words in English
  def last_name_stop?(str)
    last_name_stop_words.include? str
  end

end
