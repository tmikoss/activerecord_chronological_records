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

class Employee < ActiveRecord::Base
  self.primary_key = :id

  def self.rebuild_table
    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :employees, :force => true, :id => false do |t|
        t.integer :id
        yield t
      end
    end
  end
end