require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dubdub::StopWords do
  describe "#load!" do
    before(:all) do
      Dubdub::StopWords.load!
    end

    it "should create accessible sets for each stopwords file" do
      Dubdub::StopWords.first_name_stop_words.should be_a(Set)
      Dubdub::StopWords.last_name_stop_words.should be_a(Set)
    end

  end

  describe "#first_name_stop?" do
    context "when checking a string that isn't a first name stop word" do
      it "should be false" do
        Dubdub::StopWords.first_name_stop?('notafirstnamestop').should be_false
      end
    end

    context "when checking a string that is a first name stop word" do
      it "should return true" do
        Dubdub::StopWords.first_name_stop?('be').should be_true
      end
    end
  end

  describe "#last_name_stop?" do
    context "when checking a string that isn't a last name stop word" do
      it "should be false" do
        Dubdub::StopWords.last_name_stop?('notafirstnamestop').should be_false
      end
    end

    context "when checking a string that is a last name stop word" do
      it "should return true" do
        Dubdub::StopWords.last_name_stop?('love').should be_true
      end
    end
  end
end
