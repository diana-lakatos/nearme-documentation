// @flow
class SpamReportResolver {
  promise: JQueryXHR;

  constructor(){
    this.promise = this._fetch();
  }

  get(): JQueryXHR {
    return this.promise;
  }

  _fetch(): JQueryXHR {
    return $.ajax({
      url: '/spam_reports',
      dataType: 'json'
    });
  }
}

module.exports = new SpamReportResolver();
