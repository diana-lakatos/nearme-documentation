# frozen_string_literal: true
class AddPendingInvitationsPageToHallmark < ActiveRecord::Migration
  def up
    Instance.transaction do
      hallmark_id = 5011
      Instance.where(id: [hallmark_id]).each do |i|
        i.set_context!

        query_string = <<EOQ
query UserPendingCollaborationsQuery($user_id: ID!){
  user(id: $user_id) {
    email
    collaborations(filters: [PENDING_RECEIVED_INVITATION]){
      id
      transactable{
        id
        show_path
        name
        cover_photo_thumbnail_url
        creator{
          avatar_url_thumb
          name_with_affiliation
          profile_path
        }
      }
    }
  }
}
EOQ
        i.graph_queries.create!(
          name: 'user_pending_received_collaborations',
          query_string: query_string
        )

        views = [
          {
            path: 'transactable_mailer/transactable_owner_added_collaborator_email',
            format: 'html',
            body: <<EOQ
<h1>Hi {{ enquirer.first_name }},</h1>

<p>
  <a href="{{ lister.profile_url }}">{{ lister.name }}</a>  has invited you to become
  a collaborator on <a href="{{ transactable.listing_url }}">{{ transactable.name }}</a>.
  Join in on the conversation.
</p>

<p><a href="{{ 'pages_path' | generate_url: slug: 'pending-received-invitations' }}">Click here to accept or decline the invitation</a></p>
EOQ
          },
          {
            path: 'transactable_mailer/transactable_owner_added_collaborator_email',
            format: 'text',
            body: <<EOQ
Hi {{ enquirer.first_name }},

{{ lister.name }} ({{ lister.profile_url }})  has invited you to become a collaborator on {{ transactable.name }} ({{ transactable.listing_url }}).
Join in on the conversation.

Click here to accept or decline the invitation ({{ 'pages_path' | generate_url: slug: 'pending-received-invitations' }})
EOQ
          }
        ]

        views.each do |view|
          iv = InstanceView.find_or_initialize_by(
            instance_id: i.id, locale: 'en', view_type: 'email', partial: false, handler: 'liquid',
            path: view[:path], format: view[:format]
          )
          iv.body = view[:body]
          iv.locale_ids = [Locale.find_by(code: 'en').id]
          iv.save!
        end

        i.pages.create!(
          path: 'Pending Received Invitations',
          slug: 'pending-received-invitations',
          layout_name: 'community',
          theme: i.theme,
          content: <<EOQ
{% query_graph 'user_pending_received_collaborations', result_name: g, user_id: current_user.id %}

{% if g.user.collaborations.size == 0 %}
  <div class="header-a">
    <h1 class="hx">{{ 'collaborator_invitations.title_summary' | t }}</h1>
    <p class="tx-a">{{ 'collaborator_invitations.empty_resultset' | t }}</p>
  </div>
{% else %}
  <div class="header-a">
    <h1 class="hx">{{ 'collaborator_invitations.title_summary' | t }}</h1>
    <p class="tx-a">{{ 'collaborator_invitations.invitations_count_html' | translate: count: g.user.collaborations.size }}</p>
  </div>

  <div class="grid-a-projects-a">
    <div class="wrap">
      {% for invitation in g.user.collaborations %}
        <div class="cell">
          <article class="card-a" data-equalize>
            <figure><a href="{{ invitation.transactable.show_path }}"><img src="{{ invitation.transactable.cover_photo_thumbnail_url }}" /></a></figure>
            <h3 class="hx">
              <a href="{{ invitation.transactable.show_path }}">{{ invitation.transactable.name }}</a>
            </h3>
            <p class="user"><a href="{{ invitation.transactable.creator.profile_path }}"><img src="{{ invitation.transactable.creator.avatar_url_thumb }}" width="30" height="30" />{{ invitation.transactable.creator.name_with_affiliation }}</a></p>

            <p class="collaborator-action">
              <a href="{{ 'accept_listing_transactable_collaborator_path' | generate_url: id: invitation.id, listing_id: invitation.transactable.id }}" class='button-a tiny'>
                {{ 'approve' | translate }}
              </a>
              <a href="{{ 'listing_transactable_collaborator_path' | generate_url: id: invitation.id, listing_id: invitation.transactable.id }}" class="button-a tiny danger" data-method="delete">
                {{ 'decline' | translate }}
              </a>
            </p>
          </article>
        </div>
      {% endfor %}
    </div>
  </div>
{% endif %}

EOQ
        )

        ts = [
          { key: 'collaborator_invitations.title_summary', value: 'Pending collaboration invitations' },
          { key: 'collaborator_invitations.empty_resultset', value: 'At the moment you have no pending invitations to approve.' },
          { key: 'collaborator_invitations.invitations_count_html.one', value: 'You have <b>one</b> pending invitation.' },
          { key: 'collaborator_invitations.invitations_count_html.other', value: 'You have <b>%{count}</b> pending invitations.' }
        ]

        ts.each do |t|
          i.translations.where(
            locale: 'en',
            key: t[:key]
          ).first_or_initialize.update!(value: t[:value])
        end
      end
    end
  end

  def down
    Instance.transaction do
      hallmark_id = 5011
      Instance.where(id: [hallmark_id]).each do |i|
        i.set_context!

        i.graph_queries.where(name: 'user_pending_received_collaborations').delete_all
        i.pages.where(slug: 'pending-received-invitations').delete_all
      end
    end
  end
end
