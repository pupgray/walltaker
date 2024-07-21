# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/modules", under: "modules"

pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"

pin 'hotkeys-js', to: 'https://unpkg.com/hotkeys-js/dist/hotkeys.esm.js'
pin "@hey-web-components/monaco-editor", to: "https://ga.jspm.io/npm:@hey-web-components/monaco-editor@0.4.3/dist/node/index.js"
pin "@lit/reactive-element", to: "https://ga.jspm.io/npm:@lit/reactive-element@1.6.3/reactive-element.js"
pin "@lit/reactive-element/decorators/", to: "https://ga.jspm.io/npm:@lit/reactive-element@1.6.3/decorators/"
pin "@monaco-editor/loader", to: "https://ga.jspm.io/npm:@monaco-editor/loader@1.4.0/lib/es/index.js"
pin "lit", to: "https://ga.jspm.io/npm:lit@2.8.0/index.js"
pin "lit-element/lit-element.js", to: "https://ga.jspm.io/npm:lit-element@3.3.3/lit-element.js"
pin "lit-html", to: "https://ga.jspm.io/npm:lit-html@2.8.0/lit-html.js"
pin "lit-html/", to: "https://ga.jspm.io/npm:lit-html@2.8.0/"
pin "lit/", to: "https://ga.jspm.io/npm:lit@2.8.0/"
pin "state-local", to: "https://ga.jspm.io/npm:state-local@1.0.7/lib/es/state-local.js"
