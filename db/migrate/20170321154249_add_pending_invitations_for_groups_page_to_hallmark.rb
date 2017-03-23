class AddPendingInvitationsForGroupsPageToHallmark < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        query_string = <<EOQ
query UserPendingGroupCollaborationsQuery($user_id: ID!){
  user(id: $user_id) {
    email
    group_collaborations(filters: [PENDING_RECEIVED_INVITATION]){
      id
      group{
        id
        show_path
        name
        cover_photo{ url(version: "thumb") }
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
          name: 'user_pending_received_group_collaborations',
          query_string: query_string
        )

        views = [
          {
            path: 'group_mailer/group_owner_added_member_email',
            format: 'html',
            body: <<EOQ

<h1>Hi {{ user.first_name }},</h1>

<p>
  <a href="{{ owner.profile_url }}">{{ owner.name }}</a>  has invited you to become
  a member on <a href="{{ group.show_url }}">{{ group.name }}</a>.
  Learn more about the group.
</p>

<p><a href="{{ 'pages_url' | generate_url: slug: 'pending-received-group-invitations' }}" >Accept | Decline invitation</a></p>
EOQ
          },
          {
            path: 'group_mailer/group_owner_added_member_email',
            format: 'text',
            body: <<EOQ
Hi {{ user.first_name }},

{{ owner.name }} ({{ owner.profile_url }}) has invited you to become a member on {{ group.name }} ({{ group.show_url }}).
Learn more about the group.

Accept | Decline invitation ({{ 'pages_url' | generate_url: slug: 'pending-received-group-invitations' }})
EOQ
          }
        ]
        views.each do |view|
          iv = InstanceView.find_or_initialize_by(
            instance_id: i.id, view_type: 'email', partial: false, handler: 'liquid',
            path: view[:path], format: view[:format]
          )
          iv.body = view[:body]
          iv.transactable_type_ids = TransactableType.pluck(:id)
          iv.locale_ids = Locale.pluck(:id)
          iv.save!
        end

        i.pages.create!(
          path: 'Pending Received Group Invitations',
          slug: 'pending-received-group-invitations',
          layout_name: 'community',
          theme: i.theme,
          content: <<EOQ
{% query_graph 'user_pending_received_group_collaborations', result_name: g, user_id: current_user.id %}

{% if g.user.group_collaborations.size == 0 %}
  <div class="header-a">
    <h1 class="hx">{{ 'group_invitations.title_summary' | t }}</h1>
    <p class="tx-a">{{ 'group_invitations.empty_resultset' | t }}</p>
  </div>
{% else %}
  <div class="header-a">
    <h1 class="hx">{{ 'group_invitations.title_summary' | t }}</h1>
    <p class="tx-a">{{ 'group_invitations.invitations_count_html' | translate: count: g.user.group_collaborations.size }}</p>
  </div>

  <div class="grid-a-projects-a">
    <div class="wrap">
      {% for invitation in g.user.group_collaborations %}
        <div class="cell">
          <article class="card-a" data-equalize>
            <figure><a href="{{ invitation.group.show_path }}"><img src="{{ invitation.group.cover_photo_thumbnail_url }}" /></a></figure>
            <h3 class="hx">
              <a href="{{ invitation.group.show_path }}">{{ invitation.group.name }}</a>
            </h3>
            <p class="user"><a href="{{ invitation.group.creator.profile_path }}"><img src="{{ invitation.group.creator.avatar_url_thumb }}" width="30" height="30" />{{ invitation.group.creator.name_with_affiliation }}</a></p>

            <p class="collaborator-action">
              <a href="{{ 'accept_group_group_member_path' | generate_url: id: invitation.id, group_id: invitation.group.id }}" class='button-a tiny' data-method="patch">
                {{ 'approve' | translate }}
              </a>
              <a href="{{ 'group_group_member_path' | generate_url: id: invitation.id, group_id: invitation.group.id }}" class="button-a tiny danger" data-method="delete">
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
          { key: 'group_invitations.title_summary', value: 'Pending group invitations' },
          { key: 'group_invitations.empty_resultset', value: 'At the moment you have no pending invitations to approve.' },
          { key: 'group_invitations.invitations_count_html.one', value: 'You have <b>one</b> pending invitation.' },
          { key: 'group_invitations.invitations_count_html.other', value: 'You have <b>%{count}</b> pending invitations.' }
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
      Instances::InstanceFinder.get(:hallmark).each do |i|
        puts i.name
        i.set_context!

        i.graph_queries.where(name: 'user_pending_received_group_collaborations').delete_all
        i.pages.where(slug: 'pending-received-group-invitations').delete_all
      end
    end
  end
end
