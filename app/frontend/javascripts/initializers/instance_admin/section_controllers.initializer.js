var main = $('#main-container');

if (main.hasClass('listings')) {
  require.ensure('../../instance_admin/sections/listings', function(require){
    var InstanceAdminListingsController = require('../../instance_admin/sections/listings');
    new InstanceAdminListingsController(main);
  });
}

if (main.hasClass('products')) {
  require.ensure('../../instance_admin/sections/products', function(require){
    var InstanceAdminProductsController = require('../../instance_admin/sections/products');
    new InstanceAdminProductsController(main);
  });
}

if (main.hasClass('documents_upload')) {
  require.ensure('../../instance_admin/sections/documents_upload', function(require){
    var InstanceAdminDocumentsUploadController = require('../../instance_admin/sections/documents_upload');
    new InstanceAdminDocumentsUploadController(main);
  });
}

if (main.hasClass('seller_attachments')) {
  require.ensure('../../instance_admin/sections/seller_attachments', function(require){
    var InstanceAdminSellerAttachmentsController = require('../../instance_admin/sections/seller_attachments');
    new InstanceAdminSellerAttachmentsController(main);
  });
}

if (main.find('.content-container.reports').length > 0) {
  require.ensure('../../instance_admin/sections/listings', function(require){
    var InstanceAdminListingsController = require('../../instance_admin/sections/listings');
    new InstanceAdminListingsController(main);
  });
}

if (main.hasClass('users') || main.hasClass('projects') || main.hasClass('groups')) {
  require.ensure('../../instance_admin/sections/users', function(require){
    var InstanceAdminUsersController = require('../../instance_admin/sections/users');
    new InstanceAdminUsersController(main);
  });
}

if (main.hasClass('reviews')) {
  require.ensure('../../instance_admin/sections/reviews', function(require){
    var InstanceAdminReviewsController = require('../../instance_admin/sections/reviews');
    new InstanceAdminReviewsController(main);
  });
}

if (main.hasClass('rating_systems')) {
  require.ensure('../../instance_admin/sections/rating_systems', function(require){
    var InstanceAdminRatingSystemsController = require('../../instance_admin/sections/rating_systems');
    new InstanceAdminRatingSystemsController(main);
  });
}

if (main.hasClass('spam_reports')) {
  require.ensure('../../instance_admin/sections/spam_reports', function(require){
    var InstanceAdminSpamReportsController = require('../../instance_admin/sections/spam_reports');
    new InstanceAdminSpamReportsController(main);
  });
}

if (main.hasClass('projects') || main.hasClass('advanced_projects')) {
  require.ensure('../../instance_admin/sections/projects', function(require){
    var InstanceAdminProjectsController = require('../../instance_admin/sections/projects');
    new InstanceAdminProjectsController(main);
  });
}

if (main.hasClass('custom_attributes')) {
  require.ensure('../../instance_admin/sections/custom_attributes', function(require){
    var InstanceAdminCustomAttributesController = require('../../instance_admin/sections/custom_attributes');
    new InstanceAdminCustomAttributesController(main);
  });
}
