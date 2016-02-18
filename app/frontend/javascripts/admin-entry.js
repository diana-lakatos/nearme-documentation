'use strict';
window.$ = require('jquery');
require('jquery-ujs/src/rails');
require('../vendor/bootstrap');

(function(){

    var DNM = require('./dnm');

    DNM.registerInitializer(function(){
        $(document).on('linechart.dnm', function(event, el, values, labels){
            require.ensure('./components/chart/line', function(require){
                var LineChart = require('./components/chart/line');
                new LineChart(el, values, labels);
            });
        });
    });

    DNM.run();

    window.DNM = DNM;
}());

