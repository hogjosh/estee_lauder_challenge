defmodule Challenge.Repo do
  use Ecto.Repo,
    otp_app: :challenge,
    adapter: Ecto.Adapters.Postgres

  # This enables paging on most queries
  # Unless specified, the page size will be 20.
  use Scrivener, page_size: 20
end
