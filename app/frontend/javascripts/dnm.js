'use strict';

module.exports = {
    initializers: [],
    callbacks: {
        beforeInit: [],
        afterInit: []
    },

    run: function(){

        this.callbacks.beforeInit.forEach(function(callback){
            callback();
        });

        this.initializers.forEach(function(callback){
            callback();
        });

        this.callbacks.afterInit.forEach(function(callback){
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

