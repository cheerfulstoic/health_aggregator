defmodule HealthAggregatorWeb.HealthAutoExportController do
  use HealthAggregatorWeb, :controller

  alias HealthAggregator.HealthAutoExport

  def import(conn, params) do
    IO.inspect(params, label: :params)
    # for metrics <- params["data"]["metrics"] do
    #   :ok = HealthAutoExport.import_metrics(metrics["name"], metrics["units"], metrics["data"])
    # end

    for workout <- params["data"]["workouts"] do
      :ok = HealthAutoExport.handle_workout(workout)
    end

    json(conn, %{success: "sure"})
  end
end
