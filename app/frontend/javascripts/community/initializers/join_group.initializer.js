var Modal = require('../modal');

class JoinGroup {
  init() {
    this.bindJoinGroupClick();
    this.bindLoginButtonClick();
    this.sendRequestToJoinGroupIfActionIsPending();
  }

  onJoinGroupClick(e) {
    if(this._isUserLogged(e)) {
      return;
    }

    e.preventDefault();
    this._setModalGroupId(e);
    Modal.showContent(this._modalContainer().html());
  }

  sendRequestToJoinGroupIfActionIsPending() {
    var joinGroupId = localStorage.getItem('join-group-after-login');

    if(joinGroupId) {
      $.post(`/groups/${joinGroupId}/group_members`, () => {});
      localStorage.removeItem('join-group-after-login');
    }
  }

  bindJoinGroupClick() {
    $("a[data-join-group]").on('click', this.onJoinGroupClick.bind(this))
  }

  bindLoginButtonClick() {
    $(document).on('click', '.require-login-button', (e) => {
      var groupId = $("#loginRequiredModal").data('group-id');
      localStorage.setItem('join-group-after-login', groupId);
    });
  }

  _isUserLogged(e) {
    return $(e.target).data('current-user');
  }

  _setModalGroupId(e) {
    var joinGroupId = $(e.target).data('join-group');
    return this._modalContainer().data('group-id', joinGroupId);
  }

  _modalContainer() {
    return $("#loginRequiredModal");
  }
}

new JoinGroup().init();
