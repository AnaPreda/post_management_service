defmodule PostManagementService.Endpoint do
  import Ecto.Query
  require Logger
  use Plug.Router

  alias PostManagementService.Repo, as: Repo
  alias PostManagementService.Post, as: Post
  plug(:match)

  plug CORSPlug, origin: "*", credentials: true, methods: ["POST", "PUT", "DELETE", "GET", "PATCH", "OPTIONS"], headers: [ "Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken", "Keep-Alive", "X-Requested-With", "If-Modified-Since", "X-CSRF-Token"], expose: ['Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id']

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)
  
 get "/get_posts" do
 posts = Repo.all(from(Post))

 conn
 |>put_resp_content_type("application/json")
 |>send_resp(200,Poison.encode!(%{:posts=>posts}))
 end

 post "/create_post" do
    {title, content, author} = {
      Map.get(conn.params, "title", nil),
      Map.get(conn.params, "content", nil),
      Map.get(conn.params, "author", nil)
    }
    cond do
      is_nil(title) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'title' field must be provided"})
      is_nil(content) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'content' field must be provided"})
      is_nil(author) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'author' field must be provided"})
      true ->
        case Post.create(%{"title" => title, "content" => content, "author" => author}) do
          {:ok, new_post}->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:data => new_post}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Poison.encode!(%{"error" => "An unexpected error happened"}))
        end
    end
  end

 put "/update_post" do
    {id, title, content, author} = {
      Map.get(conn.params, "id", nil),
      Map.get(conn.params, "title", nil),
      Map.get(conn.params, "content", nil),
      Map.get(conn.params, "author", nil)
    }
    cond do
      is_nil(id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'id' field must be provided"})
      is_nil(title) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'title' field must be provided"})
      is_nil(content) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'content' field must be provided"})
      is_nil(author) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'author' field must be provided"})
      true ->
        post = Repo.get(Post, id)
        case is_nil(post) do
          true ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(404, Poison.encode!(%{"error" => "Post not found"}))
          false ->
          case Post.update(post, %{"post_id"=> id, "title" => title, "content" => content, "author" => author}) do
            {:ok, updated_post}->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(200, Poison.encode!(%{:data => updated_post}))
            :error ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, Poison.encode!(%{"error" => "An unexpected error happened"}))
          end
        end
    end
  end

 delete "/delete_post" do
    id =  Map.get(conn.params, "id", nil)

    post = Repo.get(Post, id)
    case is_nil(post) do
    true ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Poison.encode!(%{"error" => "Post not found"}))
    false ->
      case Repo.delete post do
        {:ok, struct} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(%{:data => struct}))
        {:error, changeset} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(500, Poison.encode!(%{"error" => "An unexpected error happened"}))
      end
    end
  end
  
  match _ do
    send_resp(conn, 404, "Page not found!")
  end

end
