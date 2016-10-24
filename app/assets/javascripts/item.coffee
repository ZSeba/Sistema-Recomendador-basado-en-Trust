# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready', ()->
	$( ".sortable" ).sortable
		cursor: "move",
		update: (e, ui)->
			ranking = []
			$(@).find('.recommended-item').each ()->
				$(this).find('.index').html($(this).index()+1)
			$('.recommended-item').each ()->
				ranking.push($(this).find('.index').text())
				ranking.push($(this).find('.name').text())
			$('#user_test_ranking').val(ranking.toString())
	$( ".sortable" ).disableSelection()
