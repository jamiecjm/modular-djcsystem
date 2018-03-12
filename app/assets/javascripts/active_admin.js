//= require active_admin/base
//= require admin/header
//= require activeadmin_addons/all
//= require tinymce-jquery
//= require html2canvas
//= require admin/sidebar

$(window).on('load', function () {
  $('#active_admin_content').css('opacity', 1);
});

Raven.config('https://16953ced506c444d854b48cf17b09651@sentry.io/298281').install();
Raven.context(function () {

  $(document).ready(function(){
    scale_chart();

    $(".col").each(function(){
      var attr = $(this).attr("class").replace(/col /, "");
      attr = attr.replace(/col-/, "");
      var data_label = attr.replace(/_/g, ' ');
      $(this).attr("data-label", data_label);
    });

    if ($(".index_as_column_chart").length || $(".index_as_barchart").length){
      $("#index_footer").hide();
    }
  });

  $(window).resize(scale_chart);

  function scale_chart(){
    if($(window).width() <= 767){
      scale = ($("#active_admin_content").width()-15)/1200;
      $("#chart").css("transform", "scale("+scale+")");
    } else {
      $("#chart").css("transform", "none");
    } 
  } 

});
