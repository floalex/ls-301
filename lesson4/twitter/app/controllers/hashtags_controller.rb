class HashtagsController < ApplicationController
  def show
    @statuses = Status.where("body LIKE ?", "%##{params[:id]}%")
  end
end
