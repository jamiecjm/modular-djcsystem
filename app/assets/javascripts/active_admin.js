//= require active_admin/base
//= require activeadmin_addons/all
//= require tinymce-jquery
//= require html2canvas

$(document).ready(function(){
  // $('a.popup').click(function(e) {
  //   e.stopPropagation();  // prevent Rails UJS click event
  //   e.preventDefault();

  //   ActiveAdmin.modal_dialog("Send report to: ", {emails: 'text'}, function(inputs) {
  //   	alert (inputs.emails)
  //   })
  // })	
  if ($('.index_as_column_chart').length || $('.index_as_barchart').length){
  	$('#index_footer').hide();
  }
})