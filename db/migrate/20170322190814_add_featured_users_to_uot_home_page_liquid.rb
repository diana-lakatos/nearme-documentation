class AddFeaturedUsersToUotHomePageLiquid < ActiveRecord::Migration
  def up
    view = InstanceView.find_by(path: 'home/index', instance_id: 195)
    view.body = <<-HTML
{% query_graph 'uot_home', result_name: g %}
<section class="hero-a">
    <div class="slideshow-a">
        <div class="item item-sme active">
            <h2>Make An Impact. Give Back.</h2>
            <h3>Stay Connected.</h3>
        </div>

        <div class="item item-client">
            <h2>Imagine a Marketplace where Businesses find expertise they need</h2>
            <h3>Just in Time</h3>
        </div>

        <div class="item item-mpo">
            <h2>Access the World’s Best Subject Matter Experts </h2>
            <h3>On Demand</h3>
        </div>
    </div>

    <p class="more-a">
      {% if current_user == blank %}
        <a href="/join-our-community" class="button-a">Join Our Community</a>
      {% else %}
        <a href="/search?sort=" class="button-a">Search for experts</a>
      {% endif %}
    </p>

    <div class="more-b">
        <a href="#main" data-learn-more-trigger>Learn More</a>
    </div>
</section>

<main id="main">
    <div class="wrapper-a">
        <section class="how-it-works-cta">
            <header class="section-header">
                <h2 class="hx-a" id="HowItWorks">How it Works</h2>
                <h3 class="hx-b">Fast, Easily, and Efficiently</h3>
            </header>

            <div class="cta-boxes-a">
                <article>
                    <figure>
                        <img src="https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2723/how-it-works-identify-project.jpg" alt="People looking at screen">
                    </figure>
                    <h4><span>Identify</span> a project</h4>
                    <ul>
                        <li>Define project requirements</li>
                        <li>Search for experts</li>
                        <li>Send invitations</li>
                    </ul>
                </article>

                <article>
                    <figure><img src="https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2724/how-it-works-select-your-expert.jpg" alt="Smiling woman"></figure>
                    <h4><span>Select</span> your expert</h4>
                    <ul>
                        <li>Choose among the best</li>
                        <li>Discuss your projects</li>
                        <li>Negotiate terms</li>
                    </ul>
                </article>

                <article>
                    <figure><img src="https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2722/how-it-works-get-started.jpg" alt="People working together on a document"></figure>
                    <h4><span>Get</span> started</h4>
                    <ul>
                        <li>Form your teams</li>
                        <li>Collaborate on projects</li>
                        <li>Celebrate success</li>
                    </ul>
                </article>
            </div>
            {% comment %}
            <p class="more-a">
                <a href="./" class="button-a">Learn More</a>
            </p>
            {% endcomment %}
            <p class="more-a">
              <a href="/join-our-community" class="button-a">Join Our Community</a>
            </p>

        </section>

        <section class="featured-users">
          <header class="section-header">
            <h2 class="hx-a" id="FeaturedSMEs">Featured SMEs</h2>
          </header>

          <div class="cta-boxes-b">
            {% for sme in g.featured_smes %}
              <article class='user-a'>
                <div class='wrapper'>
                    <header class="header">
                    <h4><a href="{{ sme.profile_path }}">{{ sme.name }}</a></h4>
                    <figure><a href="{{ sme.profile_path }}"><img src="{{ sme.avatar_url_big }}" alt="{{ sme.name }}"/></a></figure>
                    </header>
                    <p>{{ sme.bio | truncate: 140 }}</p>
                </div>
                </article>
          {% endfor %}
         </div>
        </section>

        <section class="video-cta">
            <header class="section-header">
                <h2 class="hx-a" id="WatchOurVideo">Watch Our Video</h2>
            </header>
            <div class="video-container">
                <iframe width="1280" height="720" src="https://www.youtube.com/embed/VqnilLKrzUo?rel=0" frameborder="0" allowfullscreen></iframe>
            </div>
            <p class="more-a">
              <a href="/join-our-community" class="button-a">Join Our Community</a>
            </p>

        </section>

        <section class="reasons-cta">
            <header class="section-header">
                <h2 class="hx-a">Why should SMEs join UoT?</h2>
                <h3 class="hx-b">Join a Global Community of Subject Matter Experts</h3>
            </header>

            <div class="cta-boxes-b">
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M13,12v1a1,1,0,0,0,1,1h1a2,2,0,0,1,2,2v1a2,2,0,0,1-2,2v2H14V19a2,2,0,0,1-2-2V16h1v1a1,1,0,0,0,1,1h1a1,1,0,0,0,1-1V16a1,1,0,0,0-1-1H14a2,2,0,0,1-2-2V12a2,2,0,0,1,2-2V8h1v2a2,2,0,0,1,2,2H16a1,1,0,0,0-1-1H14A1,1,0,0,0,13,12ZM4,19.57v1.06A5.56,5.56,0,0,1,0,15c0-2.88,3.6-7.35,4.68-8.63L3,3h7L8,7H5.46C4,8.73,1,12.7,1,15A4.52,4.52,0,0,0,4,19.57ZM5.62,6H7.38l1-2H4.62ZM24,16c0,5.26-4.25,8-9.5,8S5,21.26,5,16c0-3.87,5.44-10.24,6.72-11.69L10,0h9L17.28,4.31l.65.75-.78.62L16.56,5H12.44C10.4,7.29,6,12.88,6,16c0,5.17,4.58,7,8.5,7S23,21.17,23,16a11.13,11.13,0,0,0-2-5l.78-.63C23,12.3,24,14.37,24,16ZM12.68,4h3.65l1.2-3h-6Zm7.15,5.14.78-.63c-.44-.63-.89-1.22-1.31-1.75l-.78.62C19,7.93,19.4,8.52,19.83,9.14Z"/></svg>

                    <h4>More Clients</h4>
                    <p>Enable marketing, blogging and SEO support to boost your professional profile and win clients.</p>
                </article>

                <article>

                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M19,14a5,5,0,1,0,5,5A5,5,0,0,0,19,14Zm0,9a4,4,0,1,1,3-6.67l-3,3-1.65-1.65-.71.71L19,20.71l3.54-3.54A4,4,0,0,1,23,19,4,4,0,0,1,19,23ZM12,6A3,3,0,0,0,9,9v3h6V9A3,3,0,0,0,12,6Zm2,5H10V9a2,2,0,0,1,4,0Zm3.5-4.09L16.09,5.5l.71-.71,1.41,1.41ZM9,15h4v1H10v8H3V12H0L12,0l3.38,3.38-.71.71L12,1.41,2.41,11H4V23H9Zm12.59-4L18.91,8.33l.71-.71L24,12H20V11Z"/></svg>

                    <h4>Global Professional Community</h4>
                    <p>Join a  global community for collaboration, support and growth for your professional career.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M16,12l8-6L16,0V4H2V8H16ZM3,7V5H17V2l5.33,4L17,10V7Zm5,9H22v4H21V17H7V14L1.67,18,7,22V19h8v1H8v4L0,18l8-6Zm9,3h2v1H17Z"/></svg>
                    <h4>Work-Life Flexibility</h4>
                    <p>Consult when and where you want. Pick and choose clients. You have full control.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 23.97 20" width="72" height="72"><path d="M17.43,6.75a.5.5,0,0,0-.88,0L13,13.88,8.45,4.78a.5.5,0,0,0-.89,0L4.7,10H.84C3.56,15.8,12,20,12,20s8.43-4.22,11.16-10H19.29ZM12,18.87C10.44,18,5.19,15,2.56,11H5a.5.5,0,0,0,.44-.26L8,6.08l4.57,9.14a.5.5,0,0,0,.89,0L17,8.06l1.54,2.69A.5.5,0,0,0,19,11h2.43C18.79,15,13.56,18,12,18.87ZM1.2,8h-1A7.41,7.41,0,0,1,0,6.5,6.51,6.51,0,0,1,12,3,6.51,6.51,0,0,1,23.82,5h-1a5.51,5.51,0,0,0-9.94-1.46,1,1,0,0,1-1.68,0A5.51,5.51,0,0,0,1,6.5,6.55,6.55,0,0,0,1.2,8ZM24,7a7.7,7.7,0,0,1-.13,1h-1A7.55,7.55,0,0,0,23,7Z"/></svg>
                    <h4>Meaningful Projects</h4>
                    <p>Empower others to achieve their goals. And seize the opportunity to give back with pro bono work.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M21,18a3,3,0,0,0-1.73.56l-2.32-2.32a6.48,6.48,0,0,0,.49-9l1.83-1.83a3,3,0,1,0-.71-.71L16.73,6.57a6.48,6.48,0,0,0-9,.49L6.29,5.59A3.49,3.49,0,1,0,3.5,7a3.47,3.47,0,0,0,2.09-.71L7.13,7.84a6.49,6.49,0,0,0,.44,7.89L5.88,17.42a2.5,2.5,0,1,0,.71.71l1.69-1.69a6.49,6.49,0,0,0,7.89.44l2.4,2.4A3,3,0,1,0,21,18ZM3.5,6A2.5,2.5,0,1,1,6,3.5,2.5,2.5,0,0,1,3.5,6ZM21,1a2,2,0,1,1-2,2A2,2,0,0,1,21,1ZM4.5,21A1.5,1.5,0,1,1,6,19.5,1.5,1.5,0,0,1,4.5,21ZM7,11.5A5.5,5.5,0,1,1,12.5,17,5.51,5.51,0,0,1,7,11.5ZM21,23a2,2,0,1,1,2-2A2,2,0,0,1,21,23ZM14.65,9.65l.71.71L12,13.71,9.65,11.35l.71-.71L12,12.29Z"/></svg>
                    <h4>No Administrative Headaches</h4>
                    <p>Complete business and back office support is included. Forget billing hassles. We make it easy.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M9.35,4.35,6,7.71,3.65,5.35l.71-.71L6,6.29,8.65,3.65ZM8.65,9.65,6,12.29,4.35,10.65l-.71.71L6,13.71l3.35-3.35ZM20,11H12v1h8ZM4.35,16.65l-.71.71L6,19.71l3.35-3.35-.71-.71L6,18.29ZM12,18h4V17H12Zm8,0V17H18v1ZM20,5H12V6h8Zm3,15a3,3,0,0,1-3,3H4a3,3,0,0,1-3-3V4A3,3,0,0,1,4,1H20a3,3,0,0,1,3,3h1a4,4,0,0,0-4-4H4A4,4,0,0,0,0,4V20a4,4,0,0,0,4,4H20a4,4,0,0,0,4-4V10H23ZM23,8h1V6H23Z"/></svg>
                    <h4>No Business Risk</h4>
                    <p>No more contracting, billing or accounting worries. Prompt, regular payments are a part of our process.</p>
                </article>
            </div>

            {% comment %}
            <p class="more-a">
                <a href="./" class="button-a">Learn More</a>
            </p>
            {% endcomment %}
        </section>

        <section class="target-audience">
            <header class="section-header">
                <h2 class="hx-a">Why should professionals use UoT?</h2>
                <h3 class="hx-b">Collaborate with some of the best Subject Matter Experts</h3>
            </header>

            <div class="target-audience-wrapper cta-boxes-b">
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 24" width="72" height="72"><path d="M8,3a5,5,0,1,0,5,5A5,5,0,0,0,8,3Zm0,9a4,4,0,1,1,4-4A4,4,0,0,1,8,12ZM8,0A8,8,0,0,0,3,14.24V24l5-2,5,2V20H12v2.52L8.37,21.07,8,20.92l-.37.15L4,22.52v-7.6H4A8,8,0,1,0,8,0ZM8,15a7,7,0,1,1,7-7A7,7,0,0,1,8,15Zm4,1h1v2H12Z"/></svg>
                    <h4>Top SMEs on Demand</h4>
                    <p>Get the right expert at the right time from our trusted global SME community.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M11.65,11.65l.71.71,3.5-3.5A5,5,0,0,1,17,12a5,5,0,1,1-5-5,4.94,4.94,0,0,1,1.69.31l.78-.78a6,6,0,1,0,2.11,1.59L17.71,7H21l.5-.5A11.08,11.08,0,0,1,22.57,9h1a12,12,0,0,0-1.38-3.24L24,4,22.35,2.35l1-1L22.65.65l-1,1L20,0,17,3V6.29ZM18,3.41l2-2L22.59,4l-2,2H18ZM24,11c0,.33,0,.66,0,1s0,.67-.05,1h-1c0-.33.05-.66.05-1s0-.67-.05-1Zm-1.38,4h1A12,12,0,1,1,16.93,1.07l-.76.76A11,11,0,1,0,22.57,15Z"/></svg>
                    <h4>Targeted Expertise</h4>
                    <p>Access fast, efficient staffing for specialized skill sets and deep, specific expertise.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 23.62 23.62" width="72" height="72"><path d="M23,20l-3.73-3.73a10.44,10.44,0,0,0,1-9.55l-.78.78a9.54,9.54,0,1,1-3.37-4.63l.72-.72A10.5,10.5,0,1,0,10.5,21a10.44,10.44,0,0,0,5.77-1.73L20,23a2.12,2.12,0,0,0,3,0h0A2.12,2.12,0,0,0,23,20Zm-.71,2.29a1.12,1.12,0,0,1-1.58,0l-3.62-3.62a10.56,10.56,0,0,0,1.59-1.59l3.62,3.62A1.12,1.12,0,0,1,22.29,22.29ZM13,8h1a3,3,0,0,0-3-3V3H10V5a3,3,0,0,0,0,6v4a2,2,0,0,1-2-2H7a3,3,0,0,0,3,3v2h1V16a3,3,0,0,0,0-6V6A2,2,0,0,1,13,8Zm0,5a2,2,0,0,1-2,2V11A2,2,0,0,1,13,13Zm-3-3a2,2,0,0,1,0-4Zm8.54-4.54a9.55,9.55,0,0,0-.85-1.15l.71-.71a10.53,10.53,0,0,1,.87,1.13Z"/></svg>
                    <h4>Lower Costs</h4>
                    <p>Save money with just-in-time hiring and more competitive consulting rates.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M17.69,5.65l-4.64,4.64a2,2,0,1,0,.71.71L18.4,6.35ZM12,13a1,1,0,1,1,1-1A1,1,0,0,1,12,13ZM9,16a2,2,0,1,0,0,4h6a2,2,0,0,0,0-4Zm7,2a1,1,0,0,1-1,1H9a1,1,0,1,1,0-2h6A1,1,0,0,1,16,18ZM12,5H11V3h1ZM3,12H5v1H3Zm18,1H19V12h2Zm-2-9.42.71-.71a12.07,12.07,0,0,1,1.41,1.42L20.47,5A11.09,11.09,0,0,0,19.06,3.58ZM24,12A12,12,0,1,1,18.12,1.69l-.73.73a11,11,0,1,0,4.23,4.25l.73-.73A11.93,11.93,0,0,1,24,12Z"/></svg>
                    <h4>Faster Turnaround</h4>
                    <p>Use our tools to search, match, work, approve, invoice, and pay for projects.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M6,11a6,6,0,1,0,6-6A6,6,0,0,0,6,11Zm6-5a5,5,0,0,1,3.67,1.63L11,12.29,9.35,10.65l-.71.71L11,13.71l5.27-5.27A5,5,0,0,1,17,11a5,5,0,1,1-5-5Zm3-5H13V0h2Zm9,4v7c0,6.63-12,12-12,12S0,18.63,0,12V5A5,5,0,0,0,5,0h6V1H5.92A6,6,0,0,1,1,5.92V12c0,4.71,7.58,9.28,11,10.9,3.42-1.62,11-6.2,11-10.9V5.92A6,6,0,0,1,18.08,1H17V0h2A5,5,0,0,0,24,5Z"/></svg>
                    <h4>Less Risk</h4>
                    <p>Your confidentiality is protected with our safe, secure enterprise-level online marketplace platform.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 26 24" width="72" height="72"><path d="M5,22H25v1H5ZM1,23H3V22H1ZM25,3.5A2.45,2.45,0,0,1,22.12,6l-3.3,7.42a2.5,2.5,0,1,1-3.43.78l-3.48-2.61a2.48,2.48,0,0,1-2.76,0L5.57,16.09a2.54,2.54,0,1,1-.72-.7l3.59-4.49a2.5,2.5,0,1,1,4.17-.07l3.48,2.61a2.35,2.35,0,0,1,1.79-.4l3.3-7.42A2.5,2.5,0,1,1,25,3.5ZM5,17.5A1.5,1.5,0,1,0,3.5,19,1.5,1.5,0,0,0,5,17.5Zm7-8A1.5,1.5,0,1,0,10.5,11,1.5,1.5,0,0,0,12,9.5ZM17.5,14A1.5,1.5,0,1,0,19,15.5,1.5,1.5,0,0,0,17.5,14ZM24,3.5A1.5,1.5,0,1,0,22.5,5,1.5,1.5,0,0,0,24,3.5Z"/></svg>
                    <h4>More Expert Insights</h4>
                    <p>Access top Industry SME blogs. Gain more insights into your important issues.</p>
                </article>
            </div>
            {% comment %}
            <p class="more-a">
                <a href="./" class="button-a">Learn More</a>
            </p>
            {% endcomment %}
        </section>

        {% if platform_context.highlighted_blog_posts != empty %}
          <section class="blog-posts-cta">
              <header class="section-header">
                  <h2 class="hx-a" id="BlogPostFeed">Blog Post Feed</h2>
                  <h3 class="hx-b">Learn from our UoT Experts!</h3>
              </header>

              <div class="wrapper">
                {% for blog_post in platform_context.highlighted_blog_posts %}
                    <article itemscope itemtype="http://schema.org/BlogPosting">
                      <a href="{{ blog_post.post_path }}" itemprop="url">
                        <figure><img src="{{ blog_post.hero_image_url }}" alt="should be dynamic" itemprop="image"></figure>
                            <div class="content">
                              <h4 itemprop="headline">{{ blog_post.title }}</h4>
                                <div class="meta">
                                  posted <time datetime="{{ blog_post.published_at | to_date | l: 'short' }}" itemprop="datePublished">{{ blog_post.published_at | to_date | l: 'long'}}</time>
                                  <div class="author" itemprop="author">by {{ blog_post.author_name }}</div>
                                </div>
                                <div itemprop="description">
                                  <p>{{ blog_post.excerpt | truncate: 200 }}</p>
                                </div>
                                <strong class="cta">Read More</strong>
                            </div>
                        </a>
                    </article>
                {% endfor %}
              </div>

              <p class="more-a"><a href="/blog" class="button-a">Visit Our Blog</a></p>
          </section>
        {% endif %}

    </div>
