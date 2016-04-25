$(function() {
    $("textarea").autogrow();

    var hammertime = new Hammer(document.body, {});
    hammertime.on("swiperight", function(event) {
        $(".mdl-layout__drawer-button").trigger("click");
    });
});
