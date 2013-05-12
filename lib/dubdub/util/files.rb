module Dubdub::Util

  module ClassMethods

    # Load a file with terms into a Set.
    # Loads one term per line.
    def load_terms_file(path)
      terms = Set.new
      IO.foreach(path) do |term|
        term.chomp!
        terms << term unless term.empty?
      end
      terms
    end

    # Load a file with terms and their frequency into a Hash.
    # Loads one pair (freq, term) per line. the Hash maps the term to its freq.
    def load_term_frequencies_file(path)
      terms = {}
      IO.foreach(path) do |line|
        if line =~ /^\s*(\d+)\s([a-z]+)\s*$/
          terms[$2] = $1.to_i
        end
      end
      terms
    end

  end # ClassMethods

  extend ClassMethods
  def self.included(other)
    other.extend(ClassMethods)
  end

end
