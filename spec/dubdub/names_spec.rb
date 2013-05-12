require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dubdub::Names do
  describe "#load!" do
    before(:all) do
      Dubdub::Names.load!
    end

    it "creates accessible hashes for each names file" do
      Dubdub::Names.first_names.should be_a(Hash)
      Dubdub::Names.last_names.should be_a(Hash)
    end

    it "creates accessible sets for stop words" do
      Dubdub::Names.first_name_stop_words.should be_a(Set)
      Dubdub::Names.last_name_stop_words.should be_a(Set)
    end

    it "loads names and frequencies into @first_names" do
      Dubdub::Names.first_names['mark'].should == 318499
    end

    it "loads names and frequencies into @last_names" do
      Dubdub::Names.last_names['lewis'].should == 61907
    end
  end

  describe "#name?" do
    context "when checking a string that isn't a name" do
      it "returns an empty array" do
        Dubdub::Names.name?('nosuchname').should be_empty
      end
    end

    context "when checking a string that is a first name" do
      it "returns a :first_name, frequency pair" do
        Dubdub::Names.name?('jim').should == [[:first_names, 263284]]
      end
    end

    context "when checking a string that is a last name" do
      it "returns a :last_name, frequency pair" do
        Dubdub::Names.name?('anderson').should == [[:last_names, 107962]]
      end
    end

    context "when checking a string that is both a first and a last name" do
      it "returns two name type, frequency pairs" do
        Dubdub::Names.name?('lee').should == [[:first_names, 49451],[:last_names, 99930]]
      end
    end
  end

  describe "#first_name?" do
    context "when checking a string that isn't a first name" do
      it "returns nil" do
        Dubdub::Names.first_name?('nosuchfirstname').should be_nil
      end
    end

    context "when checking a string that is a first name" do
      it "returns it's frequency" do
        Dubdub::Names.first_name?('jim').should == 263284
      end
    end
  end

  describe "#last_name?" do
    context "when checking a string that isn't a last name" do
      it "returns nil" do
        Dubdub::Names.last_name?('nosuchlastname').should be_nil
      end
    end

    context "when checking a string that is a last name" do
      it "returns it's frequency" do
        Dubdub::Names.last_name?('anderson').should == 107962
      end
    end
  end

  describe "#prefix?" do
    context "when checking a string that isn't a prefix" do
      it "should be false" do
        Dubdub::Names.prefix?('notaprefix').should be_false
      end
    end

    context "when checking a string that is a prefix" do
      it "should be true" do
        Dubdub::Names.prefix?('mr').should be_true
      end
    end
  end

  describe "#suffix?" do
    context "when checking a string that isn't a suffix" do
      it "should be false" do
        Dubdub::Names.suffix?('notasuffix').should be_false
      end
    end

    context "when checking a string that is a suffix" do
      it "should be true" do
        Dubdub::Names.suffix?('jr').should be_true
      end
    end
  end

  describe "#initial?" do
    context "when given a single lowercase letter" do
      it "should be true" do
        Dubdub::Names.initial?('a').should be_true
      end
    end
    context "when given a single uppercase letter" do
      it "should be true" do
        Dubdub::Names.initial?('A').should be_true
      end
    end
    context "when given more than a single letter" do
      it "should be false" do
        Dubdub::Names.initial?('ab').should be_false
      end
    end
    context "when given something other than a letter" do
      it "should be false" do
        Dubdub::Names.initial?('*').should be_false
        Dubdub::Names.initial?('.').should be_false
      end
    end
  end
end

