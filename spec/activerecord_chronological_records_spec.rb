require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordChronologicalRecords" do
  def make_employee(attributes)
    Employee.new(attributes).tap{ |e| e.id = 1; e.save! }
  end

  context "When start and end dates are present" do
    before(:all) do
      Employee.rebuild_table do |t|
        t.date :start_date
        t.date :end_date
      end

      Employee.has_chronological_records :start_date, :end_date

      @first_record   = make_employee(start_date: Date.today - 1.year, end_date: Date.today - 1.month - 1.day)
      @current_record = make_employee(start_date: Date.today - 1.month, end_date: Date.today + 1.month)
      @last_record    = make_employee(start_date: Date.today + 1.month + 1.day, end_date: Date.today + 1.year)
    end

    context "scopes" do
      specify { Employee.current.all.should eq [@current_record] }
      specify { Employee.at(Date.today).all.should eq [@current_record] }
      specify { Employee.at(Date.today - 2.months).all.should eq [@first_record] }
      specify { Employee.at(Date.today + 2.months).all.should eq [@last_record] }
    end

    context "navigation methods" do
      specify { @first_record.current.should eq @current_record }
      specify { @first_record.at(Date.today).should eq @current_record }
      specify { @current_record.earliest.should eq @first_record }
      specify { @current_record.latest.should eq @last_record }
      specify { @current_record.previous.should eq @first_record }
      specify { @current_record.next.should eq @last_record }
    end

    context "helper methods" do
      specify { @current_record.should be_current }
      specify { @first_record.should_not be_current }
    end
  end
end
