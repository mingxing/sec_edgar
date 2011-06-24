# sec_edgar_income_statement_spec.rb

$LOAD_PATH << './lib'
$LOAD_PATH << './specs'
require 'sec_edgar'
require 'sec_edgar_financial_statement_shared' # shared examples foor SecEdgar::FinancialStatement

describe SecEdgar::IncomeStatement do

  let(:create_fin_stmt) do

    @bogus_filename = "/tmp/ao0gqq34q34g"

    # load a primary one
    @good_filename = "specs/testvectors/google/2010_03_31.html"

    @tenq = SecEdgar::QuarterlyReport.new
    @tenq.log = Logger.new('sec_edgar.log')
    @tenq.log.level = Logger::DEBUG
    @tenq.parse(@good_filename)
    @fin_stmt = @tenq.inc_stmt

    # load a second one (to test merging, etc)
    @good_filename2 = "specs/testvectors/google/2011_03_31.html"

    @tenq2 = SecEdgar::QuarterlyReport.new
    @tenq2.log = Logger.new('sec_edgar.log')
    @tenq2.log.level = Logger::DEBUG
    @tenq2.parse(@good_filename2)
    @fin_stmt2 = @tenq2.inc_stmt

  end

  #it_should_behave_like 'SecEdgar::FinancialStatement' ## RE-ENABLE THIS LATER

  describe "#operating_revenue" do
    [ { :filename=>"specs/testvectors/apple/2010_03_27.html", 
        :operating_revenue=>13499.0 },
      { :filename=>"specs/testvectors/deere/2004_01_31.html",
        :operating_revenue=>3483.8 },
      { :filename=>"specs/testvectors/google/2009_09_30.html",
        :operating_revenue=>5541391.0 },
      { :filename=>"specs/testvectors/intel/2005_07_02.html",
        :operating_revenue=>9231.0 },
      { :filename=>"specs/testvectors/microsoft/2011_03_31.html",
        :operating_revenue=>16428.0 } ].each do |cur_test|

      it "returns the total revenues for #{cur_test[:filename]}" do
        reporting_period = 1

        @tenq = SecEdgar::QuarterlyReport.new
        @tenq.log = Logger.new('sec_edgar.log')
        @tenq.log.level = Logger::DEBUG
        @tenq.parse(cur_test[:filename])
        @tenq.inc_stmt.operating_revenue[reporting_period].should be_within(0.1).of(cur_test[:operating_revenue])
      end
    end
  end

  describe "#cost_of_revenue" do
    [ { :filename=>"specs/testvectors/apple/2010_03_27.html", 
        :cost_of_revenue=>7874.0 },
      { :filename=>"specs/testvectors/deere/2004_01_31.html",
        :cost_of_revenue=>2294.5 },
      { :filename=>"specs/testvectors/google/2009_09_30.html",
        :cost_of_revenue=>2173390.0 },
      { :filename=>"specs/testvectors/intel/2005_07_02.html",
        :cost_of_revenue=>4028.0 },
      { :filename=>"specs/testvectors/microsoft/2011_03_31.html",
        :cost_of_revenue=>3897.0 } ].each do |cur_test|

      it "returns the total expenses for #{cur_test[:filename]}" do
        reporting_period = 1

        @tenq = SecEdgar::QuarterlyReport.new
        @tenq.log = Logger.new('sec_edgar.log')
        @tenq.log.level = Logger::DEBUG
        @tenq.parse(cur_test[:filename])
        @tenq.inc_stmt.cost_of_revenue[reporting_period].should be_within(0.1).of(cur_test[:cost_of_revenue])
      end
    end
  end

  describe "#gross_margin" do
    [ { :filename=>"specs/testvectors/apple/2010_03_27.html" }, 
      { :filename=>"specs/testvectors/deere/2004_01_31.html" },
      { :filename=>"specs/testvectors/google/2009_09_30.html" },
      { :filename=>"specs/testvectors/intel/2005_07_02.html" },
      { :filename=>"specs/testvectors/microsoft/2011_03_31.html" } ].each do |cur_test|

      it "returns the total expenses for #{cur_test[:filename]}" do
        reporting_period = 1

        @tenq = SecEdgar::QuarterlyReport.new
        @tenq.log = Logger.new('sec_edgar.log')
        @tenq.log.level = Logger::DEBUG
        @tenq.parse(cur_test[:filename])
        gm = @tenq.inc_stmt.operating_revenue[reporting_period] - @tenq.inc_stmt.cost_of_revenue[reporting_period]
        @tenq.inc_stmt.gross_margin[reporting_period].should == gm
      end
    end
  end

  describe "#operating_expense" do
    [ { :filename=>"specs/testvectors/apple/2010_03_27.html", 
        :operating_expense=>1646.0 },
      { :filename=>"specs/testvectors/deere/2004_01_31.html",
        :operating_expense=>927.1 },
      { :filename=>"specs/testvectors/google/2009_09_30.html",
        :operating_expense=>1720436.0 },
      { :filename=>"specs/testvectors/intel/2005_07_02.html",
        :operating_expense=>2554.0 },
      { :filename=>"specs/testvectors/microsoft/2011_03_31.html",
        :operating_expense=>6822.0 } ].each do |cur_test|
  
      it "returns the total expenses for #{cur_test[:filename]}" do
        reporting_period = 1
  
        @tenq = SecEdgar::QuarterlyReport.new
        @tenq.log = Logger.new('sec_edgar.log')
        @tenq.log.level = Logger::DEBUG
        @tenq.parse(cur_test[:filename])
        @tenq.inc_stmt.operating_expense[reporting_period].should be_within(0.1).of(cur_test[:operating_expense])
      end
    end
  end

  describe "#operating_income_from_sales_before_tax" do
    [ { :filename=>"specs/testvectors/apple/2010_03_27.html", 
        :operating_income_from_sales_before_tax=>3979.0 },
      { :filename=>"specs/testvectors/deere/2004_01_31.html",
        :operating_income_from_sales_before_tax=>262.2 },
      { :filename=>"specs/testvectors/google/2009_09_30.html",
        :operating_income_from_sales_before_tax=>1647565.0 },
      { :filename=>"specs/testvectors/intel/2005_07_02.html",
        :operating_income_from_sales_before_tax=>2649.0 },
      { :filename=>"specs/testvectors/microsoft/2011_03_31.html",
        :operating_income_from_sales_before_tax=>5709.0 } ].each do |cur_test|
  
      it "returns the total income from sales (before tax) for #{cur_test[:filename]}" do
        reporting_period = 1
  
        @tenq = SecEdgar::QuarterlyReport.new
        @tenq.log = Logger.new('sec_edgar.log')
        @tenq.log.level = Logger::DEBUG
        @tenq.parse(cur_test[:filename])
        @tenq.inc_stmt.operating_income_from_sales_before_tax[reporting_period].should be_within(0.1).of(cur_test[:operating_income_from_sales_before_tax])
      end
    end
  end

  # operating income from sales (before tax)
  # operating income from sales (after tax)
  # other operating income (after tax)
  # operating income (after tax)
  # financing income
  # net income

  # operating revenues
  # gross margin
  # OI from sales (after tax)
  # OI (after tax)
  # financing income
  # comprehensive income

end
 
