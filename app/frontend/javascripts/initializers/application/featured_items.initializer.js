let els = document.querySelectorAll('.featured-items-loader');
if (els.length > 0) {
  require.ensure('../../components/featured_items', (require)=>{
    const FeaturedItems = require('../../components/featured_items');

    Array.prototype.forEach.call(els, (loader: HTMLElement) => {
      new FeaturedItems(loader);
    });
  });
}
