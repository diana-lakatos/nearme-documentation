# Facebook returns as image url path that actually redirect to the real image - which causes
# exception because redirection is not allowed. This monkey patch fixes the error. To
# reproduce the error try to do following:
#
#  u = User.first; u.remote_avatar_url = 'http://graph.facebook.com/1495255061/picture?type=large'; u.save!

module OpenURI
  def self.redirectable?(uri1, uri2)
    uri1.scheme.downcase == uri2.scheme.downcase ||
      (/\A(?:https?|ftp)\z/i =~ uri1.scheme && /\A(?:https?|ftp)\z/i =~ uri2.scheme)
  end
end
