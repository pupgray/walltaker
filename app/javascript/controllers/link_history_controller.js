import {Controller} from "@hotwired/stimulus"
import {WithModal} from 'modules/modal'

class LinkHistoryController extends Controller {
    static targets = ["modal"];

    showReaction() {
        // this is awkward, but it ensures that there's no leftover frame content from the last modal
        this.modalTarget.querySelector("turbo-frame").innerHTML = "";
        this.modal.open();
    }
}

export default WithModal(LinkHistoryController)