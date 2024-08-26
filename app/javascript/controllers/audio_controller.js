import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio"
export default class extends Controller {
  static targets = ['player']
  connect() {
    document.addEventListener('click', (e) => {
      if (window.location.pathname.indexOf('news_room') > -1) {
        this.playerTarget?.play()
      } else {
        this.playerTarget?.remove();
      }
    })
  }

  disconnect() {
    this.playerTarget?.remove();
  }
}
