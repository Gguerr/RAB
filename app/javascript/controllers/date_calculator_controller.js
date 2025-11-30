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
      const currentDate = new Date()
      const currentYear = currentDate.getFullYear()
      const hireYear = hireDate.getFullYear()
      
      let vacationDate
      
      // Si la fecha de ingreso es anterior al año actual, calcular para el año actual
      if (hireYear < currentYear) {
        // Usar el mismo día y mes de la fecha de ingreso, pero del año actual
        // SIEMPRE usar el año actual, sin importar si la fecha ya pasó
        vacationDate = new Date(currentYear, hireDate.getMonth(), hireDate.getDate())
      } else {
        // Si la fecha de ingreso es del año actual o futuro, calcular 1 año después
        vacationDate = new Date(hireDate)
        vacationDate.setFullYear(vacationDate.getFullYear() + 1)
      }
      
      // Format the date as YYYY-MM-DD for the input field
      const formattedDate = vacationDate.toISOString().split('T')[0]
      
      // Set the vacation date
      this.vacationDateTarget.value = formattedDate
    } catch (error) {
      console.error('Error calculating vacation date:', error)
    }
  }
}

