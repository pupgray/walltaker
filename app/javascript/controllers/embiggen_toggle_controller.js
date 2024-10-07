import {Controller} from "@hotwired/stimulus"

export default class EmbiggenToggleController extends Controller {
    connect()  {
        this.tick();
    }
    toggle () {
        let value = window.localStorage.getItem("embiggen-link-image")
        if (value === "false" || value === null) {
            window.localStorage.setItem("embiggen-link-image", "true")
        }
        else {
            window.localStorage.setItem("embiggen-link-image", "false")
        }
        this.tick()
    }

    tick () {
        let value = window.localStorage.getItem("embiggen-link-image")
        if (value === "false" || value === null) {
            this.element.classList.remove("embiggened")
        }
        else {
            this.element.classList.add("embiggened");
        }
    }
}