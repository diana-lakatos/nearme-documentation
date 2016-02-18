/* global require, $ */
'use strict';
window.$ = require('jquery');
require('jquery-ujs/src/rails');

(function(){

    var DNM = require('./dnm');

    DNM.registerInitializer(function(){
        var els = $('[data-instance-wizard-form]');
        if (els.length === 0) {
            return;
        }

        require.ensure('./instance_wizard/instance_wizard_form', function(require){
            var InstanceWizardForm = require('./instance_wizard/instance_wizard_form');
            els.each(function(){
                return new InstanceWizardForm(this);
            })
        });
    });

    DNM.run();

    window.DNM = DNM;
}());

