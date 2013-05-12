module Dubdub::Names

  class NameTokenizer
    WORD_CHARS = (('a'..'z').to_a + ('0'..'9').to_a + ["'"]).join
    SEP_CHARS = ",.-"

    def initialize(s)
      @s = s.downcase
      @pos = 0
    end

    def next_token
      if @pos >= @s.length
        return nil
      elsif SEP_CHARS.include? @s[@pos]
        @pos += 1
        return [@s[@pos-1], @pos-1]
      elsif WORD_CHARS.include? @s[@pos]
        mark = @pos
        @pos += 1 while WORD_CHARS.include?(@s[@pos] || 'nil')
        return [@s[mark...@pos], mark]
      else
        @pos += 1
        next_token
      end
    end

    def unget_token(token)
      @pos -= token.to_s.length
    end

  end

end
