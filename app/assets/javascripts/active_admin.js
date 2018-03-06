//= require active_admin/base
//= require activeadmin_addons/all
//= require tinymce-jquery
//= require html2canvas

$(document).ready(function(){
  hide_menu();
  scale_chart();

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
    var data_label = attr.replace(/_/, " ");
    $(this).attr("data-label", data_label);
  });

  if ($(".index_as_column_chart").length || $(".index_as_barchart").length){
    $("#index_footer").hide();
  }

  $("body").on("click", "#site_title .fa-bars", function(){
    var header_height = $("#header").height();
    $("#tabs").animate({top: header_height});
    $(".fa-bars").remove();
    $("#site_title").prepend("<i class=\"fas fa-times\"></i>");
  });

  $("body").on("click", "#site_title .fa-times", function(){
    var tab_height = $("#tabs").height();
    $("#tabs").animate({top: "-"+tab_height});
    $(".fa-times").remove();
    $("#site_title").prepend("<i class=\"fas fa-bars\"></i>");
  });

  $("#header ul.tabs > li").click(function(){
    $(this).find("ul").toggle();
  });
});

$(window).resize(hide_menu);
$(window).resize(scale_chart);

function hide_menu(){
  if ($(window).width() <= 767){
    if ($("#site_title svg").length === 0){
      $("#site_title").prepend("<i class=\"fas fa-bars\"></i>");
    }
    $("#site_title a").css("margin-left","7px");  
    if ($("#site_title svg").hasClass("fa-bars")){
      $("#tabs").css({
        "top": "calc(-100vh + 41px)",
        "display": "block"
      });        
    }
  } else {
    $("#site_title svg").remove();
    $("#site_title a").css("margin-left","0");
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