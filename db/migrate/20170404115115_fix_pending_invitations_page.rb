class FixPendingInvitationsPage < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!
        puts i.name

        page = i.pages.find_by(slug: 'pending-received-invitations')
        page.content = <<EOQ
{% if current_user %}
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
{% else %}
  <script>
    window.location.href = '/users/sign_in?return_to=/pending-received-invitations';
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
