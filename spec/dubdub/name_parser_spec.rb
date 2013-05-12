require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
