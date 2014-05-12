;(function($, window, document, undefined) {
	var $win = $(window);
	var $doc = $(document);

	$doc.ready(function() {
		$doc.on('focusin', '.form-control, textarea', function() {
			if(this.title==this.value) {
				this.value = '';
			}
		}).on('focusout', '.form-control, textarea', function(){
			if(this.value=='') {
				this.value = this.title;
			}
		});

		if ($('.selectpicker').length ) {
			$('.selectpicker').selectpicker();
		};

		$('.expandable').hide().eq(0).show()

		$('.expand-nav li a').on('click', function () {
			$('.expand-nav li').removeClass('active')
			$(this).parent('li').addClass('active')
			var idx = $(this).parent('li').index()

			$('.expandable').hide().eq(idx).show()

			return false
		})

		$(window).load(function () {
			sliders()
		})

		$(window).resize(function () {
			sliders()
		})

		$('a.link-more').on('click',function (e) {
		    e.preventDefault();

		    var target = $('#myTab'),
		    	$target = $(target);

		    $('html, body').stop().animate({
		        'scrollTop': $target.offset().top
		    }, 900);
		});

		$('.slide-content-buttons a').on('click',function (e) {
		    e.preventDefault();

		    var target = $('.section-form'),
		    	$target = $(target);

		    $('html, body').stop().animate({
		        'scrollTop': $target.offset().top
		    }, 900);
		});

		function sliders () {
			$('.top-slider').show();
			$('.top-slider .slides').carouFredSel({
				responsive: true,
				auto: 4000,
				height: 'variable',
				item: {
					width: '100%',
					height: 'variable'
				}
			})

			$('.slider-small .slides').carouFredSel({
				responsive: true,
				auto: false,
				pagination: '.slider-paging',
				prev: '.slider-actions .prev',
				next: '.slider-actions .next'
			})
		}

		$('.profile').on('mouseenter', function () {
			$(this).find('.profile-content').stop(true, true).fadeIn()
		})
		.on('mouseleave', function () {
			$(this).find('.profile-content').stop(true, true).fadeOut()
		})

		$('#myTab a').click(function (e) {
			e.preventDefault()
			$(this).tab('show')
		})

		$('.carousel').carousel({
		  interval: false
		})

		var ww = $(window).width()

		$('.menu-btn').on('click', function () {
			$('.navbar').fadeToggle()
		})

		// 	var name	 	= ($('#field-name')),
		// 		email	 	= ($('#field-email')),
		// 		company	 	= ($('#field-company')),
		// 		message  	= ($('#field-message')),
		// 		marketplace = ($('#field-marketplace'));

		// $('.form-contact form #field-name').on('focusout',function() {
		// 	if( name.val().length == 0 || name.val() == name.attr('title')) {
		// 		name.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		name.parent('.form-group').addClass('success')
		// 	}
		// })

		// $('.form-contact form #field-company').on('focusout',function() {
		// 	if( company.val().length == 0 || company.val() == company.attr('title')) {
		// 		company.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		company.parent('.form-group').addClass('success')
		// 	}
		// })

		// $('.form-contact form #field-email').on('focusout',function() {
		// 	if(!mailValidation(email.val()) || email.val() == email.attr('title')) {
		// 	  email.parent('.form-group').addClass('error')
		// 	  return false;
		// 	}  else {
		// 		email.parent('.form-group').addClass('success');
		// 		return false;
		// 	}
		// })

		// $('.form-contact form #field-marketplace').on('change',function() {
		// 	if ( marketplace.find(":selected").val() === "" ) {
		// 		marketplace.parent('.form-group').removeClass('success')
		// 		marketplace.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		marketplace.parent('.form-group').addClass('success')
		// 	}
		// })

		// $('.form-contact form #field-message').on('focusout',function() {
		// 	if( message.val().length == 0 || message.val() == message.attr('title')) {
		// 		message.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		message.parent('.form-group').addClass('success')
		// 	}
		// })

		// $(document).on('submit','.form-contact form',function() {
		// 	var name	 = ($('#field-name')),
		// 		email	 = ($('#field-email')),
		// 		company	 = ($('#field-company')),
		// 		message  = ($('#field-message')),
		// 		marketplace = ($('#field-marketplace'));

		// 	$(this).find('input').removeClass('error');

		// 	if( name.val().length == 0 || name.val() == name.attr('title')) {
		// 		name.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		name.parent('.form-group').addClass('success')
		// 	}

		// 	if( company.val().length == 0 || company.val() == company.attr('title')) {
		// 		company.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		company.parent('.form-group').addClass('success')
		// 	}

		// 	if( marketplace.val().length == 0) {
		// 		marketplace.parent('.form-group').addClass('error')
		// 		return false;
		// 	} else {
		// 		marketplace.parent('.form-group').addClass('success')
		// 	}

		// 	if(!mailValidation(email.val()) || email.val() == email.attr('title')) {
		// 	  email.parent('.form-group').addClass('error')
		// 	  return false;
		// 	}  else {
		// 		email.parent('.form-group').addClass('success');

		// 	    var target = $('.success-message-content'),
		// 	    	$target = $(target);

		// 	    $('html, body').stop().animate({
		// 	        'scrollTop': $target.offset().top - 200
		// 	    }, 10);
		// 		return false;
		// 	}

		// })

		// function mailValidation(email) {
		// 	var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
		// 	if(emailReg.test(email) && email.length != 0) {
		// 		return true;
		// 	}
		// }

		$('.success-message').on('click', function () {
			$('.success-message').hide();
		})

		//Forms
		$('#new_platform_contact')
			.bind('ajax:beforeSend', function(event, xhr, status) {
				$(this).find('input[type="submit"]').prop('disabled', true);
			})
			.bind('ajax:success', function(event, xhr, status) {
				$(this).css("visibility", "hidden");
				$('.success-message ').show()
			    var target = $('.success-message-content'),
			    	$target = $(target);
			    $('html, body').stop().animate({
			        'scrollTop': $target.offset().top - 200
			    }, 10);
				ga('send', 'event', 'Form', this.id, 'Submitted')
			}).bind('ajax:error', function(event, xhr, status) {
				$(this).find('.error-block').text(xhr.responseText).css("display", "block");
				// $('html, body').animate({ scrollTop: $(this).offset().top }, 500);
				$(this).find('input[type="submit"]').prop('disabled', false);
			  ga('send', 'event', 'Form', this.id, 'Failed')
			});

	});


})(jQuery, window, document);
