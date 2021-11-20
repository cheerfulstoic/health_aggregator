defmodule HealthAggregatorWeb.HealthAutoExportController do
  use HealthAggregatorWeb, :controller

  def index(conn, params) do
    IO.inspect(params, label: :params)

    json(conn, %{success: "sure"})
  end
end
