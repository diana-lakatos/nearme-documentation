require 'net/http'
require 'json'

namespace :longtail do
  desc 'Parses data from their api and creates what needs to be created'
  task setup: :environment do
    Instance.find(130).set_context!
    LongtailRakeHelper.parse_keywords!
  end
end

class LongtailRakeHelper

  class << self

    def parse_keywords!(page_number = 1)
      url = URI.parse("http://api-staging.longtailux.com/keywords/seo?page_limit=10000")
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Get.new(url)
      req.add_field("Authorization", "Bearer bd6502da3bc87081bb32be0b7187534c")
      response = http.request(req)
      keywords = JSON.parse(response.body)

      @page = Page.where(slug: 'storage', theme_id: PlatformContext.current.theme.id).first_or_create!(path: 'Storage')
      @page.redirect_url = nil
      @page.content = page_content
      @page.css_content = page_css
      @page.save!
      @main_data_source = @page.data_sources.where(type: 'DataSource::CustomSource', label: "storage").first_or_create!

      wait = 0
      keywords["data"].each do |keyword|
        wait += 1
        if wait == 10
          wait = 0
          puts "waiting 2secs"
          sleep 2
        end

        host = "http://api-staging.longtailux.com/search/seo/#{keyword['attributes']['slug']}"
        url = URI.parse(host)
        http = Net::HTTP.new(url.host, url.port)
        req = Net::HTTP::Get.new(url)
        req.add_field("Authorization", "Bearer bd6502da3bc87081bb32be0b7187534c")
        response = http.request(req)
        while response.body == 'Too Many Attempts.'
          puts "Too many attempts, retrying after 5secs..."
          sleep(5)
          response = http.request(req)
        end
        unless response.body =~ /^{"data"/
          puts "\tSkipping keyword: #{host}"
          puts response.body
          next
        end

        data_source_content = @main_data_source.data_source_contents.where(external_id: keyword['id']).first_or_create! do |dsc|
          puts "\tNew data source content for #{keyword['attributes']['slug']}"
          dsc.external_id = keyword['id']
          dsc.externally_created_at = nil
          parsed_body = JSON.parse(response.body)
          parsed_body['included'].each_with_index do |item, index|
            transactable = Transactable.with_deleted.find_by(id: item['attributes']['guid'])
            if transactable.nil?
              puts "\t\tSkipping additional attributes - no transactable"
              next
            else
              puts "\t\tFetching additional attributes"
            end
            parsed_body['included'][index]['attributes']['price'] = transactable.action_type.pricings.first.price.to_s
            parsed_body['included'][index]['attributes']['photos'] = transactable.photos_metadata.try(:map) { |p| p['space_listing'] }
            parsed_body['included'][index]['attributes']['address'] = transactable.formatted_address
            parsed_body['included'][index]['attributes']['latitude'] = transactable.latitude
            parsed_body['included'][index]['attributes']['longitude'] = transactable.longitude
            transactable.properties.to_h.each do |k, v|
              parsed_body['included'][index]['attributes'][k] = v
            end
            parsed_body['included'][index]['attributes']['categories'] = transactable.to_liquid.categories
          end
          dsc.json_content = parsed_body
        end
        #@page.page_data_source_content.where(data_source_content: data_source_content, slug: 'storage').first_or_create!
        #@page.page_data_source_content.where(data_source_content: data_source_content, slug: keyword['attributes']['category_url'][1..-1]).first_or_create!
        @page.page_data_source_content.where(data_source_content: data_source_content, slug: keyword['attributes']['url'][1..-1]).first_or_create!

      end
    end

    def page_content
      %Q{
  {% cache_for data_source_last_update, current_path %}
    {% assign dsc = @data_source_contents.first.json_content %}
    <link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
    {% if params.slug2 == blank or dsc == blank %}
      <section class="search search-index">
        <div class="container">
          <header class="container-fluid mixed with-toggle" id="listing_search">

            <div class="header-inner">
              <div class="row-fluid">
                <div class=" btn btn-blue ">
                  <a href="/search?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" target="_blank">Search spaces on map</a>
                </div>
              </div>
            </div>
          </header>
          <div class="container page-not-found-container">
            <h1>404</h1>
            <h2>Sorry, that page could not be found. </h2>
            <p> Go back to <a href="//www.spacer.com.au?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp"><strong>www.spacer.com.au</strong></a> or <a href="javascript:history.go(-1)?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp"><strong>return</strong></a> to previous page or try one of the links below:</p>
            <div class=" page-not-found-listings">
              <ul id="searches">
                <li><strong>Adelaide</strong>:
                  <a href="/storage/lease-my-warehouse-adelaide?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">lease my warehouse adelaide</a>
                  ,                              <a href="/storage/storage-solutions-adelaide?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">storage solutions adelaide</a>
                  ,                              <a href="/storage/rent-my-shed-adelaide?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent my shed adelaide</a>
                </li>
                <li><strong>Australia</strong>:
                  <a href="/storage/single-lock-up-garage-for-rent?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">single lock up garage for rent</a>
                  ,                              <a href="/storage/full-access-garage-for-rent?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">full access garage for rent</a>
                  ,                              <a href="/storage/two-car-secure-garage-for-rent?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">two car secure garage for rent</a>
                </li>
                <li><strong>Brisbane</strong>:
                  <a href="/storage/rent-small-warehouses-brisbane?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent small warehouses brisbane</a>
                  ,                              <a href="/storage/container-storage-brisbane?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">container storage brisbane</a>
                  ,                              <a href="/storage/cheap-storage-brisbane-south?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">cheap storage brisbane south</a>
                </li>
                <li><strong>Canberra</strong>:
                  <a href="/storage/car-spaces-for-rent-canberra?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">car spaces for rent canberra</a>
                  ,                              <a href="/storage/rent-my-carpark-canberra?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent my carpark canberra</a>
                  ,                              <a href="/storage/lease-my-garage-canberra?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">lease my garage canberra</a>
                </li>
                <li><strong>Gold Coast</strong>:
                  <a href="/storage/storage-space-for-rent-gold-coast?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">storage space for rent gold coast</a>
                  ,                              <a href="/storage/rent-my-shed-gold-coast?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent my shed gold coast</a>
                  ,                              <a href="/storage/lease-my-carpark-gold-coast?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">lease my carpark gold coast</a>
                </li>
                <li><strong>Melbourne</strong>:
                  <a href="/storage/melbourne-lock-up-garage-for-rent?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">melbourne lock up garage for rent</a>
                  ,                              <a href="/storage/rent-a-shed-melbourne?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent a shed melbourne</a>
                  ,                              <a href="/storage/rent-my-car-space-melbourne?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent my car space melbourne</a>
                </li>
                <li><strong>Perth</strong>:
                  <a href="/storage/rent-my-shed-perth?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent my shed perth</a>
                  ,                              <a href="/storage/caravan-storage-perth?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">caravan storage perth</a>
                  ,                              <a href="/storage/storage-perth-cost?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">storage perth cost</a>
                </li>
                <li><strong>Sydney</strong>:
                  <a href="/storage/car-spaces-for-rent-kogarah?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">car spaces for rent kogarah</a>
                  ,                              <a href="/storage/small-warehouse-for-rent-sydney?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">small warehouse for rent sydney</a>
                  ,                              <a href="/storage/car-spaces-for-rent-rozelle?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">car spaces for rent rozelle</a>
                </li>
                <li><strong>Tasmania</strong>:
                  <a href="/storage/rent-my-garage-launceston?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">rent my garage launceston</a>
                  ,                              <a href="/storage/garage-rental-launceston?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">garage rental launceston</a>
                  ,                              <a href="/storage/car-spaces-for-rent-horbart?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">car spaces for rent horbart</a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>
    {% else %}
        {% assign dsc = @data_source_contents.first.json_content %}
        <div class="container">
          <section class="search search-index">
            <div class="container">
              <header class="container-fluid mixed with-toggle" id="listing_search">

                <div class="header-inner">
                  <div class="row-fluid">
                    <div class=" btn btn-blue ">
                      <a href="/search?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" target="_blank">Search spaces on map</a>
                    </div>
                  </div>
                </div>
              </header>
              <div class="lux-search-widget">
                <h4>
                  Showing <span class="no-of-listings"> {{ dsc.data.first.relationships.items.data.count }} </span> results for: <strong> {{  dsc.data.first.attributes.name }} </strong>
                </h4>
                <p> Related storage listings:
                  {% for similar_storage in dsc.data.first.relationships.similar_searches.data %}
                    {% for included_link in dsc.included %}
                      {% if included_link.id == similar_storage.id %}
                        <li class="lux-search-listings-option"><a href="{{ included_link.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp"><span class="selected-location">{{ included_link.attributes.highlighted }}</span></a></li>
                        {% break %}
                      {% endif %}
                    {% endfor %}
                  {% endfor %}
                </p>
                <ol class="breadcrumb center ">
                  <li><a href="/?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp"><i class="fa fa-home" aria-hidden="true"></i></a></li>
                  <li><a href="{{ dsc.data.first.attributes.category_url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">{{ dsc.data.first.attributes.category }}</a></li>
                  <li class="active"><a href="{{ dsc.data.first.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">{{ dsc.data.first.attributes.name | titleize }}</a></li>
                </ol>
              </div>

              <section class="mixed" id="results">
                <div class="list" data-list="">
                  <div class="locations">
                    {% for item in dsc.data.first.relationships.items.data %}
                      {% for listing in dsc.included %}
                        {% if listing.id == item.id %}
                        <article class="location" data-id="{{ listing.attributes.guid }}" data-name="{{ listing.attributes.name }}" data-latitude="{{ listing.attributes.latitude }}" data-longitude="{{ listing.attributes.longitude }}">
                          <div class="location-photos-container">
                            <div class="location-photos">
                              <div class="carousel" id="location-gallery-{{ listing.attributes.guid }}" data-interval="false">
                                <div class="carousel-inner">
                                  {% for photo in listing.attributes.photos %}
                                    <div class="item" {% if forloop.index == 1 %}style="display: block;"{% endif %}>
                                      <a href="{{ listing.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp"><img src="{{ photo }}" alt="{{ listing.attributes.name }}"></a>
                                    </div>
                                  {% endfor %}
                                </div>

                                <div class="carousel-nav">
                                  <a href="#location-gallery-{{ listing.attributes.guid }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" class="carousel-control left ico-chevron-left" data-slide="prev"></a>
                                  <a href="#location-gallery-{{ listing.attributes.guid }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" class="carousel-control right ico-chevron-right" data-slide="next"></a>
                                </div>
                              </div>
                            </div>
                          </div>
                          <div class="location-data">
                            <a href="{{ listing.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" class="name">{{ listing.attributes.name }}</a>
                            <div data-add-favorite-button="true" data-path="/wish_list/{{ listing.attributes.guid }}/Transactable" data-wishlistable-type="Transactable" data-link-to-classes="btn btn-white btn-large ask" data-path-bulk="/wish_lists/bulk_show" data-object-id="{{ listing.attributes.guid }}" id="favorite-button-Transactable-{{ listing.attributes.guid }}">
                            </div>
                            <p class="subheader">
                              {{ listing.attributes.address }}
                            </p>
                            <p class="details">
                              {{ listing.attributes.snippet }}
                            </p>
                          </div>
                          <div class="features">
                            <div>
                              <div>
                                <p>Space Type</p>
                                <div>
                                  <i class="fa fa-building-o"></i>
                                  <p>{{ listing.attributes.categories['Storage Type']['children'].first }}</p>
                                </div>
                              </div>
                              <div>
                                <p>Space Area</p>
                                <div>
                                  <i class="fa fa-square-o"></i>
                                  <p>{{ listing.attributes.size_of_space }} </p>
                                </div>
                              </div>
                              <div>
                                <p>Space Access</p>
                                <div>
                                  <i class="fa fa-key"></i>
                                  <p>{{ listing.attributes.categories['Access']['children'].first }}</p>
                                </div>
                              </div>
                              <div class="price-and-types hidden-xs ">
                                <span class="original-price">${{ listing.attributes.price }}</span> / month
                                <a href="{{ listing.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" class="btn">
                                  Reserve
                                </a>
                              </div>
                            </div>
                          </div>
                          <div class="price-and-types visible-xs ">
                            <span class="original-price">${{ listing.attributes.price }}</span> / month
                            <a href="{{ listing.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp" class="btn">
                              Reserve
                            </a>
                          </div>
                        </article>
                          {% break %}
                        {% endif %}
                      {% endfor %}
                    {% endfor %}

                    <div class="footer search-footer">
                      <div class="lux-search-box ">
                        <h4>
                          Other storage searches in <span class="selected-location">{{ dsc.data.first.attributes.category }}</span>:
                        </h4>
                        <ul class="lux-search-listings">

                          {% for related_storage in dsc.data.first.relationships.popular_searches.data %}
                            {% for included_link in dsc.included %}
                              {% if included_link.id == related_storage.id %}
                                <a class="selected-location" href="{{ included_link.attributes.url }}?utm_source=LUX&amp;utm_medium=organic&amp;utm_campaign=iserp">{{ included_link.attributes.highlighted }}</a>
                                {% break %}
                              {% endif %}
                            {% endfor %}
                          {% endfor %}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </section>

              <script type="text/javascript">
                $('.carousel').carousel({
                  interval: 3000
                })
                $('.carousel-inner').each(function() {
                  if ($(this).children('div').length === 1) $(this).siblings('.carousel-nav ').hide();
                });
              </script>
              <script type="text/javascript">
                $('article.location').on('click', function(e) {
                  var currentTarget = $(e.currentTarget)
                  if (currentTarget.closest('a').length > 0) { return false }
                  if (!currentTarget.hasClass('.carousel-control')) {
                    var url = currentTarget.closest('.location').find('a.name').attr('href')
                    window.test = currentTarget
                    window.location.href = url
                  }
                })
              </script>
            </div>
          </section>
        </div>
      {% endif %}
    {% endcache_for %}
      }

    end

    def page_css
      %Q{
body {
  background: #fff !important;
}
.noUi-connect{
  background:#787878;
  box-shadow: inset 0 0 3px rgba(51,51,51,.45);
  transition: background .45s;
}
.noUi-dragable {
    cursor: w-resize;
}
.noUi-horizontal {
    height: 9px;
}
.noUi-horizontal .noUi-handle {
    width: 34px;
    height: 28px;
    left: -17px;
    top: -11px;
}

.noUi-horizontal .noUi-tooltip{
  display: block;

  border: 1px solid #d9d9d9;
  font: 400 12px/12px Arial;
  border-radius: 3px;
  background: #fff;

  padding: 5px;
  font-weight:bold;
  text-align: center;
  width: 50px;
}
.noUi-horizontal .noUi-handle-lower .noUi-tooltip {
  top: -28px;
  left: -10px;
}
.noUi-horizontal .noUi-handle-upper .noUi-tooltip {
    bottom: 30px;
    left: -10px;
}
section.search section#results.mixed .list .filters {

  margin-top:0 !important;
    position: absolute !important;
    top:52% !important;
    left:0 !important;
    width:25% !important;
    padding-top: 10px !important;
}
section.search#content div.google-map .inner{
  height:350px !important;
}
section.search section#results.mixed .map {
    float: left !important;
    width: 25% !important;
    padding-top:0;
    position:relative;

}
section#results.mixed .list {
    width:100% !important;
    margin-top: -1% !important;
    float: left !important;

    overflow-x:visible !important;
    overflow-y: visible !important;
}

