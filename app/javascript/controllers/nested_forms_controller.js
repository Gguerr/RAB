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
    
    this.indexValue++
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest('[data-nested-item]')
    
    if (!item) {
      console.log('No nested item found')
      return
    }
    
    // Always remove immediately from DOM
    item.remove()
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
}

