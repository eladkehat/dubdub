require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hash do
  describe "#deep_symbolize" do
    it "symbolizes keys" do
      h1 = {'a'=>1,'b'=>'c'}
      h1.deep_symbolize.should eql({:a=>1,:b=>'c'})
    end

    it "deep-symbolizes keys" do
      h1 = {'a'=>1,'b'=>{'c'=>{'d'=>'e'},'f'=>['g',:h]}}
      h1.deep_symbolize.should eql({:a=>1,:b=>{:c=>{:d=>'e'},:f=>['g',:h]}})
    end
  end

  describe "#deep_merge!" do
    it "merges a one-layer hash" do
      h1 = {a:1,b:2}
      h2 = {a:3,c:3}
      h1.deep_merge!(h2).should eql({a:3,b:2,c:3})
    end

    it "merges a n-layer hash" do
      h1 = {a:1,b:2,c:{d:5,e:{f:6}}}
      h2 = {a:3,c:{e:{g:7},h:8}}
      h1.deep_merge!(h2).should eql({a:3,b:2,c:{d:5,e:{f:6,g:7},h:8}})
    end
  end
end