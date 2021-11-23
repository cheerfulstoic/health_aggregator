defmodule HealthAggregator.MetricServer.Calculate do
  def aggregate(values, period, aggregation_types) do
    grouped_values =
      values
      |> Enum.reduce(%{}, fn {datetime, value}, result ->
        Map.update(result, datetime_rolled_up_to(datetime, period), [value], &[value|&1])
      end)

    aggregation_types
    |> Enum.reduce(%{}, fn aggregation_type, result ->
      value =
        grouped_values
        |> Map.new(fn {datetime, values} -> {datetime, calculation(values, aggregation_type)} end)

      Map.put(result, aggregation_type, value)
    end)
  end

  defp datetime_rolled_up_to(datetime, :hour) do
    datetime
    |> Map.put(:minute, 0)
    |> datetime_rolled_up_to(:minute)
  end
  defp datetime_rolled_up_to(datetime, :minute) do
    datetime
    |> Map.put(:second, 0)
  end
  defp datetime_rolled_up_to(datetime, :second) do
    datetime
  end

  defp calculation([], _), do: nil
  defp calculation(values, {:percentile, cutoff}) do
    Statistics.percentile(values, cutoff)
  end
  defp calculation(values, :min) do
    Enum.min(values)
  end
  defp calculation(values, :max) do
    Enum.max(values)
  end
end
