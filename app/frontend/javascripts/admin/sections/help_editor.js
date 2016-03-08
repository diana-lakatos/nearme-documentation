import NM from 'nm';
import CodeEditor from '../modules/forms/custom_inputs/code_editor';
import EditorPreview from '../modules/editor_preview';
import dialog from '../modules/dialog';
import routes from '../modules/routes';
import xhr from '../toolkit/xhr';

class HelpEditor {
  constructor(contentId, container) {
    this._contentId = contentId;
    this._ui = {};
    this._ui.container = container;

    this._build();
    this._init();
    this._load();
    this._bindEvents();
  }

  _build(){
    let content = `
        <div class="fullscreen-editor help-editor">
            <div class="fullscreen-editor-panes help-editor-panes">
                <div class="fullscreen-editor-pane help-editor-pane-textarea">
                    <textarea></textarea>
                </div>
                <div class="fullscreen-editor-pane help-editor-pane-preview"></div>
            </div>
            <div class="fullscreen-editor-actions help-editor-actions">
                <button type="button" class="btn btn-flat action--cancel">Cancel</button>
                <button type="button" class="btn action--save">Save</button>
            </div>
        </div>`;

    dialog.open(content, 'dialog-fullscreen');

    const wrapper = dialog.getContentElement();
    this._ui.input = wrapper.querySelector('textarea');
    this._ui.actionCancel = wrapper.querySelector('.action--cancel');
    this._ui.actionSave = wrapper.querySelector('.action--save');
    this._ui.previewContainer = wrapper.querySelector('.help-editor-pane-preview');
  }

  _init() {
    this._editor = new CodeEditor(this._ui.input, 'markdown', { viewportMargin: 10, height: '100%' });
    this._preview = new EditorPreview(this._editor, this._ui.previewContainer);
  }

  _load() {
    const route = routes['help_contents/show'];

    xhr(route.url(this._contentId), {
      method: route.method,
      contentType: 'text'
    }).then((data)=>{
      this._editor.setValue(data);
    });
  }

  _bindEvents() {
    this._ui.actionCancel.addEventListener('click', this.close.bind(this));
    this._ui.actionSave.addEventListener('click', this.save.bind(this));
  }

  close(){
    dialog.close();
    NM.emit('closed:help_editor');
  }

  save() {
    const route = routes['help_contents/update'];

    xhr(route.url(this._contentId), {
      method: route.method,
      contentType: 'json',
      data: {
        'help_content[content]': this._editor.getValue()
      }
    }).then((result)=>{
      dialog.close();
      this._ui.container.innerHTML = result;
      NM.emit('saved:help_editor');
    });
  }
}

module.exports = HelpEditor;
