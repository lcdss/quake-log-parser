require Rails.root.join('app/services/quake_log_parser_service')

class HomeController < ApplicationController
  def index
  end

  def report
    if params[:log].blank?
      flash[:error] = 'The log field is required.'
      return redirect_to '/'
    end

    @log_data = QuakeLogParserService.new(params[:log].path).log_data
  end
end
