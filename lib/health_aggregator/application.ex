defmodule HealthAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HealthAggregator.Repo,
      # Start the Telemetry supervisor
      HealthAggregatorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HealthAggregator.PubSub},
      # Start the Endpoint (http/https)
      HealthAggregatorWeb.Endpoint,
      # Start a worker by calling: HealthAggregator.Worker.start_link(arg)
      # {HealthAggregator.Worker, arg}

      %{
        start: {HealthAggregator.MetricServer, :start_link, [[:heart_rate, 24 * 60 * 60]]},
        id: :heart_rate_metric_server
      },
      # %{
      #   start: {HealthAggregator.Publisher, :start_link, [:heart_rate]},
      #   id: :publisher
      # }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HealthAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HealthAggregatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
