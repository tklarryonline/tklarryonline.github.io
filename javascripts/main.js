$(function() {
    return $.each($("[data-time]"), function(index, ele) {
        return $(ele).html(prettyDate(new Date($(this).data("time"))));
    });
});