</main>

<!-- <section class="testimonials-a">
    <div class="wrapper-a">

        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72" class="icon"><path d="M11.39,16.76,8,20,4.61,16.76A8,8,0,0,0,0,24H16A8,8,0,0,0,11.39,16.76ZM1.07,23a7,7,0,0,1,3.37-5L8,21.38,11.56,18a7,7,0,0,1,3.37,5ZM8,17a4,4,0,0,0,4-4V11H11v2a3,3,0,0,1-6,0V11H8a4,4,0,0,0,4-4H6A2,2,0,0,0,4,9v4A4,4,0,0,0,8,17ZM5,9A1,1,0,0,1,6,8h4.83A3,3,0,0,1,8,10H5ZM20,5H14V4h6ZM14,7h6V8H14ZM11,5H10V2a2,2,0,0,1,2-2H22a2,2,0,0,1,2,2H23a1,1,0,0,0-1-1H12a1,1,0,0,0-1,1ZM23,4h1V6H23Zm0,4h1v2a2,2,0,0,1-2,2H19l-4,3V12H14V11h2v2l2.67-2H22a1,1,0,0,0,1-1Z"/></svg>

        <h2>Testimonials</h2>
        <h3>Find out what people are saying about UoT!</h3>

        <div class="wrapper">

            <div class="item" itemscope itemtype="http://schema.org/Review" itemprop="review">
                <blockquote itemprop="reviewBody">
                    <p>
                        “Aliquam vicis et ad enim utinam ad. Modo facilisi capto mara. Iustum macto singularis feugait vel plaga damnum feugait consequat eum lobortis.”
                    </p>
                </blockquote>
                <p class="author" itemprop="author">John Smith</p>
            </div>
            <div class="item" itemscope itemtype="http://schema.org/Review" itemprop="review">
                <blockquote itemprop="reviewBody">
                    <p>“Aliquam vicis et ad enim utinam ad. Modo facilisi capto mara. Iustum macto singularis feugait vel plaga damnum feugait consequat eum lobortis.”</p>
                </blockquote>
                <p class="author" itemprop="author">Jane Miller</p>
            </div>
            <div class="item" itemscope itemtype="http://schema.org/Review" itemprop="review">
                <blockquote itemprop="reviewBody">
                    <p>“Aliquam vicis et ad enim utinam ad. Modo facilisi capto mara. Iustum macto singularis feugait vel plaga damnum feugait consequat eum lobortis.”</p>
                </blockquote>
                <p class="author" itemprop="author">Trevor Williams</p>
            </div>
        </div>
    </div>
