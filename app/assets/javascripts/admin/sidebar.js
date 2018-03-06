$(document).ready(function(){

  add_sort_order_form();

  $("#active_admin_content.with_sidebar #sidebar").append("<div class=filter-trigger><i class=\"fas fa-filter\"></i></div>");

  $("body").on("click", ".filter-trigger", function(){
    $('#main_content_wrapper').toggleClass('disabled');
    if ($("#sidebar").position().left > $(window).width()){
      $("#sidebar").animate({right: 0});
    }else{
      $("#sidebar").animate({right: -285});
    }
  });

});

function add_sort_order_form(){
  var attrs = [];
  $('thead a').each(function(){
    var value = $(this).attr('href').replace(/.+order=/,'').replace(/&.+/,'');
    value = value.replace(/_desc/,'');
    value = value.replace(/_asc/,'');
    attrs.push(value);
  });
  attrs = attrs.filter(onlyUnique);
  options = '';
  attrs.forEach(function(item){
    var h_item = item.replace(/_/, ' ').replace(/\./,' ').toUpperCase();
    var item_asc = item+'_asc'
    var item_desc = item+'_desc'
    var default_val = getUrlParameter('order');
    var asc_selected = '';
    var desc_selected = '';
    if (default_val === item_asc){
      asc_selected = 'selected=selected'
    }
    else if (default_val === item_desc) {
      desc_selected = 'selected=selected'
    }

    options += '<option value='+item_asc+' '+asc_selected+'>'+h_item+' ASC</option>';
    options += '<option value='+item_desc+' '+desc_selected+'>'+h_item+' DESC</option>';
  });
  $('#active_admin_content.with_sidebar #sidebar').prepend('<div class="mobile-only sidebar_section panel" id="sort_sidebar_section">' +
          '<h3>Sort</h3>' +
          '<div class="panel_contents">' +
            '<form action='+window.location.pathname+' class="filter_form">' +
              '<label class="label">Attributes</label>' +
              '<div class="filter_form_field">' +
                '<select name="order">'+options+'</select>' +
              '</div>' +
              '<input type="submit">' +
            '</form>' +
          '</div>' +
        '</div>');
  $( "select[name=order]" ).select2({});

}

function onlyUnique(value, index, self) { 
    return self.indexOf(value) === index;
}

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};