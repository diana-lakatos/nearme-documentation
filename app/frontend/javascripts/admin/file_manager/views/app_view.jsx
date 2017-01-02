const HeaderView = require('header_view');
const FilesPaneView = require('files_pane_view');
const InfoPaneView = require('info_pane_view');

class AppView extends React.Component {
  render() {
    return <div className="file-manager">
      <HeaderView></HeaderView>
      <FilesPaneView></FilesPaneView>
      <InfoPaneView></InfoPaneView>
    </div>;
  }
}

module.exports = AppView;
