class SpamReportResolver {
  constructor(){
    this.promise = this._fetch();
  }

  get(){
    return this.promise;
  }

  _fetch() {
    return $.ajax({
      url: '/spam_reports',
      dataType: 'json'
    });
  }
}

module.exports = new SpamReportResolver();
