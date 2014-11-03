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

		$('.expandable').hide();

		$('.expand-nav li a').on('click', function () {
			$('.expand-nav li').removeClass('active')
			$(this).parent('li').addClass('active')
			var idx = $(this).parent('li').index()

			$('.expandable').hide().eq(idx).show()
            var href = $(this).attr("href");
            history.pushState({}, '', href);

			return false;
		})
        if(window.location.hash){
          $('.expand-nav li a[href=' + window.location.hash + ']').click();
        } else {
          $('.expand-nav li a').eq(0).click();
        }

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

		var name              = ($('#field-name')),
		    company           = ($('#field-company')),
		    email             = ($('#field-email')),
		    phone             = ($('#field-phone')),
		    description       = ($('#field-description'));

		$('.form-contact form #field-name').on('focusout',function() {
			if( name.val().length == 0 || name.val() == name.attr('title')) {
				name.parent('.form-group').addClass('error').removeClass('success')
			} else {
				name.parent('.form-group').addClass('success').removeClass('error')
			}
		})

		$('.form-contact form #field-company').on('focusout',function() {
			if( company.val().length == 0 || company.val() == company.attr('title')) {
				company.parent('.form-group').addClass('error').removeClass('success')
				return false;
			} else {
				company.parent('.form-group').addClass('success').removeClass('error')
			}
		})

		$('.form-contact form #field-email').on('focusout',function() {
			if(!mailValidation(email.val()) || email.val() == email.attr('title')) {
			  email.parent('.form-group').addClass('error').removeClass('success')
			  return false;
			}  else {
				email.parent('.form-group').addClass('success').removeClass('error')
				return false;
			}
		})

		$('.form-contact form #field-phone').on('focusout',function() {
			if( phone.val().length == 0 || phone.val() == phone.attr('title')) {
				phone.parent('.form-group').addClass('error').removeClass('success')
				return false;
			} else {
				phone.parent('.form-group').addClass('success').removeClass('error')
			}
		})

		$('.form-contact form #field-description').on('focusout',function() {
			if( description.val().length == 0 || description.val() == description.attr('title')) {
				description.parent('.form-group').addClass('error').removeClass('success')
				return false;
			} else {
				description.parent('.form-group').addClass('success').removeClass('error')
			}
		})

		function validateForm() {
			var name              = ($('#field-name')),
			    company           = ($('#field-company')),
			    email             = ($('#field-email')),
			    phone             = ($('#field-phone')),
			    description       = ($('#field-description')),
			    valid             = true;

			$(this).find('input').removeClass('error');

			if( name.val().length == 0 || name.val() == name.attr('title')) {
				name.parent('.form-group').addClass('error').removeClass('success')
				valid = false;
			} else {
				name.parent('.form-group').addClass('success').removeClass('error')
			}

			if( company.val().length == 0 || company.val() == company.attr('title')) {
				company.parent('.form-group').addClass('error').removeClass('success')
				valid = false;
			} else {
				company.parent('.form-group').addClass('success').removeClass('error')
			}

			if(!mailValidation(email.val()) || email.val() == email.attr('title')) {
			  email.parent('.form-group').addClass('error').removeClass('success')
			  valid = false;
			}  else {
				 email.parent('.form-group').addClass('success').removeClass('error')
			}

			if( phone.val().length == 0 || phone.val() == phone.attr('title')) {
				phone.parent('.form-group').addClass('error').removeClass('success')
				valid = false;
			} else {
				phone.parent('.form-group').addClass('success').removeClass('error')
			}

			if( description.val().length == 0 || description.val() == description.attr('title')) {
				description.parent('.form-group').addClass('error').removeClass('success')
				valid = false;
			} else {
				description.parent('.form-group').addClass('success').removeClass('error')
			}

			return valid;
		}

		function mailValidation(email) {
			var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
			if(emailReg.test(email) && email.length != 0) {
				return true;
			}
		}

		$('.success-message').on('click', function () {
			$('.success-message').hide();
		})

		//Forms
		$('#new_platform_contact')
			.bind('ajax:beforeSend', function(event, xhr, status) {
				if(validateForm()) {
					$(this).find('button[type="submit"]').text('Submitting...').prop('disabled', true);
				} else {
					alert('Please fix form errors to submit!');
					return false;
				}
			})
			.bind('ajax:success', function(event, xhr, status) {
				$(this).find('.error-block').hide();
				$(this).find('button[type="submit"]').text('Submitted!').prop('disabled', true);
				$('.success-message ').show()
			    $('html, body').stop().animate({ 'scrollTop': $('.success-message-content').offset().top - 200 }, 500);
				ga('send', 'event', 'Form', document.URL, 'Submitted')
			})
			.bind('ajax:error', function(event, xhr, status) {
				$(this).find('.error-block').text(xhr.responseText).css("display", "block");
				$(this).find('button[type="submit"]').text('SEND').prop('disabled', false);
			  ga('send', 'event', 'Form', document.URL, 'Failed')
			});

	});


})(jQuery, window, document);
