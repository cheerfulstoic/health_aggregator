defmodule HealthAggregatorWeb.HealthAutoExportController do
  use HealthAggregatorWeb, :controller

  def import(conn, params) do
    # IO.inspect(params, label: :params)

    IO.puts(Jason.encode!(params), limit: :infinity)

    for metrics <- params["data"]["metrics"] do
      HealthAutoExport.import_metrics(metrics["name"], metrics["units"], metrics["data"])
    end

    json(conn, %{success: "sure"})
  end
end
