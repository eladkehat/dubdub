require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
