import {Controller} from "@hotwired/stimulus"
import {WithModal} from 'modules/modal'

class MasterController extends Controller {
    static targets = ['cancel']

    confirm() {
        this.modal.open()
        this.cancelTarget.focus()
    }

    cancel() {
        this.modal.close()
    }
}

export default WithModal(MasterController);