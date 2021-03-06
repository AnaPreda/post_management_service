defmodule PostManagementService.Router do
  use Plug.Router
  import Ecto.Query

  require Logger
  plug(Plug.Logger, log: :debug)
  alias PostManagementService.Repo, as: Repo
  alias PostManagementService.Post, as: Post
  alias PostManagementService.PostsUtils, as: Utils
  plug(:match)

  plug CORSPlug, origin: "*", credentials: true, methods: ["POST", "PUT", "DELETE", "GET", "PATCH", "OPTIONS"], headers: [ "Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken", "Keep-Alive", "X-Requested-With", "If-Modified-Since", "X-CSRF-Token"], expose: ['Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id']

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get "/get_posts" do

    token = List.last(String.split(List.first(get_req_header(conn, "authorization"))))

    case Utils.is_valid_token(token) do
      true ->
        posts = Repo.all(from(Post))
        conn
        |>put_resp_content_type("application/json")
        |>send_resp(200,Poison.encode!(%{:posts=>posts}))
      false ->
        conn
        |>put_resp_content_type("application/json")
        |>send_resp(401,Poison.encode!(%{:error=>"Unauthorized"}))
    end
  end


  get"/get_posts_by_author" do
    author = Map.get(conn.params, "author", nil)
    token = List.last(String.split(List.first(get_req_header(conn, "authorization"))))

    case Utils.is_valid_token(token) do
      true ->
        posts =  Repo.all(from post in Post, where: post.author == ^author)
        case is_nil(posts) do
          true ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(404, Poison.encode!(%{"error" => "Posts not found for this author"}))
          false ->
            conn
            |>put_resp_content_type("application/json")
            |>send_resp(200,Poison.encode!(%{:posts=>posts}))
        end
      false ->
        conn
        |>put_resp_content_type("application/json")
        |>send_resp(401,Poison.encode!(%{:error=>"Unauthorized"}))
    end

  end

  get"/get_post_by_id" do
    id = Map.get(conn.params, "id", nil)
    token = List.last(String.split(List.first(get_req_header(conn, "authorization"))))

    case Utils.is_valid_token(token) do
      true ->
        post =  Repo.get(Post, id)
        case is_nil(post) do
          true ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(404, Poison.encode!(%{"error" => "Post not found with this id"}))
          false ->
            conn
            |>put_resp_content_type("application/json")
            |>send_resp(200,Poison.encode!(%{:post=>post}))
        end
      false ->
        conn
        |>put_resp_content_type("application/json")
        |>send_resp(401,Poison.encode!(%{:error=>"Unauthorized"}))
    end

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
        token = List.last(String.split(List.first(get_req_header(conn, "authorization"))))

        case Utils.is_valid_token(token) do
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
          false ->
            conn
            |>put_resp_content_type("application/json")
            |>send_resp(401,Poison.encode!(%{:error=>"Unauthorized"}))
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
        token = List.last(String.split(List.first(get_req_header(conn, "authorization"))))

        case Utils.is_valid_token(token) do
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
          false ->
            conn
            |>put_resp_content_type("application/json")
            |>send_resp(401,Poison.encode!(%{:error=>"Unauthorized"}))
        end
    end
  end

  delete "/delete_post" do
    id =  Map.get(conn.params, "id", nil)
    token = List.last(String.split(List.first(get_req_header(conn, "authorization"))))

    case Utils.is_valid_token(token) do
      true ->
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
      false ->
        conn
        |>put_resp_content_type("application/json")
        |>send_resp(401,Poison.encode!(%{:error=>"Unauthorized"}))
    end
  end

  delete "/admin/delete_all" do
    #    Repo.all(from post in Post, where: post.author == ^author)
    Repo.delete_all(Post)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{:message => "deleted"}))
  end
end