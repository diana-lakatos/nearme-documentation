class FixPendingGroupInvitationsPage < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!
        puts i.name

        page = i.pages.find_by(slug: 'pending-received-group-invitations')
        page.content = <<EOQ
{% if current_user %}
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
{% else %}
  <script>
    window.location.href = '/users/sign_in?return_to=/pending-received-group-invitations';
  </script>
{% endif %}
EOQ
        page.save!
      end
    end
  end

  def down
  end
end
