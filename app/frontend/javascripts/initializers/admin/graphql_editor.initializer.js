const el = document.getElementById('graphql_editor');

if (el) {
  require.ensure('../../admin/graphql_editor/graphql_editor', (require)=>{
    const GraphqlEditor = require('../../admin/graphql_editor/graphql_editor');
    return new GraphqlEditor(el);
  });
}
