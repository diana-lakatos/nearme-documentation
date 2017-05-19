const FolderPathView = require('folder_path_view');
const FolderActionsView = require('folder_actions_view');
const OtherActionsView = require('other_actions_view');

class HeaderView extends React.Component {
  render() {
    return (
      <header className="file-manager-header">
        <FolderPathView></FolderPathView>
        <FolderActionsView></FolderActionsView>
        <OtherActionsView></OtherActionsView>
      </header>
    );
  }
}

module.exports = HeaderView;
