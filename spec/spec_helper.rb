$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'active_record'
require 'activerecord_chronological_records'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Base.establish_connection(
  :adapter => defined?(JRUBY_VERSION) ? "jdbcsqlite3": "sqlite3",
  :database => "#{File.dirname(__FILE__)}/activerecord_chronological_records.db"
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :projects, :force => true do |t|
    t.date :start_date
    t.date :end_date
  end

  create_table :employees, :force => true, :id => false do |t|
    t.integer :id
    t.references :project
    t.date :start_date
    t.date :end_date
  end

  create_table :moods, :force => true, :id => false do |t|
    t.integer :id
    t.references :employee
    t.datetime :start_time
    t.datetime :end_time
  end
end

class Project < ActiveRecord::Base
  has_many :employees
end

class Employee < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :project
  has_many :moods

  has_chronological_records
end

class Mood < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :employee

  has_chronological_records :start_time, :end_time
end