defmodule Dynamo.HTTP.Test do
  @moduledoc """
  A connection to be used in tests. It implements
  the same API as the other connections implementations
  and a couple extra helpers to be used in tests.

  Check `Dynamo.HTTP` for documentation on
  the majority of the functions.
  """

  @behaviour Dynamo.HTTP

  Record.defmacros __ENV__, :connection,
    [ :method, :original_method, :path_segments, :path_info_segments, :script_name_segments,
      :query_string, :raw_req_headers, :req_headers, :req_body, :params,
      :resp_headers, :raw_cookies, :cookies, :resp_cookies, :assigns,
      :status, :resp_body, :state, :fetched ]

  use Dynamo.HTTP.Paths
  use Dynamo.HTTP.Cookies
  use Dynamo.HTTP.Request
  use Dynamo.HTTP.Response
  use Dynamo.HTTP.Assigns

  @doc """
  Initializes a connection to be used in tests.
  """
  def new() do
    connection(
      path_info_segments: [],
      script_name_segments: [],
      raw_req_headers: Binary.Dict.new([ { "Host", "127.0.0.1" } ]),
      resp_headers: Binary.Dict.new,
      resp_cookies: [],
      assigns: [],
      fetched: [],
      state: :unset
    )
  end

  ## Request API

  def version(_conn) do
    { 1, 1 }
  end

  def query_string(connection(query_string: query_string)) do
    query_string
  end

  def path_segments(connection(path_segments: path_segments)) do
    path_segments
  end

  def path(connection(path_segments: path_segments)) do
    to_path path_segments
  end

  def req_cookies(connection(raw_cookies: raw_cookies)) do
    raw_cookies
  end

  ## Response API

  def send(_status, body, connection(original_method: "HEAD")) when body != "" do
    raise Dynamo.HTTP.InvalidSendOnHeadError
  end

  def send(status, body, conn) do
    connection(conn,
      state: :sent,
      status: status,
      resp_body: body
    )
  end

  def sendfile(path, conn) do
    send(200, File.read!(path), conn)
  end

  ## Misc

  def fetch(:headers, connection(raw_req_headers: raw_req_headers, fetched: fetched) = conn) do
    connection(conn,
      fetched: [:headers|fetched],
      req_headers: raw_req_headers,
      raw_req_headers: Binary.Dict.new)
  end

  def fetch(:params, connection(query_string: query_string, fetched: fetched) = conn) do
    params = Dynamo.HTTP.QueryParser.parse(query_string)
    connection(conn, params: params, fetched: [:params|fetched])
  end

  def fetch(:cookies, connection(raw_cookies: raw_cookies, fetched: fetched) = conn) do
    connection(conn, cookies: raw_cookies, fetched: [:cookies|fetched])
  end

  def fetch(:body, connection(req_body: req_body, fetched: fetched) = conn) do
    connection(conn, req_body: req_body, fetched: [:body|fetched])
  end

  ## Test only API

  @doc """
  Resets the connection for a new request with the given
  method and on the given path.

  If the path contains a host, e.g `//example.com/foo`,
  the Host request header is set to such value, otherwise
  it defaults to `127.0.0.1`.
  """
  def req(method, path, conn) do
    uri      = URI.parse(path)
    segments = Dynamo.Router.Utils.split(uri.path)
    method   = Dynamo.Router.Utils.normalize_verb(method)

    conn = connection(conn,
      query_string: uri.query || "",
      path_segments: segments,
      path_info_segments: segments,
      script_name_segments: [],
      params: nil,
      req_headers: nil,
      req_body: nil,
      method: method,
      original_method: method)

    if uri.authority do
      conn.set_req_header "Host", uri.authority
    else
      conn
    end
  end

  @doc """
  Stores fetched aspects.
  """
  def fetched(connection(fetched: fetched)) do
    fetched
  end

  @doc """
  Sets the cookies to be read by the request.
  """
  def req_cookies(cookies, conn) do
    connection(conn, raw_cookies: Binary.Dict.new(cookies))
  end

  @doc """
  Sets the body to be read by the request.
  """
  def req_body(body, conn) do
    connection(conn, req_body: body)
  end

  @doc """
  Sets a request header, overriding any previous value.
  Both `key` and `value` are converted to binary.
  """
  def set_req_header(key, value, connection(raw_req_headers: raw_req_headers) = conn) do
    connection(conn, raw_req_headers: Dict.put(raw_req_headers, key, to_binary(value)))
  end

  @doc """
  Deletes a request header.
  """
  def delete_req_header(key, connection(raw_req_headers: raw_req_headers) = conn) do
    connection(conn, raw_req_headers: Dict.delete(raw_req_headers, key))
  end
end