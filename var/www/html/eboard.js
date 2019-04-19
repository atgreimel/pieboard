$(document).ready(function() {

    var oneSecond = 1000; // 1s = 1000 ms
    var oneMinute = oneSecond * 60;
    var pageInterval = oneSecond * 5; // 5 seconds
    var fetchInterval = oneMinute * 5; // 5 minutes
    var slides = [];
    var slideCount = 1;
    var currentSlide = 0;

    var urlParameters = window.location.search;

    // fetch daily slides
    function fetchSlides() {
        $.getJSON("eboard.php" + urlParameters, function(json) {
            var result = JSON.parse(json);
            if (result.success) {
                slides = result.slides;
                slideCount = result.slides.length;
                $("#counter span").empty();
                count = slideCount;
                while (count-- > 0) {
                    $("#counter").append("<span>&bull;</span>");
                }
            }
        });
    };

    // page through slides
    function pageSlides() {
        var date = new Date();
        $("#date").html(date.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }));
        $("#time").html(date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }));
        $("#main").html(slides[currentSlide]);
        $("#counter span.current").removeClass("current");
        $("#counter span").eq(currentSlide).addClass("current");
        currentSlide++;
        if (currentSlide >= slideCount) currentSlide = 0;
    };


    // fetch immediately, then repeat at fetchInterval
    fetchSlides();
    setInterval(fetchSlides, fetchInterval);

    // repeat paging at pageInterval
    // since fetchSlides is asynchronous, it won't have a result yet
    // so we can't run pageSlides immediately
    setInterval(pageSlides, pageInterval);

});
