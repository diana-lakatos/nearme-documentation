#encoding: utf-8
class InsertDnmHomepageContent < ActiveRecord::Migration

  def up
    dnm_instance = Instance.default_instance
    dnm_theme = dnm_instance.theme

    if dnm_theme
      dnm_theme.call_to_action = 'Find out more'

      dnm_theme.homepage_content = <<-MARKDOWN
<div class='row-fluid padding-row'>
<h1>
List Your Desk
</h1>
</div>
<div class='row-fluid'>
<div class='span4'>
<h2>Expand Your Network</h2>
<img alt="Handshake" src="/assets/illustrations/handshake.png" />
<p>Match the right people to your space based on complementary skills, communities, and interests.</p>
</div>
<div class='span4'>
<h2>Reduce Overhead</h2>
<img alt="Dollar" src="/assets/illustrations/dollar.png" />
<p>Generate extra revenue by renting desk and office space that’s not being used.</p>
</div>
<div class='span4'>
<h2>Security &amp; Convenience</h2>
<img alt="Lock" src="/assets/illustrations/lock.png" />
<p>Do business with trusted professionals quickly and easily using our secure dashboard.</p>
</div>
</div>
<div class='row-fluid'>
<a href="/space/new" class="btn btn-blue btn-large"><span class='ico-add-location padding'>List Now</span>
</a></div>
<hr>
<div class='row-fluid'>
<h1>Find a Workspace</h1>
</div>
</hr>
<div class='row-fluid'>
<div class='span4'>
<h2>Where You Need It</h2>
<img alt="World" src="/assets/illustrations/world.png" />
<p>Choose from thousands of spaces around the world. </p>
</div>
<div class='span4'>
<h2>When You Need It</h2>
<img alt="Calendar" src="/assets/illustrations/calendar.png" />
<p>Daily, weekly, or monthly – you decide the length of your stay.</p>
</div>
<div class='span4'>
<h2>How You Need It</h2>
<img alt="Desks" src="/assets/illustrations/desks.png" />
<p>Find private desks, shared office spaces, meeting rooms, and more.</p>
</div>
</div>
<div class='row-fluid padding-bottom'>
<a href="/search" class="btn btn-green btn-large"><span class='ico-search padding'>Search Now</span>
</a></div>
      MARKDOWN

      dnm_theme.save!
    end
  end

  def down
  end
end
