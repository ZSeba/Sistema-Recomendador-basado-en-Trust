$(function () {
    $( ".review" ).each(function( ) {
        var review = $( this).children("#input_review");
        var stars = review.data("stars");

        review.rating('rate',stars);
    });
})
