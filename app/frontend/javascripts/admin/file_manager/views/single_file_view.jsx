class SingleFileView extends React.Component {
  render() {
    return (
      <div className="file-manager-info-pane single-file">
        <div className="file-name" data-file-name>
          <div className="file-name-text-wrapper" data-file-name-text-wrapper>
            <h2 data-file-name-string>
               file_1.pdf
            </h2>
            <button className="edit-name" type="button">
             Edit
          </button>
          </div>
          <form className="file-name-form" action="#" data-file-name-form>
          <input type="text" value="file_1.pdf" data-file-name-input /><button type="submit">
          Change name
        </button>
        </form>
        </div>
        <ul className="selection-actions">
          <li>
            <a className="edit-file" href="#">Edit</a>
          </li>
          <li>
            <a href="#" download>Download</a>
          </li>
          <li>
            <button>Move</button>
          </li>
          <li>
            <form action="#">
              <button type="submit">Trash</button>
            </form>
          </li>
        </ul>
        <dl className="properties">
          <dt>Created</dt>
          <dd></dd>
          <dt>Last modified</dt>
          <dd></dd>
          <dt>Size</dt>
          <dd>40kb</dd>
          <dt>Absolute URL</dt>
          <dd>
            <input type="url" readOnly value="http://example.com/file/somefolder/file_1.pdf" />
            <button className="clipboard-copy" type="button" title="Copy to clipboard">
              Copy to clipboard
            </button>
          </dd>
          <dt>Liquid tag</dt>
          <dd>
            <input
              type="url"
              readOnly
              value="{{ &quot;file/somefolder/file_1.pdf&quot; | asset_url }} "
            />
            <button className="clipboard-copy" type="button" title="Copy to clipboard">
              Copy to clipboard
            </button>
          </dd>
          <dt>Access</dt>
          <dd>
            <form className="access-level" action="#">
              <ul>
                <li>
                  <span className="radio">
                    <input id="access-1" name="access" type="radio" value="1" />
                    <label htmlFor="access-1">Public</label>
                  </span>
                </li>
                <li>
                  <span className="radio">
                    <input id="access-2" name="access" type="radio" value="2" />
                    <label htmlFor="access-2">Listers only</label>
                  </span>
                </li>
                <li>
                  <span className="radio">
                    <input id="access-3" name="access" type="radio" value="3" />
                    <label htmlFor="access-3">Enquirers only</label>
                  </span>
                </li>
              </ul>
              <button type="submit">Change access level</button>
            </form>
          </dd>
          <dt>Preview</dt>
          <dd className="preview">
          </dd>
        </dl>
        <h3>More info</h3>
        <dl className="properties">
          <dt>Size</dt>
          <dd>1000px × 200px</dd>
        </dl>
      </div>
    );
  }
}

module.exports = SingleFileView;
