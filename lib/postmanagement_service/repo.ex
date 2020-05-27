defmodule PostManagementService.Repo do
  use Ecto.Repo,
    otp_app: :post_management_service,
    adapter: Ecto.Adapters.Postgres
end
