const el = document.getElementById('graphql_editor');

if (el) {
  require.ensure('../graphql_editor/graphql_editor', (require)=>{
    const GraphqlEditor = require('../graphql_editor/graphql_editor');
    return new GraphqlEditor(el);
  });
}
