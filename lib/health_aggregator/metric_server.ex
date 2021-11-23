defmodule HealthAggregator.MetricServer do
  use GenServer

  alias HealthAggregator.MetricServer.Calculate

  # Client

  def start_link([metric_type, keep_for]) do
    GenServer.start_link(__MODULE__, keep_for, name: name(metric_type))
  end

  def add_values(metric_type, values) do
    GenServer.call(name(metric_type), {:add_values, values})
  end

  def aggregate(metric_type, period, aggregation_types) do
    GenServer.call(name(metric_type), {:aggregate, period, aggregation_types})
  end

  # Server

  # keep_for -> number of seconds to keep metric values
  def init(keep_for) do
    {:ok, %{keep_for: keep_for, values: []}}
  end

  def handle_call({:add_values, new_values}, _from, %{values: values} = state) do
    {:reply, :ok, Map.put(state, :values, values ++ new_values)}
  end

  def handle_call({:aggregate, period, aggregation_types}, _from, %{values: values} = state) do
    {:reply, Calculate.aggregate(values, period, aggregation_types), state}
  end

  # Helpers

  defp name(metric_type) do
    :"#{metric_type}_metric_server"
  end
end

