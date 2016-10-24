$(function () {
    $( ".review" ).each(function( ) {
        var review = $( this).children("#input_review");
        var stars = review.data("readonly");

        review.rating('rate',stars);
    });
})

$('.edit_review').submit(function(event) {

    /* stop form from submitting normally */
  event.preventDefault();

  /* get values from elements on the page: */
  var from_user = $('#review_from_user').val();
  var to_item = $('#review_to_item').val();
  var content = $('#review_content').val();
  var stars = $('#input-id').val();

  /* Send the data using post and put the results in a div */
  $.ajax({
    url: "/reviews",
    type: "post",
    dataType: "html",
    data: { review: { from_user: from_user, to_item: to_item,content: content,stars:stars } },
    success: function() {
      location.reload();
    },
  });
  return false;
});