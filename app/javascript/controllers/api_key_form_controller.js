import {Controller} from "@hotwired/stimulus"
import {WithModal} from 'modules/modal'

export default class ApiKeyFormController extends Controller {
    static targets = ['key']

    connect() {
        if (this.hasKeyTarget) {
            this.keyTarget.addEventListener('click', this.copyKey.bind(this))
        }
    }

    copyKey() {
        if (this.hasKeyTarget) {
            getSelection().selectAllChildren(this.keyTarget)
        }
    }
}