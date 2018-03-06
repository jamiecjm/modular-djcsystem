//= require active_admin/base
//= require activeadmin_addons/all
//= require tinymce-jquery
//= require html2canvas

$(document).ready(function(){
  hide_menu();
  scale_chart();
  add_sort_order_form();

  $('#tabs').append($('#utility_nav li').clone());

  $("#active_admin_content.with_sidebar #sidebar").append("<div class=filter-trigger><i class=\"fas fa-filter\"></i></div>");

  $("body").on("click", ".filter-trigger", function(){
    if ($("#sidebar").position().left > $(window).width()){
      $("#sidebar").animate({right: 0});
    }else{
      $("#sidebar").animate({right: -285});
    }
  });

  $(".col").each(function(){
    var attr = $(this).attr("class").replace(/col /, "");
    attr = attr.replace(/col-/, "");
    var data_label = attr.replace(/_/, ' ');
    $(this).attr("data-label", data_label);
  });

  if ($(".index_as_column_chart").length || $(".index_as_barchart").length){
    $("#index_footer").hide();
  }

  $("body").on("click", "#header .fa-bars", function(){
    var header_height = $("#header").height();
    $("#tabs").animate({top: header_height});
    $(".fa-bars").remove();
    $("#header").prepend("<i class=\"fas fa-times\"></i>");
  });

  $("body").on("click", "#header .fa-times", function(){
    var tab_height = $("#tabs").height();
    $("#tabs").animate({top: "-"+tab_height});
    $(".fa-times").remove();
    $("#header").prepend("<i class=\"fas fa-bars\"></i>");
  });

  $("#header ul.tabs > li").click(function(){
    $(this).find("ul").toggle();
  });
});

$(window).resize(hide_menu);
$(window).resize(scale_chart);

function hide_menu(){
  if ($(window).width() <= 767){
    if ($("#header svg").length === 0){
      $("#header").prepend("<i class=\"fas fa-bars\"></i>");
    }
    if ($("#header svg").hasClass("fa-bars")){
      $("#tabs").css({
        "top": "calc(-100vh + 54px)",
        "display": "block"
      });        
    }
  } else {
    $("#header svg").remove();
    $("#tabs").css({
      "top": "2px",
      "display": "table-cell"
    });  
  }
}

function scale_chart(){
  if($(window).width() <= 767){
    scale = ($("#active_admin_content").width()-15)/1200;
    $("#chart").css("transform", "scale("+scale+")");
  } else {
    $("#chart").css("transform", "none");
  } 
}

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
    h_item = item.replace(/_/, ' ').replace(/\./,' ').toUpperCase();
    options += '<option value='+item+'_asc>'+h_item+' ASC</option>';
    options += '<option value='+item+'_desc>'+h_item+' DESC</option>';
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

}

function onlyUnique(value, index, self) { 
    return self.indexOf(value) === index;
}