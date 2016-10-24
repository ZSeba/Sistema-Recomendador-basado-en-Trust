class HomeController < ApplicationController
  def index
  end

  def rate_sample
  	@sample_items = Item.get_test_sample
  end

  def sort_result
  	
  end
end
