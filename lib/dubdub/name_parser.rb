module Dubdub::Names

  # Try to locate names in the given string.
  # Returns the offsets of name occurances.
  class NameParser
    def initialize(tokenizer)
      @tokenizer = tokenizer
      @names = []
      @state = nil
      @name = []
    end

    def parse_names
      while @token = @tokenizer.next_token
        action = @state || :idle
        self.send action
      end
      if [:first_or_last, :last, :suffix].include? @state
        add_name
      end
      @names
    end

    def name_offsets
      @names.map do |name|
        # offset of first part until offset of last part + length of last part
        [name[0][1], name[-1][1] + name[-1][0].length - name[0][1]]
      end
    end

    private

    def add_name
      @names << @name
      reset
    end

    # transition to the given state
    def transition(state, add_token_to_name = true)
      @state = state
      @name << @token if add_token_to_name
    end

    # reset the state machine
    def reset
      @state = nil
      @name = []
    end

    def idle
      if Dubdub::Names.initial? @token.first
        transition :initial
      elsif Dubdub::Names.first_name? @token.first
        transition Dubdub::Names.last_name?(@token.first) ? :first_or_last : :first
      elsif Dubdub::Names.last_name? @token.first
        transition :last
      end
    end

    def initial
      if Dubdub::Names.initial? @token.first
        transition :initial
      elsif @token.first == '.'
        ; # do nothing, just consume the token
      elsif Dubdub::Names.first_name? @token.first
        transition Dubdub::Names.last_name?(@token.first) ? :first_or_last : :first
      elsif Dubdub::Names.last_name? @token.first
        transition :last
      else
        reset
      end
    end

    def first
      if Dubdub::Names.initial? @token.first
        transition :initial
      elsif Dubdub::Names.first_name? @token.first
        transition Dubdub::Names.last_name?(@token.first) ? :first_or_last : :first
      elsif Dubdub::Names.last_name? @token.first
        transition :last
      else
        reset
      end
    end

    def last
      if Dubdub::Names.last_name? @token.first
        transition :last
      elsif @token.first == '-'
        ; # do nothing, just consume the token
      elsif @token.first == ','
        transition :suffix, false
      else
        add_name
      end
    end

    def first_or_last
      if Dubdub::Names.initial? @token.first
        transition :initial
      elsif Dubdub::Names.first_name? @token.first
        transition Dubdub::Names.last_name?(@token.first) ? :first_or_last : :first
      elsif Dubdub::Names.last_name? @token.first
        transition :last
      elsif @token.first == '-'
        transition :last, false
      elsif @token.first == ','
        transition :suffix, false
      else
        add_name
      end
    end

    def suffix
      if Dubdub::Names.suffix? @token.first
        @name << @token
      else
        @tokenizer.unget_token @token.first
      end
      add_name
    end

  end
  
end
