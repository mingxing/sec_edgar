# sec_edgar_quarterly_report_spec.rb

$LOAD_PATH << './lib'
require 'sec_edgar'

describe SecEdgar::QuarterlyReport do

  before(:each) do
    @bogus_filename = "/tmp/ao0gqq34q34g"
    @good_filename = "specs/testvectors/2010_03_31.html"
    @tenq = SecEdgar::QuarterlyReport.new
  end
   
  describe "#parse" do
    it "returns false if file doesn't exist or file doesn't contain quarterly report" do
      @tenq.parse(@bogus_filename).should == false
    end
    it "returns true if file exists and contains quarterly report" do
      @tenq.parse(@good_filename).should == true
    end
    it "creates a balance sheet if success" do
      @tenq.parse(@good_filename)
      @tenq.bal_sheet.class.should == SecEdgar::BalanceSheet
    end
    it "creates an income statement if success" do
      @tenq.parse(@good_filename)
      @tenq.inc_stmt.class.should == SecEdgar::IncomeStatement
    end
    it "creates a cash flow statement if success" do
      @tenq.parse(@good_filename)
      @tenq.cash_flow_stmt.class.should == SecEdgar::CashFlowStatement
    end
  end

  describe "#normalize" do
    it "does nothing if you haven't parsed anything yet" do
      # FIXME
    end
    it "normalizes the financial statements if you've parsed them" do
      # FIXME
    end
  end

end

