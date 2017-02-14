# We do this because we don't want slugs deleted when the user is
# soft deleted by acts as paranoid; FriendlyId uses an inner join
# with users to determine what slugs are available and it would no
# longer find the slug, but the slug would still be in users leading
# to a "uniqueness" error on the users table
class FriendlyId::Slug
  alias_method :really_destroy!, :destroy
  alias_method :really_delete!, :delete

  def destroy
    true
  end

  def delete
    true
  end
end
