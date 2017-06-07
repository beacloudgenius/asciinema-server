defmodule Asciinema.Asciicast do
  use Asciinema.Web, :model
  alias Asciinema.{User, Asciicast}
  alias Asciinema.PngGenerator.PngParams

  @default_png_scale 2
  @default_theme "asciinema"

  schema "asciicasts" do
    field :version, :integer
    field :file, :string
    field :terminal_columns, :integer
    field :terminal_lines, :integer
    field :stdout_data, :string
    field :stdout_timing, :string
    field :stdout_frames, :string
    field :private, :boolean
    field :secret_token, :string
    field :duration, :float
    field :title, :string
    field :theme_name, :string
    field :snapshot_at, :float

    timestamps(inserted_at: :created_at)

    belongs_to :user, User
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:title])
  end

  def create_changeset(struct, attrs) do
    struct
    |> changeset(attrs)
    |> cast(attrs, [:user_id, :version, :file, :duration, :terminal_columns, :terminal_lines])
    |> generate_secret_token
    |> validate_required([:user_id, :version, :duration, :terminal_columns, :terminal_lines, :secret_token])
  end

  defp generate_secret_token(changeset) do
    put_change(changeset, :secret_token, random_token(25))
  end

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> String.replace(~r/[_=-]/, "")
    |> binary_part(0, length)
  end

  def by_id_or_secret_token(thing) do
    if String.length(thing) == 25 do
      from a in __MODULE__, where: a.secret_token == ^thing
    else
      case Integer.parse(thing) do
        {id, ""} ->
          from a in __MODULE__, where: a.private == false and a.id == ^id
        :error ->
          from a in __MODULE__, where: a.id == -1 # TODO fixme
      end
    end
  end

  def json_store_path(%__MODULE__{id: id, file: file}) when is_binary(file) do
    "asciicast/file/#{id}/#{file}"
  end
  def json_store_path(%__MODULE__{id: id, stdout_frames: stdout_frames}) when is_binary(stdout_frames) do
    "asciicast/stdout_frames/#{id}/#{stdout_frames}"
  end

  def snapshot_at(%Asciicast{snapshot_at: snapshot_at, duration: duration}) do
    snapshot_at || duration / 2
  end

  def theme_name(%Asciicast{theme_name: a_theme_name}, %User{theme_name: u_theme_name}) do
    a_theme_name || u_theme_name || @default_theme
  end

  def png_params(%Asciicast{} = asciicast, %User{} = user) do
    %PngParams{snapshot_at: snapshot_at(asciicast),
               theme: theme_name(asciicast, user),
               scale: @default_png_scale}
  end
end