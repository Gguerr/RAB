#!/usr/bin/env ruby

# Test script to verify PDF generation
require_relative 'config/environment'

# Create a test date
date = Date.current
employees = Employee.active.order(:names, :surnames).limit(5)

puts "Testing PDF generation..."
puts "Date: #{date.strftime('%d/%m/%Y')}"
puts "Employees count: #{employees.count}"

# Test the PDF generation method
begin
  controller = Admin::AttendancesController.new
  controller.instance_variable_set(:@date, date)
  controller.instance_variable_set(:@employees, employees)
  
  pdf_data = controller.send(:generate_physical_form_pdf)
  
  puts "✅ PDF generated successfully!"
  puts "PDF size: #{pdf_data.length} bytes"
  
  # Save test PDF
  File.open("test_planilla.pdf", "wb") do |f|
    f.write(pdf_data)
  end
  
  puts "✅ Test PDF saved as 'test_planilla.pdf'"
  
rescue => e
  puts "❌ Error generating PDF: #{e.message}"
  puts e.backtrace.first(5)
end