</section>   -->
    HTML
    view.save!
  end

  def down
    view = InstanceView.find_by(path: 'home/index', instance_id: 195)
    view.body = <<-HTML
<section class="hero-a">

    <div class="slideshow-a">
        <div class="item item-sme active">
            <h2>Make An Impact. Give Back.</h2>
            <h3>Stay Connected.</h3>
        </div>

        <div class="item item-client">
            <h2>Imagine a Marketplace where Businesses find expertise they need</h2>
            <h3>Just in Time</h3>
        </div>

        <div class="item item-mpo">
            <h2>Access the World’s Best Subject Matter Experts </h2>
            <h3>On Demand</h3>
        </div>
    </div>

    <p class="more-a">
      {% if current_user == blank %}
        <a href="/join-our-community" class="button-a">Join Our Community</a>
      {% else %}
        <a href="/search?sort=" class="button-a">Search for experts</a>
      {% endif %}
    </p>

    <div class="more-b">
        <a href="#main" data-learn-more-trigger>Learn More</a>
    </div>
</section>

<main id="main">
    <div class="wrapper-a">
        <section class="how-it-works-cta">
            <header class="section-header">
                <h2 class="hx-a" id="HowItWorks">How it Works</h2>
                <h3 class="hx-b">Fast, Easily, and Efficiently</h3>
            </header>

            <div class="cta-boxes-a">
                <article>
                    <figure>
                        <img src="https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2723/how-it-works-identify-project.jpg" alt="People looking at screen">
                    </figure>
                    <h4><span>Identify</span> a project</h4>
                    <ul>
                        <li>Define project requirements</li>
                        <li>Search for experts</li>
                        <li>Send invitations</li>
                    </ul>
                </article>

                <article>
                    <figure><img src="https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2724/how-it-works-select-your-expert.jpg" alt="Smiling woman"></figure>
                    <h4><span>Select</span> your expert</h4>
                    <ul>
                        <li>Choose among the best</li>
                        <li>Discuss your projects</li>
                        <li>Negotiate terms</li>
                    </ul>
                </article>

                <article>
                    <figure><img src="https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2722/how-it-works-get-started.jpg" alt="People working together on a document"></figure>
                    <h4><span>Get</span> started</h4>
                    <ul>
                        <li>Form your teams</li>
                        <li>Collaborate on projects</li>
                        <li>Celebrate success</li>
                    </ul>
                </article>
            </div>
            {% comment %}
            <p class="more-a">
                <a href="./" class="button-a">Learn More</a>
            </p>
            {% endcomment %}
            <p class="more-a">
              <a href="/join-our-community" class="button-a">Join Our Community</a>
            </p>

        </section>

        <section class="video-cta">
            <header class="section-header">
                <h2 class="hx-a" id="WatchOurVideo">Watch Our Video</h2>
            </header>
            <div class="video-container">
                <iframe width="1280" height="720" src="https://www.youtube.com/embed/VqnilLKrzUo?rel=0" frameborder="0" allowfullscreen></iframe>
            </div>
            <p class="more-a">
              <a href="/join-our-community" class="button-a">Join Our Community</a>
            </p>

        </section>

        <section class="reasons-cta">
            <header class="section-header">
                <h2 class="hx-a">Why should SMEs join UoT?</h2>
                <h3 class="hx-b">Join a Global Community of Subject Matter Experts</h3>
            </header>

            <div class="cta-boxes-b">
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M13,12v1a1,1,0,0,0,1,1h1a2,2,0,0,1,2,2v1a2,2,0,0,1-2,2v2H14V19a2,2,0,0,1-2-2V16h1v1a1,1,0,0,0,1,1h1a1,1,0,0,0,1-1V16a1,1,0,0,0-1-1H14a2,2,0,0,1-2-2V12a2,2,0,0,1,2-2V8h1v2a2,2,0,0,1,2,2H16a1,1,0,0,0-1-1H14A1,1,0,0,0,13,12ZM4,19.57v1.06A5.56,5.56,0,0,1,0,15c0-2.88,3.6-7.35,4.68-8.63L3,3h7L8,7H5.46C4,8.73,1,12.7,1,15A4.52,4.52,0,0,0,4,19.57ZM5.62,6H7.38l1-2H4.62ZM24,16c0,5.26-4.25,8-9.5,8S5,21.26,5,16c0-3.87,5.44-10.24,6.72-11.69L10,0h9L17.28,4.31l.65.75-.78.62L16.56,5H12.44C10.4,7.29,6,12.88,6,16c0,5.17,4.58,7,8.5,7S23,21.17,23,16a11.13,11.13,0,0,0-2-5l.78-.63C23,12.3,24,14.37,24,16ZM12.68,4h3.65l1.2-3h-6Zm7.15,5.14.78-.63c-.44-.63-.89-1.22-1.31-1.75l-.78.62C19,7.93,19.4,8.52,19.83,9.14Z"/></svg>

                    <h4>More Clients</h4>
                    <p>Enable marketing, blogging and SEO support to boost your professional profile and win clients.</p>
                </article>

                <article>

                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M19,14a5,5,0,1,0,5,5A5,5,0,0,0,19,14Zm0,9a4,4,0,1,1,3-6.67l-3,3-1.65-1.65-.71.71L19,20.71l3.54-3.54A4,4,0,0,1,23,19,4,4,0,0,1,19,23ZM12,6A3,3,0,0,0,9,9v3h6V9A3,3,0,0,0,12,6Zm2,5H10V9a2,2,0,0,1,4,0Zm3.5-4.09L16.09,5.5l.71-.71,1.41,1.41ZM9,15h4v1H10v8H3V12H0L12,0l3.38,3.38-.71.71L12,1.41,2.41,11H4V23H9Zm12.59-4L18.91,8.33l.71-.71L24,12H20V11Z"/></svg>

                    <h4>Global Professional Community</h4>
                    <p>Join a  global community for collaboration, support and growth for your professional career.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M16,12l8-6L16,0V4H2V8H16ZM3,7V5H17V2l5.33,4L17,10V7Zm5,9H22v4H21V17H7V14L1.67,18,7,22V19h8v1H8v4L0,18l8-6Zm9,3h2v1H17Z"/></svg>
                    <h4>Work-Life Flexibility</h4>
                    <p>Consult when and where you want. Pick and choose clients. You have full control.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 23.97 20" width="72" height="72"><path d="M17.43,6.75a.5.5,0,0,0-.88,0L13,13.88,8.45,4.78a.5.5,0,0,0-.89,0L4.7,10H.84C3.56,15.8,12,20,12,20s8.43-4.22,11.16-10H19.29ZM12,18.87C10.44,18,5.19,15,2.56,11H5a.5.5,0,0,0,.44-.26L8,6.08l4.57,9.14a.5.5,0,0,0,.89,0L17,8.06l1.54,2.69A.5.5,0,0,0,19,11h2.43C18.79,15,13.56,18,12,18.87ZM1.2,8h-1A7.41,7.41,0,0,1,0,6.5,6.51,6.51,0,0,1,12,3,6.51,6.51,0,0,1,23.82,5h-1a5.51,5.51,0,0,0-9.94-1.46,1,1,0,0,1-1.68,0A5.51,5.51,0,0,0,1,6.5,6.55,6.55,0,0,0,1.2,8ZM24,7a7.7,7.7,0,0,1-.13,1h-1A7.55,7.55,0,0,0,23,7Z"/></svg>
                    <h4>Meaningful Projects</h4>
                    <p>Empower others to achieve their goals. And seize the opportunity to give back with pro bono work.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M21,18a3,3,0,0,0-1.73.56l-2.32-2.32a6.48,6.48,0,0,0,.49-9l1.83-1.83a3,3,0,1,0-.71-.71L16.73,6.57a6.48,6.48,0,0,0-9,.49L6.29,5.59A3.49,3.49,0,1,0,3.5,7a3.47,3.47,0,0,0,2.09-.71L7.13,7.84a6.49,6.49,0,0,0,.44,7.89L5.88,17.42a2.5,2.5,0,1,0,.71.71l1.69-1.69a6.49,6.49,0,0,0,7.89.44l2.4,2.4A3,3,0,1,0,21,18ZM3.5,6A2.5,2.5,0,1,1,6,3.5,2.5,2.5,0,0,1,3.5,6ZM21,1a2,2,0,1,1-2,2A2,2,0,0,1,21,1ZM4.5,21A1.5,1.5,0,1,1,6,19.5,1.5,1.5,0,0,1,4.5,21ZM7,11.5A5.5,5.5,0,1,1,12.5,17,5.51,5.51,0,0,1,7,11.5ZM21,23a2,2,0,1,1,2-2A2,2,0,0,1,21,23ZM14.65,9.65l.71.71L12,13.71,9.65,11.35l.71-.71L12,12.29Z"/></svg>
                    <h4>No Administrative Headaches</h4>
                    <p>Complete business and back office support is included. Forget billing hassles. We make it easy.</p>
                </article>

                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M9.35,4.35,6,7.71,3.65,5.35l.71-.71L6,6.29,8.65,3.65ZM8.65,9.65,6,12.29,4.35,10.65l-.71.71L6,13.71l3.35-3.35ZM20,11H12v1h8ZM4.35,16.65l-.71.71L6,19.71l3.35-3.35-.71-.71L6,18.29ZM12,18h4V17H12Zm8,0V17H18v1ZM20,5H12V6h8Zm3,15a3,3,0,0,1-3,3H4a3,3,0,0,1-3-3V4A3,3,0,0,1,4,1H20a3,3,0,0,1,3,3h1a4,4,0,0,0-4-4H4A4,4,0,0,0,0,4V20a4,4,0,0,0,4,4H20a4,4,0,0,0,4-4V10H23ZM23,8h1V6H23Z"/></svg>
                    <h4>No Business Risk</h4>
                    <p>No more contracting, billing or accounting worries. Prompt, regular payments are a part of our process.</p>
                </article>
            </div>

            {% comment %}
            <p class="more-a">
                <a href="./" class="button-a">Learn More</a>
            </p>
            {% endcomment %}
        </section>

        <section class="target-audience">
            <header class="section-header">
                <h2 class="hx-a">Why should professionals use UoT?</h2>
                <h3 class="hx-b">Collaborate with some of the best Subject Matter Experts</h3>
            </header>

            <div class="target-audience-wrapper cta-boxes-b">
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 24" width="72" height="72"><path d="M8,3a5,5,0,1,0,5,5A5,5,0,0,0,8,3Zm0,9a4,4,0,1,1,4-4A4,4,0,0,1,8,12ZM8,0A8,8,0,0,0,3,14.24V24l5-2,5,2V20H12v2.52L8.37,21.07,8,20.92l-.37.15L4,22.52v-7.6H4A8,8,0,1,0,8,0ZM8,15a7,7,0,1,1,7-7A7,7,0,0,1,8,15Zm4,1h1v2H12Z"/></svg>
                    <h4>Top SMEs on Demand</h4>
                    <p>Get the right expert at the right time from our trusted global SME community.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M11.65,11.65l.71.71,3.5-3.5A5,5,0,0,1,17,12a5,5,0,1,1-5-5,4.94,4.94,0,0,1,1.69.31l.78-.78a6,6,0,1,0,2.11,1.59L17.71,7H21l.5-.5A11.08,11.08,0,0,1,22.57,9h1a12,12,0,0,0-1.38-3.24L24,4,22.35,2.35l1-1L22.65.65l-1,1L20,0,17,3V6.29ZM18,3.41l2-2L22.59,4l-2,2H18ZM24,11c0,.33,0,.66,0,1s0,.67-.05,1h-1c0-.33.05-.66.05-1s0-.67-.05-1Zm-1.38,4h1A12,12,0,1,1,16.93,1.07l-.76.76A11,11,0,1,0,22.57,15Z"/></svg>
                    <h4>Targeted Expertise</h4>
                    <p>Access fast, efficient staffing for specialized skill sets and deep, specific expertise.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 23.62 23.62" width="72" height="72"><path d="M23,20l-3.73-3.73a10.44,10.44,0,0,0,1-9.55l-.78.78a9.54,9.54,0,1,1-3.37-4.63l.72-.72A10.5,10.5,0,1,0,10.5,21a10.44,10.44,0,0,0,5.77-1.73L20,23a2.12,2.12,0,0,0,3,0h0A2.12,2.12,0,0,0,23,20Zm-.71,2.29a1.12,1.12,0,0,1-1.58,0l-3.62-3.62a10.56,10.56,0,0,0,1.59-1.59l3.62,3.62A1.12,1.12,0,0,1,22.29,22.29ZM13,8h1a3,3,0,0,0-3-3V3H10V5a3,3,0,0,0,0,6v4a2,2,0,0,1-2-2H7a3,3,0,0,0,3,3v2h1V16a3,3,0,0,0,0-6V6A2,2,0,0,1,13,8Zm0,5a2,2,0,0,1-2,2V11A2,2,0,0,1,13,13Zm-3-3a2,2,0,0,1,0-4Zm8.54-4.54a9.55,9.55,0,0,0-.85-1.15l.71-.71a10.53,10.53,0,0,1,.87,1.13Z"/></svg>
                    <h4>Lower Costs</h4>
                    <p>Save money with just-in-time hiring and more competitive consulting rates.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M17.69,5.65l-4.64,4.64a2,2,0,1,0,.71.71L18.4,6.35ZM12,13a1,1,0,1,1,1-1A1,1,0,0,1,12,13ZM9,16a2,2,0,1,0,0,4h6a2,2,0,0,0,0-4Zm7,2a1,1,0,0,1-1,1H9a1,1,0,1,1,0-2h6A1,1,0,0,1,16,18ZM12,5H11V3h1ZM3,12H5v1H3Zm18,1H19V12h2Zm-2-9.42.71-.71a12.07,12.07,0,0,1,1.41,1.42L20.47,5A11.09,11.09,0,0,0,19.06,3.58ZM24,12A12,12,0,1,1,18.12,1.69l-.73.73a11,11,0,1,0,4.23,4.25l.73-.73A11.93,11.93,0,0,1,24,12Z"/></svg>
                    <h4>Faster Turnaround</h4>
                    <p>Use our tools to search, match, work, approve, invoice, and pay for projects.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72"><path d="M6,11a6,6,0,1,0,6-6A6,6,0,0,0,6,11Zm6-5a5,5,0,0,1,3.67,1.63L11,12.29,9.35,10.65l-.71.71L11,13.71l5.27-5.27A5,5,0,0,1,17,11a5,5,0,1,1-5-5Zm3-5H13V0h2Zm9,4v7c0,6.63-12,12-12,12S0,18.63,0,12V5A5,5,0,0,0,5,0h6V1H5.92A6,6,0,0,1,1,5.92V12c0,4.71,7.58,9.28,11,10.9,3.42-1.62,11-6.2,11-10.9V5.92A6,6,0,0,1,18.08,1H17V0h2A5,5,0,0,0,24,5Z"/></svg>
                    <h4>Less Risk</h4>
                    <p>Your confidentiality is protected with our safe, secure enterprise-level online marketplace platform.</p>
                </article>
                <article>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 26 24" width="72" height="72"><path d="M5,22H25v1H5ZM1,23H3V22H1ZM25,3.5A2.45,2.45,0,0,1,22.12,6l-3.3,7.42a2.5,2.5,0,1,1-3.43.78l-3.48-2.61a2.48,2.48,0,0,1-2.76,0L5.57,16.09a2.54,2.54,0,1,1-.72-.7l3.59-4.49a2.5,2.5,0,1,1,4.17-.07l3.48,2.61a2.35,2.35,0,0,1,1.79-.4l3.3-7.42A2.5,2.5,0,1,1,25,3.5ZM5,17.5A1.5,1.5,0,1,0,3.5,19,1.5,1.5,0,0,0,5,17.5Zm7-8A1.5,1.5,0,1,0,10.5,11,1.5,1.5,0,0,0,12,9.5ZM17.5,14A1.5,1.5,0,1,0,19,15.5,1.5,1.5,0,0,0,17.5,14ZM24,3.5A1.5,1.5,0,1,0,22.5,5,1.5,1.5,0,0,0,24,3.5Z"/></svg>
                    <h4>More Expert Insights</h4>
                    <p>Access top Industry SME blogs. Gain more insights into your important issues.</p>
                </article>
            </div>
            {% comment %}
            <p class="more-a">
                <a href="./" class="button-a">Learn More</a>
            </p>
            {% endcomment %}
        </section>

        {% if platform_context.highlighted_blog_posts != empty %}
          <section class="blog-posts-cta">
              <header class="section-header">
                  <h2 class="hx-a" id="BlogPostFeed">Blog Post Feed</h2>
                  <h3 class="hx-b">Learn from our UoT Experts!</h3>
              </header>

              <div class="wrapper">
                {% for blog_post in platform_context.highlighted_blog_posts %}
                    <article itemscope itemtype="http://schema.org/BlogPosting">
                      <a href="{{ blog_post.post_path }}" itemprop="url">
                        <figure><img src="{{ blog_post.hero_image_url }}" alt="should be dynamic" itemprop="image"></figure>
                            <div class="content">
                              <h4 itemprop="headline">{{ blog_post.title }}</h4>
                                <div class="meta">
                                  posted <time datetime="{{ blog_post.published_at | to_date | l: 'short' }}" itemprop="datePublished">{{ blog_post.published_at | to_date | l: 'long'}}</time>
                                  <div class="author" itemprop="author">by {{ blog_post.author_name }}</div>
                                </div>
                                <div itemprop="description">
                                  <p>{{ blog_post.excerpt | truncate: 200 }}</p>
                                </div>
                                <strong class="cta">Read More</strong>
                            </div>
                        </a>
                    </article>
                {% endfor %}
              </div>

              <p class="more-a"><a href="/blog" class="button-a">Visit Our Blog</a></p>
          </section>
        {% endif %}

    </div>