describe Dubdub::Names::NameParser do
  before(:all) do
    Dubdub::Names.load!
  end

  describe "#parse_names" do
    context "when given a string with no names in it" do
      before :each do
        s = "NOTICE: Sixth Circuit Rule 24(c) states that citation of unpublished dispositions is disfavored except for establishing res judicata, estoppel, or the law of the case and requires service of copies of cited unpublished dispositions of the Sixth Circuit."
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns an empty array" do
        @p.parse_names.should be_empty
      end
    end

    context "when given a string with a name like <first> <middle> <last>" do
      before :each do
        s = "John Paul JONES, Appellant,"
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns the name and offsets" do
        @p.parse_names.first.map(&:first).should == %w( john paul jones )
        @p.parse_names.first.map(&:last).should == [0, 5, 10]
      end
    end

    context "when given a string with a name like <first> <initial>. <last>" do
      before :each do
        s = "James A. MOORE, et al., Plaintiffs-Appellants,"
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns the name and offsets" do
        @p.parse_names.first.map(&:first).should == %w( james a moore )
        @p.parse_names.first.map(&:last).should == [0, 6, 9]
      end
    end

    context "when given a string with a name like <first> <initial> <last>, <suffix>" do
      before :each do
        s = "James J. Moore, Jr. Appellant."
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns the name and offsets" do
        @p.parse_names.first.map(&:first).should == %w( james j moore jr )
        @p.parse_names.first.map(&:last).should == [0, 6, 9, 16]
      end
    end

    context "when given a string with just a last name" do
      before :each do 
        s = "Taylor,"
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns the last name and its offset" do
        @p.parse_names.first.should == [['taylor', 0]]
      end
    end

    context "when given a string with two names" do
      before :each do
        s = "James A. MOORE and John Johnson, Plaintiffs-Appellants,"
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns the two names and offsets" do
        @p.parse_names.should == [[['james', 0], ['a',6],['moore',9]],[['john',19],['johnson',24]]]
      end
    end

    context "when given a string with multiple last names" do
      before :each do
        s = "Before THOMPSON, WHITE and JACKSON, Circuit Judges."
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
      end
      it "returns the last names and offsets" do
        @p.parse_names.should == [[['thompson',7]], [['white',17]], [['jackson',27]]]
      end
    end
   end

  describe "#name_offsets" do
    context "when given a string with no names in it" do
      before :each do
        s = "NOTICE: Sixth Circuit Rule 24(c) states that citation of unpublished dispositions is disfavored except for establishing res judicata, estoppel, or the law of the case and requires service of copies of cited unpublished dispositions of the Sixth Circuit."
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
        @p.parse_names
      end
      it "returns an empty array" do
        @p.name_offsets.should be_empty
      end
    end

    context "when given a string with a single name in it" do
      before :each do
        s = "John Paul JONES, Appellant,"
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
        @p.parse_names
      end
      it "returns the name's beginning and length" do
        @p.name_offsets.should == [[0,15]]
      end
    end

    context "when given a string with a name that has a suffix" do
      before :each do
        s = "James J. Moore, Jr. Appellant."
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
        @p.parse_names
      end
      it "returns the name's beginning and length, including the suffix" do
        @p.name_offsets.should == [[0,18]]
      end
    end

    context "when given a string with two names" do
      before :each do
        s = "James A. MOORE and John Johnson, Plaintiffs-Appellants,"
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
        @p.parse_names
      end
      it "returns the two names' beginning offsets and length" do
        @p.name_offsets.should == [[0,14], [19,12]]
      end
    end

    context "when given a string with multiple last names" do
      before :each do
        s = "Before THOMPSON, WHITE and JACKSON, Circuit Judges."
        @p = Dubdub::Names::NameParser.new(Dubdub::Names::NameTokenizer.new(s))
        @p.parse_names
      end
      it "returns the last names' beginning offsets and lengths" do
        @p.name_offsets.should == [[7,8], [17,5], [27,7]]
      end
    end
   end
end

describe Dubdub::Names::NameTokenizer do
  describe "#next_token" do
    context "when given a single word" do
      before(:each) { @t = Dubdub::Names::NameTokenizer.new('word') }
      it "returns it and its offset" do
        @t.next_token.should == ['word', 0]
      end
      it "returns nil after it" do
        @t.next_token
        @t.next_token.should be_nil
      end
    end

    context "when given words separated by spaces" do
      before(:each) { @t = Dubdub::Names::NameTokenizer.new("one 2 three o'clock") }
      it "returns each word and offset in turn, then nil" do
        offset = 0
        %w( one 2 three o'clock ).each do |word|
          @t.next_token.should == [word, offset]
          offset += word.length + 1
        end
        @t.next_token.should be_nil
      end
    end

    context "when given mixed-case words" do
      before(:each) { @t = Dubdub::Names::NameTokenizer.new("One 2 tHRee O'Clock") }
      it "returns lower-case tokens" do
        %w( one 2 three o'clock ).each {|word| @t.next_token.first.should == word }
      end
    end

    context "when given words separated by separators" do
      before(:each) { @t = Dubdub::Names::NameTokenizer.new('one two, three-four. f. six seven.') }
      it "returns the words and separators in order, with their offsets, then nil" do
        [['one',0],['two',4],[',',7],['three',9],['-',14],['four',15],['.',19],['f',21],['.',22],['six',24],['seven',28],['.',33]].each do |token|
          @t.next_token.should == token
        end
        @t.next_token.should be_nil
      end
    end

    context "when given words, separators and other characters" do
      before(:each) { @t = Dubdub::Names::NameTokenizer.new('one&two * (three), four-five.') }
      it "returns the words and separators with offsets and ignores other characters" do
        [['one',0],['two',4],['three',11],[',',17],['four',19],['-',23],['five',24],['.',28]].each do
          |token| @t.next_token.should == token
        end
        @t.next_token.should be_nil
      end
    end
  end

  describe "#unget_token" do
    it "returns the tokenizer to a state where the next #get_token returns the same token" do
      t = Dubdub::Names::NameTokenizer.new('one&two * (three), four-five.')
      8.times do 
        token = t.next_token
        t.unget_token token.first
        t.next_token.should == token
      end
    end
  end
end
