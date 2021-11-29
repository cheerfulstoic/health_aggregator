defmodule HealthAggregator.Handlers.Workout do
  use GenServer

  alias HealthAggregator.Publisher.SFTP

  def process_name do
    :workout_handler
  end

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: process_name())
  end

  def handle(workout) do
    GenServer.cast(process_name(), {:handle, workout})
  end

  # Server

  def init(nil) do
    {:ok, nil}
  end

  # List with "date" and "qty" ("units" == "bpm")
  def handle_cast({:handle, %{"start" => start, "name" => name, "heartRateData" => heart_rate_data, "heartRateRecovery" => heartRateRecovery}}, state) do

    aggregate_data =
      heart_rate_data
      |> Enum.map(fn (record) ->
        # TODO: This is doing HealthAutoExport stuff, so it should go there
        {:ok, datetime} = Timex.parse(record["date"], "%Y-%m-%d %H:%M:%S %z", :strftime)
        {datetime, record["qty"]}
      end)
      |> HealthAggregator.MetricServer.Calculate.aggregate(:second, [:min, :max])

    svg_content = HealthAggregator.Publisher.svg("#{name} Heart Rate", aggregate_data)
                  |> Phoenix.HTML.safe_to_string()

    {:ok, start_date} = Timex.parse(start, "%Y-%m-%d %H:%M:%S %z", :strftime)
    SFTP.upload(svg_content, "workouts/#{start_date.year}-#{start_date.month}-#{start_date.day}-#{name}.svg")

    # Extract out code to aggregate?  Do I need to send this to the metrics server?
    # I guess it's in MetricServer.Calculate.  Should it be elsewhere?

    {:noreply, state}
  end
end

