class Hash

  # Symbolizes all of hash's keys and subkeys.
  # Also allows for custom pre-processing of keys (e.g. downcasing, etc)
  # if the block is given:
  #
  # somehash.deep_symbolize { |key| key.downcase }
  #
  # Copied from: https://gist.github.com/998709
  def deep_symbolize
    self.inject({}) do |result, (key, value)|
      value = value.deep_symbolize if value.is_a? Hash
      key = yield key if block_given?
      sym_key = key.to_sym rescue key
      result[sym_key] = value
      result
    end
  end

  # Deep merging of hashes
  # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
  def deep_merge!(other)
    merger = proc do |key, v1, v2|
      Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
    end
    self.merge! other, &merger
  end

end