$(function () {
$('#input-id').rating();
$('#input-id').on('change', function () {
alert('Rating: ' + $(this).val());
});
$('#programmatically-set').click(function () {
$('#programmatically-rating').rating('rate', $('#programmatically-value').val());
});
$('#programmatically-get').click(function () {
alert($('#programmatically-rating').rating('rate'));
});
$('.rating-tooltip').rating({
  extendSymbol: function (rate) {
  $(this).tooltip({
    container: 'body',
    placement: 'bottom',
    title: 'Rate ' + rate
  });
}
});
$('.rating-tooltip-manual').rating({
  extendSymbol: function () {
    var title;
$(this).tooltip({
  container: 'body',
  placement: 'bottom',
  trigger: 'manual',
  title: function () {
return title;
}
});
$(this).on('rating.rateenter', function (e, rate) {
title = rate;
$(this).tooltip('show');
})
.on('rating.rateleave', function () {
$(this).tooltip('hide');
});
}
});
$('.rating').each(function () {
$('<span class="label label-default"></span>')
.text($(this).val() || ' ')
.insertAfter(this);
});
$('.rating').on('change', function () {
$(this).next('.label').text($(this).val());
});
});