import {Controller} from "@hotwired/stimulus"

export default class HistoryReactionController extends Controller {
    submitEnd(event) {
        const response = event.detail.fetchResponse.response
        // 205: HTTP Reset Content
        if (response.status === 205) {
            window.location = response.headers.get("Location");
        }
    }
}
