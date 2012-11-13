module ActiverecordChronologicalRecords
  def has_chronological_records(*options)
    if options.empty?
      start_column, end_column = :start_date, :end_date
    else
      start_column, end_column = options[0], options[1]
    end

    query_start_column = "#{table_name}.#{start_column}"
    query_end_column   = "#{table_name}.#{end_column}"
    same_record_lookup = "#{self}.where(:#{primary_key} => self.#{primary_key})"

    self.instance_eval <<-EOS
      def effective_at(date)
        where("(#{query_start_column} <= :date OR #{query_start_column} IS NULL) AND (#{query_end_column} >= :date OR #{query_end_column} IS NULL)", :date => date)
      end

      def current
        effective_at(Time.now)
      end
EOS

    self.class_eval <<-EOS
      def effective_at(date)
        #{same_record_lookup}.effective_at(date).first
      end

      def earliest
        #{same_record_lookup}.order("#{query_start_column} ASC").first
      end

      def latest
        #{same_record_lookup}.order("#{query_start_column} DESC").first
      end

      def previous
        effective_at(#{start_column} - 1.day)
      end

      def next
        effective_at(#{end_column} + 1.day)
      end

      def current
        effective_at(Time.now)
      end

      def current?
        (#{start_column}.blank? || #{start_column}.to_time <= Time.now) && (#{end_column}.blank? || #{end_column}.to_time >= Time.now)
      end
EOS
  end
end

ActiveRecord::Base.extend ActiverecordChronologicalRecords