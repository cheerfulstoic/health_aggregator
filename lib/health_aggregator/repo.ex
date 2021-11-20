defmodule HealthAggregator.Repo do
  use Ecto.Repo,
    otp_app: :health_aggregator,
    adapter: Ecto.Adapters.Postgres
end
