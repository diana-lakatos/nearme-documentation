# Lets keep here list of good practices

## Frontend

### Don't hardcode URLs to assets in liquids

Bad:
```html
<div class="ugly">
  <img src="https://8b7d8a1812d735c99cea.ssl.cf4.rackcdn.com/2016/assets/images/testimonials/example.jpg"/>
</div>
```

Good:
```html
<div class="nice">
  <img src="{{asset_url['example.jpg']}}"/>
</div>
```

How to use it?
  - Create custom theme (default one) and add custom asset via MPA
  - Use MarketplaceBuilder (example: https://github.com/mdyd-dev/desksnearme/tree/staging/marketplaces/csn/custom_themes)