section#results.mixed .list .locations{
  margin-top:0;
}
section#results.mixed .list .locations .location .location-data {
    overflow: auto;
    margin-right:0;
    padding-top: 0;
    width: 60% !important;
    float:right;
    padding-left:2%;
}
.search-index .carousel-inner>.active {
  max-height:100%;
}

section.search section#results.mixed .list .locations .location .location-photos-container {
    float:left;
    margin:0;
}
section.search section#results.mixed .list .locations .location .location-photos-container .carousel img {
    width: 100%;
    border-radius:8px;

}
section.search section#results.mixed .list .locations .location .location-data p.details {
    padding-right: 0;
    margin-right: 0;
    text-align:justify;
    line-height: 1.2em;
}
section.search section#results.mixed div.features {
    padding-bottom:0 !important;
    width: 100% ;
    min-height:2.5em;
}

div.features > div {
  width: 33% !important;
  display: -webkit-flex !important;
  display: flex;
  -webkit-box-pack: start !important;
  justify-content: flex-start !important;
  -webkit-justify-content: flex-start;
}

section.search section#results.mixed .list .locations .location .price-and-types {
  position: absolute;
  right:2%;
  width:auto !important;
  bottom:10%;
  }
section.search section#results.mixed .list .locations .location  .price-and-types > span{
    color:#ff5252;
  }
  .search-index section.search section#results.mixed div.features > div > div{
    width:50%;
  }
  section.search section#results.mixed div.features > div > div:first-of-type {
      margin-left: 10px !important;
  }
