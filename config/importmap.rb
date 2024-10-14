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
pin "@monaco-editor/loader", to: "https://ga.jspm.io/npm:@monaco-editor/loader@1.4.0/lib/es/index.js"
pin "state-local", to: "https://ga.jspm.io/npm:state-local@1.0.7/lib/es/state-local.js"
pin "iconify-icon" # @2.1.0
pin "@stefanjudis/sparkly-text", to: "@stefanjudis--sparkly-text.js" # @1.0.10
