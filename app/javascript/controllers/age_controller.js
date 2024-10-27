import {Controller} from "@hotwired/stimulus"
import {WithModal} from 'modules/modal'

class AgeController extends Controller {
    static targets = ['cancel']
    skipHeader = true

    connect () {
        if (!localStorage.getItem('age')) {
            this.confirm()
        }
    }

    confirm() {
        this.modal.open()
        this.cancelTarget.focus()
    }

    dismiss() {
        localStorage.setItem('age', true)
        this.modal.close()
    }

    cancel() {
        window.location = "https://google.com"
    }
}

export default WithModal(AgeController);