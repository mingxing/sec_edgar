module SecEdgar

  class IncomeStatement < FinancialStatement
    attr_accessor :revenues
    attr_accessor :operating_revenue

    def initialize
      super()
      @name = "Income Statement"

      @revenues = [] # array of rows
      @operating_revenue = [] # array of floats
    end

    def parse(edgar_fin_stmt)
      # pull the table into rows (akin to CSV)
      return false if not super(edgar_fin_stmt)

      # text-matching to pull out dates, net amounts, etc.
      parse_reporting_periods
  
      # restate it
      return false if not parse_income_stmt_state_machine
    end

  private

    def parse_reporting_periods
      # pull out the date ranges
      @rows.each_with_index do |row, idx|
  
        # Match [X Months Ended  September 30,][Y Months Ended   June 30,]
        #       [2003][2004][2003][2004]
        if String(row[0].text).downcase.match(/months[^A-Za-z]*ended/) and
           String(row[1].text).downcase.match(/months[^A-Za-z]*ended/) then
          @rows[idx].insert(1,"")
          @rows[idx].insert(0,"")
          @rows[idx+1].insert(0,"")
  
        # Match [Month Ended]
        #       [Mar 1, 2003][Mar 1, 2004]
        elsif String(row[0].text).downcase.match(/month.*ended/) then
          if row.length < 2 then
            @rows[idx].concat(@rows[idx+1])
            @rows.delete_at(idx+1)
          end
  
        # Match [Year Ended]
        #       [Mar 1, 2003][Mar 1, 2004]
        elsif String(row[0].text).downcase.match(/year.*ended/) then
          if row.length < 2 then
            @rows[idx].concat(@rows[idx+1])
            @rows.delete_at(idx+1)
          end
        end
      end
    end

    def parse_income_stmt_state_machine
      
      @state = :waiting_for_revenues
      @rows.each do |cur_row|
        @log.debug("income statement parser.  Cur label: #{cur_row[0].text}") if @log
        @next_state = nil
        case @state
        when :waiting_for_revenues
          if !cur_row[0].nil? and cur_row[0].text.downcase =~ /(net sales|net revenue|revenue)/
            if cur_row[1].val.nil? #  there's a list of individual revenue line items cominng
              @next_state = :reading_revenues
            else # there's no lst of revenues coming, just the total on this line
              @operating_revenue = cur_row.collect { |x| x.val || nil }
              @next_state = :done
            end
          else
            # ignore
          end

        when :reading_revenues
          if !cur_row[0].nil? and cur_row[0].text.downcase =~ /total/
              @operating_revenue = cur_row.collect { |x| x.val || nil }
            @next_state = :done
          else
            @revenues.push cur_row
          end

        when :done
          # ignore

        else
          @log.error("Income statement parser state machine.  Got into weird state, #{@state}") if @log
          return false
        end

        if !@next_state.nil?
          @log.debug("Income statement parser.  Switching to state: #{@next_state}") if @log
          @state = @next_state
        end
      end

      if @state != :done
        @log.warn("Balance sheet parser state machine.  Unexpected final state, #{@state}") if @log
        return false
      end

      return true
    end

  end
    
end
