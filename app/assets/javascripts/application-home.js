//
//= require jquery
//= require ./home/jquery.browser.min
//= require ./home/jquery.form
//= require ./home/jquery.queryloader2
//= require ./home/modernizr-2.6.2.min
//= require ./home/jquery.fitvids
//= require ./home/jquery.appear
//= require ./home/jquery.slabtext.min
//= require ./home/jquery.fittext
//= require ./home/jquery.easing.min
//= require ./home/jquery.parallax-1.1.3
//= require ./home/jquery.prettyPhoto
//= require ./home/jquery.sticky
//= require ./home/selectnav.min
//= require ./home/SmoothScroll
//= require ./home/jquery.flexslider-min
//= require ./home/isotope
//= require ./home/bootstrap-modal
//= require ./home/shortcodes
//= require ./home/scripts
//

$( document ).ready(function() {
  setTimeout(function() {
    $(".features-nav-item").removeClass("active");
    $(".home-nav-item").addClass("active");
  }, 200);
});
