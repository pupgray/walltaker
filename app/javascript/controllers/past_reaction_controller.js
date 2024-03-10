import {Controller} from "@hotwired/stimulus"
import {WithModal} from 'modules/modal'

class PastReactionController extends Controller {
    addReaction() {
        this.modal.open();
    }
}

export default WithModal(PastReactionController)