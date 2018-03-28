$(document).ready(function(){
	$('a[data-action=change_upline_of]').click(function(){
		$.get({
			url: '/users/get_all',
			dataType: 'JSON',
			success: function(data){
				$('select[name=upline]').append('<option value='+null+'> </option>');
			    data.forEach(function(item, index){
			        $('select[name=upline]').append('<option value='+item[0]+'>'+item[1]+'</option>');
			    });
			},
			error: function(){
				alert('Error 500')
			}
		});
		$('.ui-dialog').removeAttr('tabindex');
		$('.ui-dialog select[name=upline]').select2({});
	});
});