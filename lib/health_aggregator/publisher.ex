defmodule HealthAggregator.Publisher do
  use GenServer

  alias HealthAggregator.MetricServer

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

    # blah = chunk_html(%{aggregate_data: aggregate_data})
    #        |> Phoenix.HTML.unsafe()

    blah = svg(aggregate_data)
           |> Phoenix.HTML.safe_to_string()

    # IO.inspect(blah, label: :blah)

    # File.write!("test.html", blah)
    publish_svg(blah)

    Process.send_after(self(), :generate, 10_000)

    {:noreply, metric_type}
  end

  def publish_svg(content) do
    now = DateTime.utc_now()

    options = [
      host: System.get_env("SFTP_DOMAIN"),
      user: System.get_env("SFTP_USER"),
      password: System.get_env("SFTP_PASSWORD"),
    ]

    root_path = System.get_env("SFTP_ROOT_PATH")
    path = "#{root_path}#{now.year}-#{now.month}-#{now.day}.svg"

    IO.puts("Uploading to #{path}")
    SFTPClient.connect(options, fn conn ->
      IO.inspect(String.length(content), label: :length)
      {:ok, pid} =
        StringIO.open(content)
      source_stream =
        IO.binstream(pid, :line)
      target_stream = SFTPClient.stream_file!(conn, path)

      source_stream
      Enum.into([content], target_stream)
      # |> Stream.into(target_stream)
      |> Stream.run()
    end)
    IO.puts("Uploaded!")
  end

  require EEx
  EEx.function_from_file(:def, :chunk_html, "lib/health_aggregator/publisher/chunk.html.eex", [:assigns], engine: Phoenix.HTML.Engine)

  def svg(aggregate_data) do
    timestamps =
      Enum.flat_map(aggregate_data, fn {aggregation_type, values} -> Map.keys(values) end)
      |> Enum.sort()
      |> Enum.uniq()
      |> IO.inspect(label: :timestamps)

    if length(timestamps) > 0 do
      data =
        timestamps
        |> Enum.map(fn (timestamp) ->
          Enum.reduce(aggregate_data, %{timestamp: timestamp}, fn {aggregation_type, values}, result ->
            Map.put(result, String.to_atom(inspect(aggregation_type)), values[timestamp])
          end)
        end)
        |> IO.inspect(label: :brap)

      dataset = Contex.Dataset.new(data)

      # dataset = Contex.Dataset.new(data, ["x", "y"])
      pp = Contex.LinePlot.new(dataset, mapping: %{
        x_col: :timestamp,
        y_cols: Map.keys(aggregate_data) |> Enum.map(fn (key) -> String.to_atom(inspect(key)) end),
      })

      Contex.Plot.new(600, 400, pp)
      |> Contex.Plot.plot_options(%{
        legend_setting: :legend_right,
        mapping: %{ bar: "Bar", baz: "Baz" },
      })
      # |> Contex.Plot.titles("My first plot", "With a fancy subtitle")
      |> Contex.Plot.to_svg()
    else
      {:safe, ""}
    end
  end

end

