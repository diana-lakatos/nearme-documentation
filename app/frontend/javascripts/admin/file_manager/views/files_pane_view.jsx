class FilePaneView extends React.Component {
  render() {
    return <div className="file-manager-files-pane">
      <table className="file-listing">
        <thead>
          <tr>
            <th className="files-name">
              <a href="#">Name</a>
            </th>
            <th className="files-size">
              <a href="#">Size</a>
            </th>
            <th className="files-modified">
              <a href="#">Modified</a>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr className="file-type-dir">
            <td>
              <a href="#">..</a>
            </td>
            <td>
              --
            </td>
            <td>
              --
            </td>
          </tr>
          <tr className="file-type-dir">
            <td>
              <a href="#">subfolder</a>
            </td>
            <td>
              --
            </td>
            <td>
              2016-10-12
            </td>
          </tr>
          <tr className="file-type-zip">
            <td>
              <a href="#">file_1.pdf</a>
            </td>
            <td>
              45kb
            </td>
            <td></td>
          </tr>
          <tr className="file-type-zip">
            <td>
              <a href="#">file_1.zip</a>
            </td>
            <td>
              45kb
            </td>
            <td>
              2016-10-12
            </td>
          </tr>
          <tr className="file-type-png">
            <td>
              <a href="#">file_1.png</a>
            </td>
            <td>
              45kb
            </td>
            <td>
              2016-10-12
            </td>
          </tr>
        </tbody>
      </table>


    </div>;
  }
}

module.exports = FilePaneView;
