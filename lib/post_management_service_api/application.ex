defmodule PostManagementService.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    :ets.new(:my_posts, [:bag, :public, :named_table])

    Supervisor.start_link(children(), opts())
  end
  defp children do
    [
      {Plug.Adapters.Cowboy2, scheme: :http,
        plug: PostManagementService.Endpoint, options: [port: 4000]},
      PostManagementService.Repo,
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: PostManagementService.Supervisor
    ]
  end

end