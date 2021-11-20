defmodule HealthAggregatorWeb.PageController do
  use HealthAggregatorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
