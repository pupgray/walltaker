import {Controller} from "@hotwired/stimulus"
import '@hey-web-components/monaco-editor'

const baseConfig = {
    theme: 'vs-dark',
    automaticLayout: true,
    quickSuggestions: {
        comments: 'on',
        other: 'on',
        strings: 'on',
    },
    renameOnType: true,
    suggest: {
        showClasses: true,
        showColors: true,
        showConstants: true,
        showConstructors: true,
        showDeprecated: true,
        showEnumMembers: true,
        showEnums: true,
        showEvents: true,
        showFields: true,
        showFiles: true,
        showFolders: true,
        showFunctions: true,
        showIcons: true,
        showInlineDetails: true,
        showInterfaces: true,
        showIssues: true,
        showKeywords: true,
        showMethods: true,
        showModules: true,
        showOperators: true,
        showProperties: true,
        showReferences: true,
        showSnippets: true,
        showStatusBar: true,
        showStructs: true,
        showTypeParameters: true,
        showUnits: true,
        showUsers: true,
        showValues: true,
        showVariables: true,
        showWords: true,
    },
    minimap: {
        autohide: true
    },
    wordWrap: 'on'
}

export default class WallEditorController extends Controller {
    static targets = ['template', 'csseditor', 'editor', 'saveBtnText', 'preview']
    static values = {saveUrl: String}

    connect() {
        this.editorTarget.options = {
            ...baseConfig,
            language: 'html',
        }
        this.csseditorTarget.options = {
            ...baseConfig,
            language: 'html',
        }

        const buffers = this.templateTarget.innerHTML.split('<!-- EDITORSPLIT --><style>')
        const htmlValue = buffers?.[0] ?? ''
        const cssValue = buffers?.[1]?.replace('</style>', '') ?? ''

        this.editorTarget.addEventListener('editorInitialized', () => {
            this.editorTarget.editor.addCommand(this.editorTarget.monaco.KeyMod.CtrlCmd | this.editorTarget.monaco.KeyCode.KeyS, () => {
                this.save()
            });

            this.editorTarget.value = htmlValue
        });

        this.csseditorTarget.addEventListener('editorInitialized', () => {
            this.csseditorTarget.editor.addCommand(this.csseditorTarget.monaco.KeyMod.CtrlCmd | this.csseditorTarget.monaco.KeyCode.KeyS, () => {
                this.save()
            });

            this.csseditorTarget.value = cssValue
        });
    }

    save() {
        const value = `${this.editorTarget.value}<!-- EDITORSPLIT --><style>${this.csseditorTarget.value}</style>`
        const csrfToken = document.querySelector("[name='csrf-token']").content

        const body = new FormData()
        body.append('user[details]', value)
        body.append('_method', 'patch')

        fetch(this.saveUrlValue, {
            method: 'POST',
            headers: {
                "X-CSRF-Token": csrfToken
            },
            body
        }).then(res => {
            this.saveBtnTextTarget.innerText = 'Saved!'
            this.previewTarget.reload()

            setTimeout(() => {
                this.saveBtnTextTarget.innerText = 'Save'
            }, 1000)
        })
    }
}