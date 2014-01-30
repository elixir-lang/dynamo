defmodule Dynamo.HTTP.Mime do
  @doc """
  Conveniences for working with MIME types.
  To use them, just import this module.
  """

  @doc """
  Return MIME type for given filename.
  """
  #def from_file(filename) do
  #  {t, s, _} = :cowlib.web(filename)
  #  t <> "/" <> s
  #end

  def from_file(path) when is_atom(path) do
    from_file(to_string(path))
  end

  def from_file(path) do
    case :filename.extension(path) do
      << >> -> "text/html"
      << ?., ext :: binary >> -> web_ext(ext)
    end
  end

  defp web_ext("css"), do: "text/css"
  defp web_ext("gif"), do: "image/gif"
  defp web_ext("html"), do: "text/html"
  defp web_ext("htm"), do: "text/html"
  defp web_ext("ico"), do: "image/x-icon"
  defp web_ext("jpeg"), do: "image/jpeg"
  defp web_ext("jpg"), do: "image/jpeg"
  defp web_ext("js"), do: "application/javascript"
  defp web_ext("json"), do: "application/json"
  defp web_ext("mp3"), do: "audio/mpeg"
  defp web_ext("mp4"), do: "video/mp4"
  defp web_ext("ogg"), do: "audio/ogg"
  defp web_ext("ogv"), do: "video/ogg"
  defp web_ext("png"), do: "image/png"
  defp web_ext("svg"), do: "image/svg+xml"
  defp web_ext("txt"), do: "text/plain"
  defp web_ext("wav"), do: "audio/x-wav"
  defp web_ext("webm"), do: "video/webm"
  defp web_ext("xml"), do: "text/xml"
  defp web_ext(_), do: "application/octet-stream"

end
