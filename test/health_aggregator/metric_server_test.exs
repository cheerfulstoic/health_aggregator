defmodule HealthAggregator.MetricServerTest do
  use ExUnit.Case, async: true

  alias HealthAggregator.MetricServer

  describe ".aggregate" do
    test "No data" do 
      start_supervised!({HealthAggregator.MetricServer, [:foo, 10]}, restart: :temporary)

      result = MetricServer.aggregate(:foo, :hour, [{:percentile, 50}])

      assert result == %{
        {:percentile, 50} => %{}
      }
    end

    test "Data spanning three hour slots across two days" do 
      start_supervised!({HealthAggregator.MetricServer, [:foo, 10]}, restart: :temporary)

      MetricServer.add_values(:foo, [
        {~U[2021-11-19 13:26:08Z], 44},
        {~U[2021-11-19 13:56:08Z], 47},
        {~U[2021-11-19 14:26:08Z], 53},
        {~U[2021-11-20 14:16:00Z], 10},
        {~U[2021-11-20 14:26:00Z], 12},
        {~U[2021-11-20 14:36:00Z], 15},
      ])

      result = MetricServer.aggregate(:foo, :hour, [{:percentile, 50}])

      assert result == %{
        {:percentile, 50} => %{
          ~U[2021-11-19 13:00:00Z] => 45.5,
          ~U[2021-11-19 14:00:00Z] => 53,
          ~U[2021-11-20 14:00:00Z] => 12,
        }
      }
    end
  end
end
