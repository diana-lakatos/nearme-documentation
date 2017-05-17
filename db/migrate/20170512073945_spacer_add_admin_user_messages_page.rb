class SpacerAddAdminUserMessagesPage < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!

      query = <<-QUERY
query admin_messages($after: String, $before: String) {
  messages(first: 15, after: $after, before: $before){
    pageInfo{
      hasNextPage
      startCursor
      hasPreviousPage
      endCursor
    }
    edges{
      node{
   		 	body
    		created_at
        author{id slug name}
        recipient{
          id slug name
          seller: profile(profile_type: "seller"){ id }
        }
      }
    }
  }
}
      QUERY

      i.graph_queries.create!(name: 'admin_messages', query_string: query)

      views = [
        {
          path: 'instance_admin/manage/user_messages',
          layout_name: 'instance_admin',
          admin_page: true,
          metadata_title: 'User Messages',
          slug: 'instance_admin/manage/user_messages',
          content: <<-BODY
{% query_graph 'admin_messages', result_name: g, after: params.after, before: params.before %}

<div class="content-container">
  <h4>User Messages</h4>
  <div class="row">
    <div class="table-container col-xs-12">
      <table class="table">
        <thead>
          <tr>
            <th>Receiver</th>
            <th>Sender</th>
            <th>Receiver Host/Guest</th>
            <th>Sent at</th>
            <th>Message</th>
          </tr>
        </thead>
        <tbody>
          {% for edge in g.messages.edges %}
            {% assign message = edge.node %}
            <tr>
              <td>
                <a href={{ 'edit_instance_admin_manage_user_path' | generate_url: id: message.recipient.id }}>
                  {{ message.recipient.name }}
                </a>
              </td>
              <td>
                <a href={{ 'edit_instance_admin_manage_user_path' | generate_url: id: message.author.id }}>
                  {{ message.author.name }}
                </a>
              </td>
              <td>{% if message.recipient.seller %}Host{% else %}Guest{% endif %}</td>
              <td>{{ message.created_at {{ site.date | date: ' %b %d, %Y' }}</td>
              <td>
                <a href="#collapse_message_{{ message.id }}" role="button" data-toggle="collapse">
                  {{ message.body | truncate: 20, '...'}}
                </a>
              </td>
            </tr>
            <tr class="collapse" id="collapse_message_{{ message.id }}">
              <td colspan=6>
                <div class="well">
                  {{ message.body }}
                </div>
              </td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <div class="pagination">
        <a href="{{ current_path }}?before={{ g.messages.pageInfo.startCursor }}">
          Prev
        </a>
        {% if g.messages.pageInfo.hasNextPage %}
          <a href="{{ current_path }}?after={{ g.messages.pageInfo.endCursor }}">
            Next
          </a>
        {% endif %}
      </div>
    </div>
  </div>
</div>
          BODY
        }
      ]

      views.each do |view|
        i.pages.create!(
          view.merge(
            instance_id: i.id,
            theme: i.theme
          )
        )
      end
    end
  end

  def down
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!
      i.pages.where(path: 'instance_admin/manage/user_messages').delete_all
      i.graph_queries.where(name: 'admin_messages').delete_all
    end
  end
end