section.search section#results.mixed .list .locations .location .location-data a.name {
  width:100% !important;
}
section.search section#results.mixed .list .filters .search-mixed-filter {
  padding:1% 0px !important;
}
section.search section#results.mixed .list .filters .search-mixed-filter ul li.filter-option label.checkbox.small-checkbox span.filter-label-text {
    font-size: 14px !important;
}
section.search section#results.mixed .list .filters .search-mixed-filter ul li.filter-option label.checkbox.small-checkbox {
    margin-top: 0 !important;
}
.search-index section.search section#results.mixed .list .filters .search-mixed-filter:not(:last-of-type) {

    border-bottom: 2px solid white;
}
.search-footer .listings-info {
  text-align: center;
  padding-top:2%;
}
.search-footer .listings-info a, .lux-search-box .lux-search-listings .lux-search-listings-option a{
  text-decoration: underline !important;
  color:#787878;
}
.large-12 #searches li a{
  color:#717171;
}
header#listing_search.mixed .header-inner form {

    padding-bottom: 10px;
}
.lux-search-box{
  padding:5% 0;
  background-color: #fff !important;
}
.lux-search-box .lux-search-listings .lux-search-listings-option {
  font-size:16px;
  text-decoration: underline;
  color:#787878;
}
.lux-search-widget{
  padding-top:5%;
  padding-left:0.5%;

}
.lux-search-widget p {
  margin-bottom: 0;
  padding-bottom:0;
}
.lux-search-widget .breadcrumb{
  background-color: transparent;
  font-size: 16px;
  padding-left:0;
}
.lux-search-widget .breadcrumb li a{
  color: #000;
  text-decoration: underline !important;
}
.lux-search-widget .breadcrumb .fa-home{
  font-size: 18px;
}
.lux-search-widget .breadcrumb > li + li:before {
    color: #000;
    content: '\f105';
    font-family: 'FontAwesome';
  }
