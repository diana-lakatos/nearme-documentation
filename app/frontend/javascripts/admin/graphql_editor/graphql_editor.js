import * as React from 'react';
import ReactDom from 'react-dom';
import GraphiQL from 'graphiql';
import fetch from 'isomorphic-fetch';

if (process.env.NODE_ENV !== 'production') {
  require.ensure('react-addons-perf', (require)=>{
    React.Perf = require('react-addons-perf');
  });
}

class GraphqlEditor {
  constructor(container: string) {
    this._ui = {};
    this._ui.container = container;
    this._ui.query = document.getElementById('graph_query_query_string');

    this._bindEvents();
    this._initialize();
  }

  _bindEvents() {
  }

  _graphQLFetcher(graphQLParams) {
    return fetch(window.location.origin + '/api/graph', {
      method: 'post',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(graphQLParams),
    }).then(response => response.json());
  }

  _queryString() {
    return this._ui.query.value;
  }

  _setQueryString(query) {
    this._ui.query.value = query;
  }

  _disableSubmittingFormOnQueryButton(){
    let executeButton = this._ui.container.querySelector('button')
    executeButton.type = 'button';
  }

  _initialize() {
    this._setQueryString = this._setQueryString.bind(this);
    ReactDom.render(<GraphiQL fetcher={this._graphQLFetcher} query={this._queryString()} onEditQuery={this._setQueryString} storage={null} />, this._ui.container );
    this._disableSubmittingFormOnQueryButton();
  }
}

module.exports = GraphqlEditor;
