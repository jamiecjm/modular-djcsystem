$(document).ready(function(){
  $('#menu').clone().insertAfter('#header h1');
  $('#header #tabs #menu').remove();
  $('#menu').click(function(){
    $("#tabs").toggleClass('visible');
    if ($('#tabs').hasClass('visible')){
      $("#tabs").animate({top: 0});
    } else {
      $("#tabs").animate({top: "-100vh"});
    } 
  });
  $('#header #tabs > li.current ul').addClass('opened');
  $("#header ul.tabs > li").click(function(){
    $("#header ul.tabs > li ul").not($(this).find("ul")).removeClass('opened');
    $(this).find("ul").toggleClass('opened');
  });

  $('#title_bar').click(function(){
    $('.logged_in #title_bar, #active_admin_content, #footer, .logged_in .flashes, #header #tabs').toggleClass('hidden')
  })
});