.lux-search-widget a.selected-location:after{
  content:',';
}
.lux-search-widget a.selected-location:last-of-type:after{
  content:'';
}
  header#listing_search.mixed {
    background: transparent;
  }
  header#listing_search.mixed a{
    color:white !important;
    border:none !important;
  }
  .btn.btn-blue{
  font-style: normal;
    font-weight: 700;
    background: #00bcd4;
    font-size: 12pt;
    padding-top:2%;
    padding-bottom:2%;
}
header#listing_search.mixed {
  left:22% !important;
}
.lux-search-widget h4{
  padding-top:5%;
}
.location-data a{
  color:#202020;
  font-weight: 500;
}
article.location{
  padding:10px 0;
}
div.features {
  border:none !important;
}
article.location{
  border-bottom: 1px solid #d2d2d2;
  border-top: none !important;
}
.page-not-found-container{
  margin-top:10%;
  padding:5% 0;

  text-align: center;

  background-color: #fbfbfb;
}
.page-not-found-container h1{
  color:#ff5252;
  text-shadow: 5px 5px #ececec;
  font-size:100px;
  font-family: 'Montserrat', sans-serif;
}
.page-not-found-container h2{
  font-weight: 700;
}
.page-not-found-container p{
  font-size:18px;
}
.page-not-found-container p a{
  text-decoration: underline !important;
}
.page-not-found-container p a:first-of-type{
  color:#00bcd4;
}
.page-not-found-container .page-not-found-listings{
  padding: 5%;

}
.page-not-found-container .page-not-found-listings ul li a{
  color:#787777;
}
  @media  screen and (max-width: 680px){

    section.search > .container{
      width:100%;
      padding-left:0;
      padding-right:0;
    }
    section.search section#results.mixed .list .locations{
      margin-top:2% !important;
    }
    section.search section#results.mixed .list .locations .location .location-photos-container .location-photos .carousel img{
      width:100% !important;
      height: 100% !important;
    }
    section.search section#results.mixed .list .locations .location .location-photos-container {
    width: 100% !important;
  }
    .lux-search-widget{
      padding-top: 5px;
      padding-left: 5px;
    }
    .lux-search-widget h4{
      font-size:16px;
    }
    .lux-search-widget p{
      font-size:14px;
    }
    section.search section#results.mixed .list .locations .location .location-data p.details{
      line-height: 1em;
      font-size:15px;
    }
    section.search section#results.mixed .list .locations .location .location-data {
      width: 100% !important;
    }

    div.features > div {
    width: 33%;
    display: -webkit-box;
    display: -webkit-flex;
    display: -ms-flexbox;
    display: flex !important;
    -webkit-box-pack: justify;
    -webkit-justify-content: space-between;
    -ms-flex-pack: justify;
    justify-content: space-between !important;
    }

    section.search section#results.mixed .list .filters{
      top:14% !important;
      width:100% !important;
    }
    section.search section#results.mixed .list .locations .location .price-and-types {
    position: relative;
    width: 100% !important;
    right:0;
    }
    section.search section#results.mixed .list .locations .location .price-and-types a{
      float: right;
    }
    .large-12{
      width:100%;
    }
    .btn.btn-blue{
      padding:4% 15%;
      margin-left:10%;
    }
    header#listing_search.mixed{
      left:0 !important;
    }
    section#hero> div{
      width: 100%;
      padding-right:0;
      padding-left:0;
    }
    .lux-search-box{
      text-align: center;
    }
    .lux-search-widget .breadcrumb .fa-home{
      font-size: 22px;
    }
    .lux-search-widget .breadcrumb li a{
      font-size:14px;
    }
  }
  @media (min-width:682px) and (max-width: 768px) {
    .notify_popup {
      display:none;
    }
    header#listing_search.mixed {
      width: 100%;
    }
  .lux-search-widget {
    padding-top: 1%;
  }
  section.search section#results.mixed .map{
      display:block !important;
      float: left !important;
      width:50% !important;
  }


  section.search section#results.mixed .list .locations .location .location-photos-container .location-photos .carousel img{
    width:100% !important;
    height: 100% !important;
  }
  .search-index .carousel-inner>.active {
    max-height: none;
  }


  section.search section#results.mixed .list .locations .location .location-photos-container{
    width:40% !important;

  }
  section#results.mixed .list .locations .location .location-data {
   width: 60% !important;
   padding: 0 10px !important;
  }
  section.search section#results.mixed .list .locations .location .location-data p.details {

    line-height: 1.1em;
  }
  section.search section#results.mixed .list .filters {
    display: block !important;
    position: absolute !important;
    top: 54% !important;
    left: 0 !important;
    width: 50% !important;
  }
  div.features > div {
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex !important;
  -webkit-box-pack: justify;
  -webkit-justify-content: space-between;
  -ms-flex-pack: justify;
  justify-content: space-between !important;
  width: 33% !important;
  }
  section.search section#results.mixed .list .locations .location .price-and-types {
  position: absolute;
  width: auto !important;
  right:5%;
  bottom:5%;
  }

  #habla_beta_container_do_not_rely_on_div_classes_or_names {
    display: none!important;
}
}
@media (min-width:769px) and (max-width: 1024px) {
  .notify_popup {
    display:none;
  }
  header#listing_search.mixed {
    width: 100%;
  }
