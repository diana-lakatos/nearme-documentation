import * as React from 'react';
import ReactDom from 'react-dom';
import GraphiQL from 'graphiql'; /* eslint no-unused-vars: 0 */
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

    this._initialize();
  }

  _graphQLFetcher(graphQLParams) {
    return fetch(window.location.origin + '/api/graph', {
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this._getCSRFToken(),
        'UserAuthorization': this._getAuthToken()
      },
      credentials: 'same-origin',
      body: JSON.stringify(graphQLParams),
    }).then(response => response.json());
  }

  _queryString() {
    return this._ui.query.value;
  }

  _setQueryString(query) {
    this._ui.query.value = query;
  }

  _disableSubmittingFormOnQueryButton() {
    let executeButton = this._ui.container.querySelector('button');
    executeButton.type = 'button';
  }

  _initialize() {
    const graphQLFetcher = this._graphQLFetcher.bind(this);
    const setQueryString = this._setQueryString.bind(this);
    const graphiqlEditor = <GraphiQL fetcher={graphQLFetcher} query={this._queryString()} onEditQuery={setQueryString} storage={null} />;
    ReactDom.render(graphiqlEditor, this._ui.container);
    this._disableSubmittingFormOnQueryButton();
  }


  _getCSRFToken(){
    return document.querySelector('meta[name="csrf-token"]').content;
  }

  _getAuthToken(){
    return document.querySelector('meta[name="authorization-token"]').content;
  }
}

module.exports = GraphqlEditor;
