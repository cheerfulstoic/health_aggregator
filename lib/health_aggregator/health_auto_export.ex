defmodule HealthAggregator.HealthAutoExport do
  @moduledoc "Code to handle data coming from the Health Auto Export app"

  def import_metrics("heart_rate", "count/min", data) do
    # We take the "Max" value as the raw data here.  This works if you set
    # the "Period" and "Aggregation" in HAE to "Default" which gives raw data
    # TBD...
    # https://github.com/Lybron/health-auto-export/discussions/8


    :ok
  end

  def import_metrics(name, units, _data) do
    {:error, "Unsupported metrics: #{name} / #{units}"}
  end
end

