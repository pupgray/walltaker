import {Controller} from "@hotwired/stimulus"

export default class WallEditorController extends Controller {
    static targets = ['template', 'editor', 'saveBtnText', 'preview']
    static values = {saveUrl: String}

    connect() {
        require.config({paths: {'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.48.0/min/vs'}});
        require(["vs/editor/editor.main"], () => {
            monaco.editor.create(this.editorTarget, {
                value: this.templateTarget.innerHTML,
                language: "html",
                theme: 'vs-dark',
                automaticLayout: true
            }).addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS, () => {
                this.save()
            });
        });
    }

    save() {
        const value = monaco.editor.getModels()[0].getValue()
        const csrfToken = document.querySelector("[name='csrf-token']").content

        const body = new FormData()
        body.append('wall[content]', value)

        fetch(this.saveUrlValue, {
            method: 'PATCH',
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