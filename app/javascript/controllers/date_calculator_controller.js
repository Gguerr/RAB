import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hireDate", "vacationDate"]

  connect() {
    // Calculate vacation date if hire date is already set
    if (this.hireDateTarget.value) {
      this.calculateVacationDate()
    }
  }

  calculateVacationDate() {
    const hireDateValue = this.hireDateTarget.value
    
    if (!hireDateValue) {
      this.vacationDateTarget.value = ""
      return
    }

    try {
      // Parse the hire date
      const hireDate = new Date(hireDateValue)
      
      // Add exactly one year
      const vacationDate = new Date(hireDate)
      vacationDate.setFullYear(vacationDate.getFullYear() + 1)
      
      // Format the date as YYYY-MM-DD for the input field
      const formattedDate = vacationDate.toISOString().split('T')[0]
      
      // Set the vacation date
      this.vacationDateTarget.value = formattedDate
    } catch (error) {
      console.error('Error calculating vacation date:', error)
    }
  }
}

