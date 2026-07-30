defmodule SongExplorer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SongExplorerWeb.Telemetry,
      SongExplorer.Repo,
      {DNSCluster, query: Application.get_env(:song_explorer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SongExplorer.PubSub},
      # Start a worker by calling: SongExplorer.Worker.start_link(arg)
      # {SongExplorer.Worker, arg},
      # Start to serve requests, typically the last entry
      SongExplorerWeb.Endpoint,
      {Task.Supervisor, name: SongExplorer.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SongExplorer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SongExplorerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