</main>

<!-- <section class="testimonials-a">
    <div class="wrapper-a">

        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="72" height="72" class="icon"><path d="M11.39,16.76,8,20,4.61,16.76A8,8,0,0,0,0,24H16A8,8,0,0,0,11.39,16.76ZM1.07,23a7,7,0,0,1,3.37-5L8,21.38,11.56,18a7,7,0,0,1,3.37,5ZM8,17a4,4,0,0,0,4-4V11H11v2a3,3,0,0,1-6,0V11H8a4,4,0,0,0,4-4H6A2,2,0,0,0,4,9v4A4,4,0,0,0,8,17ZM5,9A1,1,0,0,1,6,8h4.83A3,3,0,0,1,8,10H5ZM20,5H14V4h6ZM14,7h6V8H14ZM11,5H10V2a2,2,0,0,1,2-2H22a2,2,0,0,1,2,2H23a1,1,0,0,0-1-1H12a1,1,0,0,0-1,1ZM23,4h1V6H23Zm0,4h1v2a2,2,0,0,1-2,2H19l-4,3V12H14V11h2v2l2.67-2H22a1,1,0,0,0,1-1Z"/></svg>

        <h2>Testimonials</h2>
        <h3>Find out what people are saying about UoT!</h3>

        <div class="wrapper">

            <div class="item" itemscope itemtype="http://schema.org/Review" itemprop="review">
                <blockquote itemprop="reviewBody">
                    <p>
                        “Aliquam vicis et ad enim utinam ad. Modo facilisi capto mara. Iustum macto singularis feugait vel plaga damnum feugait consequat eum lobortis.”
                    </p>
                </blockquote>
                <p class="author" itemprop="author">John Smith</p>
            </div>
            <div class="item" itemscope itemtype="http://schema.org/Review" itemprop="review">
                <blockquote itemprop="reviewBody">
                    <p>“Aliquam vicis et ad enim utinam ad. Modo facilisi capto mara. Iustum macto singularis feugait vel plaga damnum feugait consequat eum lobortis.”</p>
                </blockquote>
                <p class="author" itemprop="author">Jane Miller</p>
            </div>
            <div class="item" itemscope itemtype="http://schema.org/Review" itemprop="review">
                <blockquote itemprop="reviewBody">
                    <p>“Aliquam vicis et ad enim utinam ad. Modo facilisi capto mara. Iustum macto singularis feugait vel plaga damnum feugait consequat eum lobortis.”</p>
                </blockquote>
                <p class="author" itemprop="author">Trevor Williams</p>
            </div>
        </div>
    </div>
</section>   -->
      HTML
      view.save!
  end
end
