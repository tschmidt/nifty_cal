require 'date'

# NiftyCal
#
# Since I am not satisfied with any other calendaring solutions out there I am going
# to roll my own. This calendaring solution will take a start date and an end date.
# Obviously the start date should exist before the end date. You may also pass a block
# that will populate the column for the day specified.
module NiftyCal
  
  # Version Number is major.minor.bugfix
  VERSION = '0.1.0'
  
  # Set Defaults for the calendar
  DEFAULT_OPTIONS = {
    :table_class        => 'calendar',
    :this_month_class   => 'currentMonth',
    :other_month_class  => 'otherMonth',
    :day_name_class     => 'dayName',
    :day_class          => 'weekDay',
    :weekend_day_class  => 'weekendDay',
    :title_class        => 'calendar_title',
    :title_text         => "#{Date::MONTHNAMES[Date.today.month]} #{Date.today.year}",
    :include_weekends   => true,
    :abbrev             => (0..2),
    :show_today         => true,
    :start_date         => Date.today.beginning_of_month,
    :end_date           => Date.today.end_of_month,
  }
  
  DAY_NAMES = Date::DAYNAMES.dup
  
  def display_calendar(options = {}, &block)
    block ||= Proc.new {|data| nil}    
    options = DEFAULT_OPTIONS.merge(options)
    raise(ArgumentError, ":start_date must come before :end_date") unless options[:start_date] <= options[:end_date]
    
    # Make sure we are only working with Date object
    options[:start_date] = options[:start_date].is_a?(DateTime) ? options[:start_date].to_date : options[:start_date]
    options[:end_date]   = options[:end_date].is_a?(DateTime) ? options[:end_date].to_date : options[:end_date]
    
    # Only for finger saving
    @first_day = options[:start_date]
    @last_day = options[:end_date]
    pad_last_day unless enough_days? == 0
    @total_days = @last_day.yday - @first_day.yday
    @content = block
    
    create_calendar options
  end
  
  private
  
    def create_calendar(options = {})
      cal = options[:title_text].blank? ? "" : "<h2 class=#{options[:title_class]}>#{options[:title_text]}</h2>"
      cal << %(<table class="#{options[:table_class]}">)
      cal << %(<thead><tr>)
      
      @day_names = DAY_NAMES.dup
      @first_day.wday.times do
        @day_names.push(@day_names.shift)
      end
      
      @day_names.reject! {|day_name| day_name if %w(Saturday Sunday).include?(day_name) } unless options[:include_weekends]
      
      @day_names.each do |day_name|
        cal << %(<th class="#{options[:day_name_class]}">#{day_name[options[:abbrev]]}</th>)
      end
      
      cal << "</tr></thead><tbody>"
      
      (@total_days / 7).times do |week_number|
        week_number += 1
        cal << "<tr>"
        
        all_days = []
        (@first_day..@last_day).each {|day| all_days.push day}
        
        min = ((week_number - 1) * 7)
        max = min + 6
        min.upto(max) do |num|
          unless options[:include_weekends]
            next if weekend?(all_days[num])
          end
          class_names = []
          
          # When the block is passed it can be an array with the first entry the content
          # for the day and the second hash with the key :class. For example:
          #   ["<p>This is the text</p>", {:class => "event"}]
          content, attrs = @content.call(all_days[num])
          class_names.push attrs[:class] if attrs and attrs.has_key?(:class)
          class_names.push Date.today.month == all_days[num].month ? options[:this_month_class] : options[:other_month_class]
          class_names.push weekend?(all_days[num]) ? options[:weekend_day_class] : options[:day_class]
          class_names.push all_days[num] == Date.today ? "today" : ''
          cal << %(<td class="#{class_names.join(' ')}"><span>#{format_day(all_days[num])}</span>#{content}</td>)
        end
        
        cal << "</tr>"
      end
      
      cal << "</tbody></table>"
    end
    
    def enough_days?
      (@first_day.yday - @last_day.yday) % 7
    end
    
    def padded_days
      enough_days?
    end
    
    def pad_last_day
      @last_day = @last_day + padded_days.days
    end
    
    def weekend?(date)
      [0,6].include?(date.wday)
    end
    
    def format_day(date)
      if date == Date.today
        "Today"
      else
        first_of_the_month?(date)
      end
    end
    
    def first_of_the_month?(date)
      if date.beginning_of_month == date
        "#{Date::MONTHNAMES[date.month]} #{date.day}"
      else
        "#{date.day}"
      end
    end
    
end