module Admin::AttendancesHelper
  def attendance_status_badge(present)
    if present
      content_tag :span, '✅ Presente', class: 'inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800'
    else
      content_tag :span, '❌ Ausente', class: 'inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800'
    end
  end

  def attendance_rate_badge(rate)
    badge_class = case rate
    when 90..100
      'bg-green-100 text-green-800'
    when 80...90
      'bg-yellow-100 text-yellow-800'
    else
      'bg-red-100 text-red-800'
    end

    content_tag :span, "#{rate}%", class: "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium #{badge_class}"
  end

  def month_name(month_number)
    Date::MONTHNAMES[month_number]
  end

  def format_attendance_date(date)
    date.strftime("%d/%m/%Y")
  end

  def format_attendance_datetime(datetime)
    datetime.strftime("%d/%m/%Y %H:%M")
  end

  def attendance_summary_stats(summary)
    {
      total: summary[:total] || summary[:total_days],
      present: summary[:present] || summary[:present_days],
      absent: summary[:absent] || summary[:absent_days],
      rate: summary[:attendance_rate]
    }
  end

  def calendar_day_class(date, current_month, attendances)
    base_class = "aspect-square border border-gray-200 rounded-lg p-2"
    
    if date.month != current_month
      "#{base_class} bg-gray-50"
    elsif attendances.any?
      "#{base_class} bg-blue-50"
    else
      base_class
    end
  end

  def attendance_trend_icon(current_rate, previous_rate)
    return '📊' if previous_rate.nil?
    
    if current_rate > previous_rate
      '📈'
    elsif current_rate < previous_rate
      '📉'
    else
      '➡️'
    end
  end
end


