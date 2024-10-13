import {Controller} from "@hotwired/stimulus"

const MEDALS = [
    {over: 50, colour: 'driftwood'},
    {over: 75, colour: 'tin'},
    {over: 150, colour: 'bronze'},
    {over: 300, colour: 'silver'},
    {over: 500, colour: 'gold'},
    {over: 800, colour: 'platinum'},
    {over: 1000, colour: 'uranium'},
    {over: 1400, colour: 'ruby'},
    {over: 1800, colour: 'jade'},
    {over: 2400, colour: 'regal-purple'},
    {over: 4200, colour: 'green'},
    {over: 6900, colour: 'cum'}
]

export default class UserReferenceController extends Controller {
    static values = {hideOnline: String}
    online = false;
    flair = "";
    setCount = 0;
    isReporter = false;

    connect() {
        const username = this.element.childNodes[0].textContent
        this.flairEl = this.element.querySelector('.flair') ?? document.createElement("span");
        this.flairEl.className = 'flair'
        this.element.appendChild(this.flairEl);
        if (username) {
            fetch(`/api/users/${username}.json`)
                .then(stream => stream.json())
                .then(result => {
                    if (!this.hasHideOnlineValue) {
                        this.online = !!result.online;
                        this.flair = result.flair;
                    }
                    this.setCount = result.set_count ?? 0;
                    this.isReporter = result.is_reporter ?? false;
                })
                .catch(() => {
                    this.online = false
                })
                .finally(() => {
                    this.refresh()
                })
        }
    }

    refresh() {
        if (this.online) {
            this.attachCharm('online')
        } else {
            this.detachCharm('online')
        }
        if (this.isReporter) {
            const reporterCharm = document.createElement('div')
            reporterCharm.className = `text-charm text-charm__reporter`
            reporterCharm.title = `WTN Official Reporter`
            reporterCharm.innerHTML = `
                <ion-icon
                    aria-label="WTN Reporter Icon"
                    title="User is a Reporter"
                    name="earth"></ion-icon>
            `
            if (!this.element.querySelector(`.text-charm__reporter`)) {
                this.element.appendChild(reporterCharm)
            }
        }
        this.setMedal()
        this.flairEl.innerHTML = this.flair;
    }

    attachCharm(type) {
        const charm = document.createElement('div')
        charm.className = `text-charm text-charm__${type}`

        if (this.element.querySelector(`.text-charm__${type}`)) return

        if (type.includes('medal-')) {
            const colour = type.replace('medal-', '')
            const medal = MEDALS.find(medal => medal.colour === colour)
            if (medal) {
                charm.className = `text-charm text-charm__medal text-charm__${type}`
                charm.title = `The ${type.replace('medal-', '')} medal`
                charm.innerHTML = `
                    <ion-icon
                        aria-label="The ${type.replace('medal-', '')} medal"
                        title="The ${type.replace('medal-', '')} medal"
                        name="trophy-sharp">
                    </ion-icon>
                    <small>${medal.over}</small>
                `
            }
        }

        this.element.appendChild(charm)
    }

    detachCharm(type) {
        const charms = this.element.querySelectorAll(`.text-charm__${type}`)
        if (charms) charms.forEach(charm => charm.remove())
    }

    setMedal() {
        const currentMedal = MEDALS.reduce((acc, i) => {
            if (this.setCount >= i.over) acc = i
            return acc
        }, null)
        MEDALS.forEach((medalType) => {
            this.detachCharm(`medal-${medalType.colour}`)
        })
        if (currentMedal) this.attachCharm(`medal-${currentMedal.colour}`)
    }
}