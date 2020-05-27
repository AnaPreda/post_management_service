defmodule PostManagementService.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do

    create table(:posts, primary_key: false) do
      add :post_id, :serial, primary_key: true
      add :title, :string, null: false
      add :content, :string, null: false
      add :author, :string

      timestamps()
    end
  end
end