.lux-search-widget {
  padding-top: 8%;
}
section.search section#results.mixed .list .locations .location .location-photos-container{
  width:40%;
}

section.search section#results.mixed .map{
    display:block !important;
    float: left !important;
    width:50% !important;
}
section#results.mixed .list {
  width:100% !important;
  margin-top: -3% !important;
}

section.search section#results.mixed .list .locations .location .location-photos-container .location-photos .carousel img{
  width:100% !important;
  height: 100% !important;
}
.search-index .carousel-inner>.active {
  max-height: none;
}
section#results.mixed .list .locations .location .location-data {
 width: 60% !important;
 padding: 0 10px;
}
section.search section#results.mixed .list .locations .location .location-data p.details {

  line-height: 1.1em;
}
section.search section#results.mixed .list .filters {
  display: block !important;
  position: absolute !important;
  top: 53% !important;
  left: 0 !important;
  width: 50% !important;
}
div.features > div {
width: 33% !important;
display: -webkit-box;
display: -webkit-flex;
display: -ms-flexbox;
display: flex !important;
-webkit-box-pack: justify;
-webkit-justify-content: space-between;
-ms-flex-pack: justify;
justify-content: space-between !important;
}
section.search section#results.mixed .list .locations .location .price-and-types {
position: absolute;
width: auto !important;
right:5%;
  bottom:10%;
}

#habla_beta_container_do_not_rely_on_div_classes_or_names {
  display: none!important;
}
}
      }

    end

  end
end

