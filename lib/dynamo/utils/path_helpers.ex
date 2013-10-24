defmodule Dynamo.Utils.PathHelpers do
  @moduledoc """
  Useful helpers for working with path. Dynamo.Loader module
  uses it for getting the correct root path for loading the rest
  of modules.
  """

  @doc """
  Returns the path up the tree of directories of the path specified by 
  the argument 'path' that contains the file mix.exs

  If given path contains the file itself - this function will return
  this same path.
  """
  def base_path_for(path) do
    base_path_for path, File.exists?(Path.join(path, "mix.exs"))
  end

  @doc false
  def base_path_for(path, has_mix) do
    try do
      if has_mix do
        path
      else
        path_up = Path.expand Path.join(path, ".."), "."
        base_path_for path_up, File.exists?(Path.join(path_up, "mix.exs"))
      end
    rescue
      FunctionClauseError ->
        raise "could not find the root directory for the project." <>
              "Make sure that you're in a directory which has a mix.exs file" <>
              "in one of its parents"
    end
  end
end