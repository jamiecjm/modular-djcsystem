$(document).ready(function(){
  hide_menu();

  $('#tabs').append($('#utility_nav li').clone());

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
