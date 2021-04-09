# Taken from Ecto Github Repo:
# https://github.com/elixir-ecto/ecto/blob/master/lib/mix/tasks/ecto.create.ex

defmodule Mix.Tasks.Ecto.Create do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Creates the repository storage"

  @switches [
    quiet: :boolean,
    repo: [:string, :keep],
    no_compile: :boolean,
    no_deps_check: :boolean
  ]

  @aliases [
    r: :repo,
    q: :quiet
  ]

  @doc false
  def run(args) do
    repos = parse_repo(args)
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)

      ensure_implements(
        repo.__adapter__,
        Ecto.Adapter.Storage,
        "create storage for #{inspect(repo)}"
      )

      case repo.__adapter__.storage_up(repo.config) do
        :ok ->
          unless opts[:quiet] do
            Mix.shell().info("The database for #{inspect(repo)} has been created")
          end

        {:error, :already_up} ->
          unless opts[:quiet] do
            Mix.shell().info("The database for #{inspect(repo)} has already been created")
          end

        {:error, term} when is_binary(term) ->
          Mix.raise("The database for #{inspect(repo)} couldn't be created: #{term}")

        {:error, term} ->
          Mix.raise("The database for #{inspect(repo)} couldn't be created: #{inspect(term)}")
      end
    end)
  end
end
