class FolderPathView extends React.Component {
  render() {
    return <div className="file-manager-folder-path">
      <h3>Path:</h3> <a href="#">/</a> &rsaquo; <a href="#">folder</a> &rsaquo; <a href="#">subfolder</a>
    </div>;
  }
}

module.exports = FolderPathView;
