Mix.start
Mix.env(:dev)
Mix.shell(Mix.Shell.Process)
System.put_env("MIX_ENV", "dev")

Dynamo.start(:dev)
Dynamo.View.Renderer.start_link

ExUnit.start

defmodule MixHelpers do
  import ExUnit.Assertions

  def tmp_path do
    File.expand_path("../../tmp", __FILE__)
  end

  def tmp_path(extension) do
    File.join tmp_path, extension
  end

  def in_tmp(which, function) do
    path = tmp_path(which)
    File.rm_rf! path
    File.mkdir_p! path
    File.cd! path, function
  end

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  def assert_file(file, match) when is_regex(match) do
    assert_file file, &1 =~ match
  end

  def assert_file(file, callback) when is_function(callback, 1) do
    assert_file(file)
    callback.(File.read!(file))
  end
end