defmodule HealthAggregator.HealthAutoExport do
  @moduledoc "Code to handle data coming from the Health Auto Export app"

  alias HealthAggregator.MetricServer

  def import_metrics("heart_rate", "count/min", data) do
    # We take the "Max" value as the raw data here.  This works if you set
    # the "Period" and "Aggregation" in HAE to "Default" which gives raw data
    # TBD...
    # https://github.com/Lybron/health-auto-export/discussions/8

    values =
      data
      |> Enum.map(fn record ->
        {:ok, datetime} = Timex.parse(record["date"], "%Y-%m-%d %H:%M:%S %z", :strftime)
        {datetime, record["Max"]}
      end)
      |> IO.inspect(label: :values)

    MetricServer.add_values(:heart_rate, values)

    :ok
  end

  # start, stop, distance, temperature, route?
  def handle_workout(workout) do
    HealthAggregator.Handlers.Workout.handle(workout)
  end

  def import_metrics(name, units, _data) do
    {:error, "Unsupported metrics: #{name} / #{units}"}
  end
end

