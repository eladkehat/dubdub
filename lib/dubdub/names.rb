module Dubdub::Names
  extend self # singleton
  include Dubdub::Util

  def load!
    env = Dubdub::Config.env
    filename = File.join(Dubdub::Config.root, 'config', 'res.yml')
    @settings = YAML::load_file(filename)[Dubdub::Config.env].deep_symbolize
    @settings[:files].each_key {|key| load_names_file key }
    @settings[:stop_words].each_key {|key| load_stopwords_file key }
  end

  def load_names_file(key)
    settings = @settings[:files][key]
    path = File.join(Dubdub::Config.root, settings[:path])
    names = settings[:freq] ? load_term_frequencies_file(path) : load_terms_file(path)
    attr_accessor key
    self.send "#{key}=".to_sym, names
  end

  def load_stopwords_file(key)
    path = File.join(Dubdub::Config.root, @settings[:stop_words][key])
    words = load_terms_file(path)
    attr_accessor key
    self.send "#{key}=".to_sym, words
  end

  def name?(str)
    res = []
    [:first_names, :last_names].each do |key|
      if freq = self.send(key)[str]
        res << [key, freq]
      end
    end
    res
  end

  def first_name?(str)
    first_names[str]
  end

  def last_name?(str)
    last_names[str]
  end

  def last_name_prefix?(str)
    last_name_prefixes.include? str
  end

  def initial?(str)
    str =~ /^[A-Za-z]$/
  end

  def prefix?(str)
    prefixes.include? str
  end

  def suffix?(str)
    suffixes.include? str
  end

end
