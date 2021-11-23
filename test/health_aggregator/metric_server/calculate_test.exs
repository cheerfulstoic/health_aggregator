defmodule HealthAggregator.MetricServer.CalculateTest do
  use ExUnit.Case, async: true

  alias HealthAggregator.MetricServer.Calculate

  describe ".aggregate" do
    test "No data" do 
      result = Calculate.aggregate([], :hour, [:median])

      assert result == %{median: %{}}
    end

    test "One value" do
      values = [
        {~U[2022-01-01 02:55:18Z], 99},
      ]

      assert Calculate.aggregate(values, :hour, [:min, {:percentile, 50}, {:percentile, 90}, :max]) == %{
        :min => %{
          ~U[2022-01-01 02:00:00Z] => 99
        },
        {:percentile, 50} => %{
          ~U[2022-01-01 02:00:00Z] => 99
        },
        {:percentile, 90} => %{
          ~U[2022-01-01 02:00:00Z] => 99
        },
        :max => %{
          ~U[2022-01-01 02:00:00Z] => 99
        },
      }
    end

    test "Many values, one period slot" do
      values = [
        {~U[2022-01-01 02:15:18Z], 56},
        {~U[2022-01-01 02:25:18Z], 51},
        {~U[2022-01-01 02:35:18Z], 74},
        {~U[2022-01-01 02:45:18Z], 61},
      ]

      assert Calculate.aggregate(values, :hour, [:min, {:percentile, 50}, {:percentile, 90}, :max]) == %{
        :min => %{
          ~U[2022-01-01 02:00:00Z] => 51
        },
        {:percentile, 50} => %{
          ~U[2022-01-01 02:00:00Z] => 58.5
        },
        {:percentile, 90} => %{
          ~U[2022-01-01 02:00:00Z] => 70.1
        },
        :max => %{
          ~U[2022-01-01 02:00:00Z] => 74
        },
      }
    end

  end
end

