import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]
  static values = { 
    index: Number,
    prefix: String
  }

  connect() {
    this.indexValue = this.containerTarget.children.length
    
    // Initialize existing account type fields
    this.element.querySelectorAll('.account-type-select').forEach(select => {
      this.toggleAccountFields(select)
    })
    
    // Initialize existing education level fields
    this.element.querySelectorAll('select[name*="[education_level]"]').forEach(select => {
      this.toggleSpecificGradeFields(select)
    })
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.indexValue)
    const wrapper = document.createElement('div')
    wrapper.innerHTML = content
    
    const newElement = wrapper.firstElementChild
    this.containerTarget.appendChild(newElement)
    
    // Initialize account type fields for the new element
    const accountSelect = newElement.querySelector('.account-type-select')
    if (accountSelect) {
      this.toggleAccountFields(accountSelect)
    }
    
    // Initialize education level fields for the new element
    const educationSelect = newElement.querySelector('select[name*="[education_level]"]')
    if (educationSelect) {
      this.toggleSpecificGradeFields(educationSelect)
    }
    
    this.indexValue++
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest('[data-nested-item]')
    
    if (!item) {
      console.log('No nested item found')
      return
    }
    
    // Check if this is an existing record (has an ID field) or a new one
    const destroyField = item.querySelector('.destroy-field')
    const idField = item.querySelector('input[name*="[id]"]')
    
    if (destroyField && idField && idField.value) {
      // Existing record: mark for destruction but keep in DOM (hidden)
      destroyField.value = '1'
      item.style.display = 'none'
      console.log('Marked existing record for destruction')
    } else {
      // New record: remove from DOM immediately
      item.remove()
      console.log('Removed new record from DOM')
    }
  }


  toggleAccountType(event) {
    this.toggleAccountFields(event.target)
  }

  toggleAccountFields(selectElement) {
    const container = selectElement.closest('[data-nested-item]')
    if (!container) {
      console.log('No container found for account fields toggle')
      return
    }
    
    const bankFields = container.querySelectorAll('.bank-fields')
    const mobileFields = container.querySelectorAll('.mobile-fields')
    
    // Reset all fields to hidden first
    bankFields.forEach(field => field.style.display = 'none')
    mobileFields.forEach(field => field.style.display = 'none')
    
    if (selectElement.value === 'bank') {
      // For bank accounts: show bank name and account number
      bankFields.forEach(field => field.style.display = 'block')
    } else if (selectElement.value === 'mobile_payment') {
      // For mobile payment: show only mobile phone number
      mobileFields.forEach(field => field.style.display = 'block')
    }
    // If no type selected, all fields stay hidden
  }

  toggleSpecificGrade(event) {
    this.toggleSpecificGradeFields(event.target)
  }

  toggleSpecificGradeFields(selectElement) {
    const container = selectElement.closest('[data-nested-item]')
    if (!container) {
      console.log('No container found for grade fields toggle')
      return
    }
    
    const specificGradeField = container.querySelector('.specific-grade-field')
    const specificGradeSelect = container.querySelector('.specific-grade-select')
    
    if (!specificGradeField || !specificGradeSelect) {
      console.log('No specific-grade-field or select found')
      return
    }
    
    const selectedValue = selectElement.value
    const currentSpecificGrade = specificGradeSelect.value
    
    // Clear existing options except the prompt
    specificGradeSelect.innerHTML = '<option value="">Seleccione grado</option>'
    
    if (selectedValue === 'primaria') {
      specificGradeField.style.display = 'block'
      // Add primary grades
      const primaryOptions = [
        ['1er_grado', '1er Grado'],
        ['2do_grado', '2do Grado'],
        ['3er_grado', '3er Grado'],
        ['4to_grado', '4to Grado'],
        ['5to_grado', '5to Grado'],
        ['6to_grado', '6to Grado']
      ]
      
      primaryOptions.forEach(([value, text]) => {
        const option = document.createElement('option')
        option.value = value
        option.textContent = text
        if (value === currentSpecificGrade) {
          option.selected = true
        }
        specificGradeSelect.appendChild(option)
      })
      
      console.log('Added primary grade options to select')
      
    } else if (selectedValue === 'secundaria') {
      specificGradeField.style.display = 'block'
      // Add secondary grades
      const secondaryOptions = [
        ['1er_año', '1er Año'],
        ['2do_año', '2do Año'],
        ['3er_año', '3er Año'],
        ['4to_año', '4to Año'],
        ['5to_año', '5to Año']
      ]
      
      secondaryOptions.forEach(([value, text]) => {
        const option = document.createElement('option')
        option.value = value
        option.textContent = text
        if (value === currentSpecificGrade) {
          option.selected = true
        }
        specificGradeSelect.appendChild(option)
      })
      
      console.log('Added secondary grade options to select')
      
    } else {
      // For other education levels, hide the field
      specificGradeField.style.display = 'none'
    }
  }
}

