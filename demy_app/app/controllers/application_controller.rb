class ApplicationController < ActionController::Base
  def hello_world
    render 'application/hello_world'  ## equals to `render inline: File.read('app/views/application/hello_world.html')`
  end
end
