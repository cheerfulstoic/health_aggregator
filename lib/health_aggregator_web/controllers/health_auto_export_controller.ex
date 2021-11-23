defmodule HealthAggregatorWeb.HealthAutoExportController do
  use HealthAggregatorWeb, :controller

  def index(conn, params) do
    IO.inspect(params, label: :params)

    for metrics <- params["data"]["metrics"] do
      HealthAutoExport.import_metrics(metrics["name"], metrics["units"], metrics["data"])
    end

    json(conn, %{success: "sure"})
  end
end
