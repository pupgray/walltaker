import {Controller} from "@hotwired/stimulus"

export default class EmbiggenToggleController extends Controller {
    connect()  {
        this.tick();
    }
    toggle () {
        if (window.sessionStorage.getItem("embiggen-link-image") === "false") {
            window.sessionStorage.setItem("embiggen-link-image", "true")
        }
        else {
            window.sessionStorage.setItem("embiggen-link-image", "false")
        }
        this.tick()
    }

    tick () {
        if (window.sessionStorage.getItem("embiggen-link-image") === "false") {
            this.element.classList.remove("embiggened")
        }
        else {
            this.element.classList.add("embiggened");
        }
    }
}