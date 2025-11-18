class Attendance < ApplicationRecord
  belongs_to :employee

  validates :attendance_date, presence: true
  validates :employee_id, uniqueness: { scope: :attendance_date, message: "ya tiene registro de asistencia para esta fecha" }

  scope :for_date, ->(date) { where(attendance_date: date) }
  scope :for_month, ->(year, month) { where(attendance_date: Date.new(year, month, 1)..Date.new(year, month, -1)) }
  scope :for_year, ->(year) { where(attendance_date: Date.new(year, 1, 1)..Date.new(year, 12, 31)) }
  scope :present, -> { where(present: true) }
  scope :absent, -> { where(present: false) }
  scope :recent, -> { order(attendance_date: :desc) }

  def self.mark_all_present(date)
    Employee.active.each do |employee|
      attendance = find_or_initialize_by(employee: employee, attendance_date: date)
      attendance.present = true
      attendance.save
    end
  end

  def self.mark_all_absent(date)
    Employee.active.each do |employee|
      attendance = find_or_initialize_by(employee: employee, attendance_date: date)
      attendance.present = false
      attendance.save
    end
  end

  def self.daily_summary(date)
    attendances = for_date(date)
    {
      total: attendances.count,
      present: attendances.present.count,
      absent: attendances.absent.count,
      attendance_rate: attendances.count > 0 ? (attendances.present.count.to_f / attendances.count * 100).round(2) : 0
    }
  end

  def self.monthly_summary(year, month)
    attendances = for_month(year, month)
    {
      total_days: attendances.count,
      present_days: attendances.present.count,
      absent_days: attendances.absent.count,
      attendance_rate: attendances.count > 0 ? (attendances.present.count.to_f / attendances.count * 100).round(2) : 0
    }
  end

  def self.yearly_summary(year)
    attendances = for_year(year)
    {
      total_days: attendances.count,
      present_days: attendances.present.count,
      absent_days: attendances.absent.count,
      attendance_rate: attendances.count > 0 ? (attendances.present.count.to_f / attendances.count * 100).round(2) : 0
    }
  end
end


