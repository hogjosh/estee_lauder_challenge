defmodule Challenge.Repo do
  use Ecto.Repo,
    otp_app: :challenge,
    adapter: Ecto.Adapters.Postgres
end
