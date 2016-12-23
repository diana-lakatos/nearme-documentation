let windowWidth = document.documentElement.clientWidth;

const getPlacement = () => {
  return windowWidth < 481 ? 'auto bottom' : 'auto right';
};

module.exports = {
  placement: getPlacement(), // it has precende over data-placement attribute in html
  viewport: 'body'
};
