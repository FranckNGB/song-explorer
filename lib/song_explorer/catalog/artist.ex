defmodule SongExplorer.Catalog.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artists" do
    field :name, :string
    field :deezer_id, :integer

    has_many :albums, SongExplorer.Catalog.Album

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name, :deezer_id])
    |> validate_required([:name, :deezer_id])
    |> unique_constraint(:deezer_id)
  end
end
