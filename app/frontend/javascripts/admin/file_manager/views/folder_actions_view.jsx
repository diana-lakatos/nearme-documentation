class FolderActionsView extends React.Component {
  render() {
    return <ul className="file-manager-header-actions folder-actions">
      <li><button type="button" className="action--upload">Upload</button></li>
      <li><button type="button" className="action--new-folder">New Folder</button></li>
      <li><button type="button" className="action--new-file">New File</button></li>
    </ul>;
  }
}

module.exports = FolderActionsView;
