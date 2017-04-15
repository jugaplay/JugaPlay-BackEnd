class Admin::HomeController < Admin::BaseController
  def index
    @can_be_closed_tables = Table.can_be_closed
  end
end
