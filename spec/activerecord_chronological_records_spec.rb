require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiverecordChronologicalRecords do
  def make_employee(attributes)
    Employee.new(attributes).tap{ |e| e.id = 1; e.save! }
  end

  shared_examples "scopes" do
    specify { Employee.current.all.should eq [@current_record] }
    specify { Employee.effective_at(Date.today).should eq [@current_record] }
    specify { Employee.effective_at(Date.today - 2.months).should eq [@first_record] }
    specify { Employee.effective_at(Date.today + 2.months).should eq [@last_record] }
    specify { Employee.effective_at(Date.today - 2.years).should be_empty }
  end

  shared_examples "navigation methods" do
    specify { @first_record.current.should eq @current_record }
    specify { @first_record.effective_at(Date.today).should eq @current_record }
    specify { @first_record.effective_at(Date.today - 2.years).should be_nil }
    specify { @current_record.earliest.should eq @first_record }
    specify { @current_record.latest.should eq @last_record }
    specify { @current_record.previous.should eq @first_record }
    specify { @current_record.next.should eq @last_record }
  end

  shared_examples "helper methods" do
    specify { @current_record.should be_current }
    specify { @first_record.should_not be_current }
  end

  context "When start and end dates are present" do
    before(:all) do
      Employee.delete_all
      @first_record   = make_employee(:start_date => Date.today - 1.year, :end_date => Date.today - 1.month - 1.day)
      @current_record = make_employee(:start_date => Date.today - 1.month, :end_date => Date.today + 1.month)
      @last_record    = make_employee(:start_date => Date.today + 1.month + 1.day, :end_date => Date.today + 1.year)
    end

    include_examples "scopes"
    include_examples "navigation methods"
    include_examples "helper methods"

    specify { Employee.effective_at(Date.today + 1.year + 1.day).should be_empty }
  end

  context "When last record does not have end date" do
    before(:all) do
      Employee.delete_all
      @first_record   = make_employee(:start_date => Date.today - 1.year, :end_date => Date.today - 1.month - 1.day)
      @current_record = make_employee(:start_date => Date.today - 1.month, :end_date => Date.today + 1.month)
      @last_record    = make_employee(:start_date => Date.today + 1.month + 1.day, :end_date => nil)
    end

    include_examples "scopes"
    include_examples "navigation methods"
    include_examples "helper methods"
  end

  context "when used in join and colums with same name are defined on both tables" do
    before(:all) do
      Project.delete_all
      Employee.delete_all

      @project = Project.create

      @first_record   = make_employee(:project => @project, :start_date => Date.today - 1.year, :end_date => Date.today - 1.month - 1.day)
      @current_record = make_employee(:project => @project, :start_date => Date.today - 1.month, :end_date => Date.today + 1.month)
    end

    specify { expect { @project.employees.current.all }.not_to raise_error }
    specify { Employee.joins(:project).current.should eq [@current_record] }
    specify { Employee.joins(:project).effective_at(Date.today - 2.months).should eq [@first_record] }
  end

  context "dealing with inclusion" do
    before do
      Employee.delete_all
      Mood.delete_all
    end

    it "when end_date is date, current scope should include records that end today" do
      employee = make_employee(:start_date => Date.today - 1.day, :end_date => Date.today)
      sleep 1
      Employee.current.should eq [employee]
    end

    it "when end_date is time, current scope should include records that have ended" do
      mood = Mood.create(:start_time => Time.now - 1.minute, :end_time => Time.now)
      sleep 1
      Mood.current.should be_empty
    end
  end
end
