import * as React from 'react';
import ReactDom from 'react-dom';

if (process.env.NODE_ENV !== 'production') {
  require.ensure('react-addons-perf', require => {
    React.Perf = require('react-addons-perf');
  });
}

//const delegate = require('dom-delegate');
// const FileNameEditor = require('lib/file_name_editor');
//
//
//
const AppView = require('views/app_view');

class FileManager {
  constructor(container: string) {
    this._ui = {};
    this._ui.container = container;

    // this._delegated = {};
    // this._ui.fileNameEditor = this._ui.container.querySelector('[data-file-name]');
    this._bindEvents();
    this._initialize();
  }

  _bindEvents() {}

  _initialize() {
    ReactDom.render(React.createElement(AppView, null), this._ui.container);
    // this.fileNameEditor = new FileNameEditor(this._ui.fileNameEditor);
  }
}

module.exports = FileManager;
