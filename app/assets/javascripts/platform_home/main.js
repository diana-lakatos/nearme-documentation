(function($){

	$(document).ready(function(){
    // Flash
    Flash.initialize();

		//Vars
		var $tabs = $('.tab'),
			$tabsNav = $('.tabs-nav');
			$tabsVisible = $('#tab1, #tab6'),
			isTouch = 'ontouchstart' in document,
			$nav = $('.nav-menu').parent();

		// touch check
		$('html').addClass(isTouch ? 'touch' : 'no-touch');

		// menu
		$('.nav-menu').on('click', function(e) {

			$nav.toggleClass('mobile');

			e.preventDefault();

		});

		//Tabs
		$tabs.not($tabsVisible).hide();
		$tabsNav.find('li:first-child').addClass('current');
		$tabsNav.on('click', 'a', function(e){

			var $this = $(this),
				$parent = $this.parent(),
				href = $this.attr('href');

			if (!$parent.hasClass('current')) {

				$parent.addClass('current');
				$parent.siblings().removeClass('current');

				$tabs.filter(href).show().siblings().hide();

			}

			e.preventDefault();

		});

		//Scroll
		$(".scroll-list").simplyScroll({
            orientation: 'vertical'
        });

    //Checkboxes
		$('.checkbox input').iCheck();

		//Forms
		$('#new_platform_contact')
			.bind('ajax:beforeSend', function(event, xhr, status) {
				$(this).find('input[type="submit"]').attr('disabled','disabled');
			})
			.bind('ajax:success', function(event, xhr, status) {
				$(this).replaceWith(xhr);
			});

		$('#new_platform_demo_request')
			.bind('ajax:beforeSend', function(event, xhr, status) {
				$(this).find('input[type="submit"]').attr('disabled','disabled');
			})
			.bind('ajax:success', function(event, xhr, status) {
				$(this).replaceWith(xhr);
			});

	});

})(jQuery);
