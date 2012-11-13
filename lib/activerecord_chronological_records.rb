module ActiverecordChronologicalRecords
  def has_chronological_records(*options)
    if options.empty?
      start_column, end_column = :start_date, :end_date
    else
      start_column, end_column = options[0], options[1]
    end

    self.instance_eval <<-EOS
      def at(date)
        where("(#{start_column} <= :date OR #{start_column} IS NULL) AND (#{end_column} >= :date OR #{end_column} IS NULL)", :date => date)
      end

      def current
        at(Time.now)
      end
EOS

    self.class_eval <<-EOS
      def at(date)
        #{self}.at(date).where(:#{primary_key} => self.#{primary_key}).first
      end

      def current
        at(Time.now)
      end

      def current?
        (#{start_column}.blank? || #{start_column}.to_time <= Time.now) && (#{end_column}.blank? || #{end_column}.to_time >= Time.now)
      end

      def earliest
        #{self}.where(:#{primary_key} => self.#{primary_key}).order("#{start_column} ASC").first
      end

      def latest
        #{self}.where(:#{primary_key} => self.#{primary_key}).order("#{start_column} DESC").first
      end

      def previous
        at(#{start_column} - 1.day)
      end

      def next
        at(#{end_column} + 1.day)
      end
EOS
  end
end

ActiveRecord::Base.extend ActiverecordChronologicalRecords