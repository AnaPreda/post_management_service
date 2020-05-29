defmodule PostManagementService.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias PostManagementService.{Post, Repo}
  @primary_key {:post_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :post_id}
  schema "posts" do
    field :title, :string
    field :content, :string
    field :author, :string

    timestamps()
  end

  @fields ~w(title content author)a

  def changeset(data, params \\ %{}) do
    data
    |> cast(params, @fields)
    |> validate_required([:title, :content, :author])
  end

  def create(params) do
    cs = changeset(%Post{}, params)
    Repo.insert(cs)
  end
  
  def update(data, params) do
    post = changeset(data, params)
    Repo.update(post)
  end
end
