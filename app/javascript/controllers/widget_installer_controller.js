import {Controller} from "@hotwired/stimulus"
import {WithModal} from 'modules/modal'

class WidgetInstallerController extends Controller {
    connect () {
        this.element.addEventListener('click', (e) => {
            if (e.target === this.element) {
                this.modal.open()
            }
        });
    }

    cancel() {
        this.modal.close()
    }
}

export default WithModal(WidgetInstallerController);