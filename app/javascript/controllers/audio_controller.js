import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio"
export default class extends Controller {
  static targets = ['player']
  connect() {
    document.addEventListener('click', () => {
      this.playerTarget.play()
    })
  }
}
