defmodule HealthAggregatorWeb.HealthAutoExportController do
  use HealthAggregatorWeb, :controller

  alias HealthAggregator.HealthAutoExport

  def import(conn, params) do
    for metrics <- params["data"]["metrics"] do
      :ok = HealthAutoExport.import_metrics(metrics["name"], metrics["units"], metrics["data"])
    end

    json(conn, %{success: "sure"})
  end
end
