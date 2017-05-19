import NM from 'nm';
import CodeEditor from '../modules/forms/custom_inputs/code_editor';
import dialog from '../modules/dialog';
import xhr from '../toolkit/xhr';
import closest from '../toolkit/closest';

const CodeMirror = require('codemirror/lib/codemirror.js');
import 'codemirror/addon/merge/merge.css';
require(
  'imports?diff_match_patch=diff-match-patch&DIFF_DELETE=>-1&DIFF_INSERT=>1&DIFF_EQUAL=>0!codemirror/addon/merge/merge.js'
);

const editorDefaults = require('../modules/forms/custom_inputs/codemirror/defaults');

class VersionsEditor {
  constructor(urlVersionsIndex, textarea) {
    this._urlVersionsIndex = urlVersionsIndex;
    this._mainEditor = CodeEditor.getInstanceFromTextarea(textarea);
    this._currentValue = this._mainEditor.getValue();
    this._ui = {};

    this._build();
    this._load();
    this._bindEvents();
  }

  _build() {
    let content = `
        <div class="fullscreen-editor versions-editor">
            <div class="fullscreen-editor-panes versions-editor-panes">
                <div class="fullscreen-editor-pane versions-editor-pane-textarea">
                    <span class="select-version">Select version from the list</span>
                </div>
                <div class="fullscreen-editor-pane versions-editor-pane-list">
                    <h3>Versions</h3>
                    <p class="loading">Loading versions...</p>
                </div>
            </div>
            <div class="fullscreen-editor-actions versions-editor-actions">
                <button type="button" class="btn btn-flat action--cancel">Cancel</button>
                <button type="button" class="btn action--save is-hidden">Update</button>
            </div>
        </div>`;

    dialog.open(content, 'dialog-fullscreen');

    const wrapper = dialog.getContentElement();
    this._ui.input = wrapper.querySelector('textarea');
    this._ui.actionCancel = wrapper.querySelector('.action--cancel');
    this._ui.actionSave = wrapper.querySelector('.action--save');
    this._ui.listContainer = wrapper.querySelector('.versions-editor-pane-list');
    this._ui.editorPane = wrapper.querySelector('.versions-editor-pane-textarea');
  }

  _populateVersions(versions) {
    const loadingText = this._ui.listContainer.querySelector('.loading');
    loadingText.parentNode.removeChild(loadingText);

    if (versions.length === 0) {
      dialog
        .getContentElement()
        .querySelector(
          '.fullscreen-editor-panes'
        ).innerHTML = '<strong class="no-versions-found">No previous versions found</strong>';
      return;
    }

    const list = document.createElement('ul');

    versions.forEach(version => {
      console.log(version);
      const li = document.createElement('li');
      const author = version.author
        ? `<span class="author">${version.attributes.author}</span>`
        : '';
      li.innerHTML = `<a href="${version.links.self}">${version.attributes.date} ${author}</a>`;
      list.appendChild(li);
    });
    this._ui.listContainer.appendChild(list);
  }

  _initEditor() {
    let options = Object.assign({}, editorDefaults, {
      value: this._currentValue,
      orig: '',
      lineNumbers: true,
      mode: 'liquid',
      viewportMargin: 10,
      height: '100%',
      highlightDifferences: true,
      connect: true
    });
    this._ui.editorPane.innerHTML = '';
    this._editor = CodeMirror.MergeView(this._ui.editorPane, options);
  }

  _load() {
    return xhr(this._urlVersionsIndex, {
      method: 'get',
      contentType: 'application/vnd.api+json'
    }).then(r => {
      this._populateVersions(r.data);
    });
  }

  _selectVersion(trigger) {
    Array.prototype.forEach.call(this._ui.listContainer.querySelectorAll('a'), el => {
      el.classList.remove('is-active');
    });
    trigger.classList.add('is-active');
    this._loadVersion(trigger.href);
  }

  _loadVersion(url) {
    return xhr(url, { contentType: 'json' }).then(r => {
      let version = r.data;

      this._ui.actionSave.classList.remove('is-hidden');
      if (!this._editor) {
        this._initEditor();
      }
      this._editor.rightOriginal().setValue(version.attributes.content || '');
    });
  }

  _bindEvents() {
    this._ui.actionCancel.addEventListener('click', this.close.bind(this));
    this._ui.actionSave.addEventListener('click', this.save.bind(this));
    if (this._ui.listContainer) {
      this._ui.listContainer.addEventListener('click', e => {
        let link = closest(e.target, 'a');

        if (link) {
          e.preventDefault();
          this._selectVersion(link);
        }
      });
    }
  }

  close() {
    dialog.close();
    NM.emit('closed:versions_editor');
  }

  save() {
    this._mainEditor.setValue(this._editor.editor().getValue());
    dialog.close();
    NM.emit('saved:versions_editor');
  }
}

module.exports = VersionsEditor;
