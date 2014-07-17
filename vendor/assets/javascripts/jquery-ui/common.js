$(function(){


// Block Skip

	$('p.skip a').focus(function(){
		$(this).addClass('show');
	});
	$('p.skip a').blur(function(){
		$(this).removeClass('show');
	});


// TableCell Class

	$('table').each(function(){
		$('tr:first-child th',this).each(function(i){
			i = i + 1;
			var cell_class = $(this).attr('class');
			$(this).parents('table').find('tr :nth-child('+ i +')').addClass(cell_class);
		});
	});
	


// FixPng

	if($.browser.msie && $.browser.version<9){
		$('img[src$=".png"]').fixPng();
	}


});
