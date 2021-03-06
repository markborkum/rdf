require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::Query::Variable do
  context ".new(:x)" do
    before :each do
      @var = RDF::Query::Variable.new(:x)
    end

    it "is named" do
      @var.named?.should be_true
      @var.name.should == :x
    end

    it "has no value" do
      @var.value.should be_nil
    end
    
    context "distinguished" do
      subject {@var}
      it "is distinguished" do
        subject.should be_distinguished
      end

      it "can be made non-distinguished" do
        subject.distinguished = false
        subject.should_not be_distinguished
      end

      it "has a string representation" do
        subject.to_s.should == "?x"
      end
    end
    
    context "non-distinguished" do
      subject { @var.distinguished = false; @var }
      it "is nondistinguished" do
        subject.should_not be_distinguished
      end

      it "can be made distinguished" do
        subject.distinguished = true
        subject.should be_distinguished
      end

      it "has a string representation" do
        subject.to_s.should == "??x"
      end
    end
    
    it "is convertible to a symbol" do
      @var.to_sym.should == :x
    end


    it "has no value" do
      @var.value.should be_nil
    end

    it "is unbound" do
      @var.unbound?.should be_true
      @var.bound?.should be_false
      @var.variables.should == {:x => @var}
      @var.bindings.should == {}
    end

    describe "#==" do
      it "matches any Term" do
        [RDF::URI("foo"), RDF::Node.new, RDF::Literal("foo"), @var].each do |value|
          @var.should == value
        end
      end

      it "does not match non-terms" do
        [nil, true, false, 123].each do |value|
          @var.should_not == value
        end
      end
    end

    describe "#eql?" do
      it "matches any Term" do
        [RDF::URI("foo"), RDF::Node.new, RDF::Literal("foo"), @var].each do |value|
          @var.should be_eql value
        end
      end

      it "does not match non-terms" do
        [nil, true, false, 123].each do |value|
          @var.should_not be_eql value
        end
      end
    end

    describe "#===" do
      it "matches any Term" do
        [RDF::URI("foo"), RDF::Node.new, RDF::Literal("foo"), @var].each do |value|
          (@var === value).should be_true
        end
      end

      it "does not match non-terms" do
        [nil, true, false, 123].each do |value|
          (@var === value).should be_false
        end
      end
    end
  end

  context ".new(:x, 123)" do
    before :each do
      @var = RDF::Query::Variable.new(:x, RDF::Literal(123))
    end

    it "has a value" do
      @var.value.should == RDF::Literal(123)
    end

    it "is bound" do
      @var.unbound?.should be_false
      @var.bound?.should be_true
      @var.variables.should == {:x => @var}
      @var.bindings.should == {:x => RDF::Literal(123)}
    end

    it "matches only its value" do
      [nil, true, false, RDF::Literal(456)].each do |value|
        (@var === value).should be_false
      end
      (@var === RDF::Literal(123)).should be_true
    end

    it "has a string representation" do
      @var.to_s.should == "?x=123"
    end
  end

  context "when rebound" do
    before :each do
      @var = RDF::Query::Variable.new(:x, RDF::Literal(123))
    end

    it "returns the previous value" do
      @var.bind(RDF::Literal(456)).should == RDF::Literal(123)
      @var.bind(RDF::Literal(789)).should == RDF::Literal(456)
    end

    it "is still bound" do
      @var.bind!(RDF::Literal(456))
      @var.unbound?.should be_false
      @var.bound?.should be_true
    end
  end

  context "when unbound" do
    before :each do
      @var = RDF::Query::Variable.new(:x, RDF::Literal(123))
    end

    it "returns the previous value" do
      @var.unbind.should == RDF::Literal(123)
      @var.unbind.should == nil
    end

    it "is not bound" do
      @var.unbind!
      @var.unbound?.should be_true
      @var.bound?.should be_false
    end
  end
end
