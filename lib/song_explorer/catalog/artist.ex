defmodule SongExplorer.Catalog.Artist do
  @moduledoc """
  Schéma Ecto représentant un artiste musical.

  ## Champs
    - `name` : nom de l'artiste
    - `deezer_id` : identifiant unique de l'artiste sur Deezer (contrainte d'unicité)

  ## Relations
    - `has_many :albums` : liste des albums associés à l'artiste
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          deezer_id: integer() | nil,
          albums: [SongExplorer.Catalog.Album.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

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
