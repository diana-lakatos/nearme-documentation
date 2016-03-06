'use strict';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');

$( document ).ajaxError(function( event, jqxhr, settings, errorThrown ) {
    if (window.Raygun) {
        window.Raygun.send(jqxhr.statusText, "Data: " + settings.data + "\n\n" + jqxhr.responseText);
    }
});

module.exports = {
    initializers: [],
    callbacks: {
        beforeInit: [],
        afterInit: []
    },

    run: function(){

        $.each(this.callbacks.beforeInit, function(index, callback){
            callback();
        });

        $.each(this.initializers, function(index, callback){
            callback();
        });

        $.each(this.callbacks.afterInit, function(index, callback){
            callback();
        });
    },

    registerCallback: function(type, callback) {
        this.callbacks[type].push(callback);
    },

    registerInitializer: function(callback) {
        this.initializers.push(callback);
    }
};

