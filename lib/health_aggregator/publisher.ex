defmodule HealthAggregator.Publisher do
  use GenServer

  alias HealthAggregator.MetricServer
  alias HealthAggregator.Publisher.SFTP

  # Client

  def start_link(metric_type) do
    GenServer.start_link(__MODULE__, metric_type, name: :publisher)
  end

  def generate do
    send(:publisher, :generate)
  end

  # Server

  def init(metric_type) do
    Process.send_after(self(), :generate, 1_000)

    {:ok, metric_type}
  end

  def handle_info(:generate, metric_type) do
    IO.inspect(metric_type, label: :metric_type)

    aggregate_data =
      MetricServer.aggregate(metric_type, :hour, [:min, {:percentile, 25}, {:percentile, 50}, {:percentile, 75}, :max])
      |> IO.inspect(label: :result)

    content = svg("Day Heart Rate", aggregate_data)
           |> Phoenix.HTML.safe_to_string()

    now = DateTime.utc_now()
    SFTP.upload(content, "#{now.year}-#{now.month}-#{now.day}.svg")

    Process.send_after(self(), :generate, 600_000)

    {:noreply, metric_type}
  end

  def svg(title, aggregate_data) do
    timestamps =
      Enum.flat_map(aggregate_data, fn {aggregation_type, values} -> Map.keys(values) end)
      |> Enum.sort()
      |> Enum.uniq()
      |> IO.inspect(label: :timestamps)

    first_timestamp = Enum.min(timestamps)

    if length(timestamps) > 0 do
      data =
        timestamps
        |> Enum.map(fn (timestamp) ->
          time_offset = DateTime.diff(timestamp, first_timestamp)
          Enum.reduce(aggregate_data, %{time_offset: time_offset}, fn {aggregation_type, values}, result ->
            Map.put(result, String.to_atom(inspect(aggregation_type)), values[timestamp])
          end)
        end)
        |> IO.inspect(label: :brap)

      dataset = Contex.Dataset.new(data)

      # dataset = Contex.Dataset.new(data, ["x", "y"])
      pp = Contex.LinePlot.new(dataset, mapping: %{
        x_col: :time_offset,
        y_cols: Map.keys(aggregate_data) |> Enum.map(fn (key) -> String.to_atom(inspect(key)) end),
      })

      Contex.Plot.new(600, 400, pp)
      |> Contex.Plot.plot_options(%{
        legend_setting: :legend_right,
        mapping: %{ bar: "Bar", baz: "Baz" },
      })
      |> Contex.Plot.titles(title, "")
      |> Contex.Plot.to_svg()
    else
      {:safe, ""}
    end
  end

end

