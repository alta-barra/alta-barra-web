defmodule AltabarraWeb.Router do
  use AltabarraWeb, :router

  import AltabarraWeb.UserAuth
  alias Altabarra.Accounts.User
  alias Altabarra.Analytics

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AltabarraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :track_page_view_analytics
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Corsica, origins: "*"
    plug :track_api_access_analytics
  end

  pipeline :admin do
    plug :ensure_admin
  end

  scope "/", AltabarraWeb do
    pipe_through [:browser, :require_authenticated_user, :admin]

    resources "/articles", ArticleController
    resources "/fact_checks", FactCheckController
    resources "/tags", TagController
    resources "/article_categories", ArticleCategoryController
    resources "/categories", CategoryController
    resources "/article_tags", ArticleTagController
  end

  scope "/", AltabarraWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/status", HealthcheckController, :status
    get "/contact", PageController, :contact
    get "/services", PageController, :services
    get "/apis", PageController, :apis

    resources "/blog", BlogController, only: [:index, :show]

    get "/sitemap.xml", SitemapController, :index
  end

  scope "/api/stac", AltabarraWeb do
    pipe_through :api

    get "/", StacController, :root_catalog
    get "/:provider", StacController, :get_catalog
    get "/:provider/collections", StacController, :list_collections
    get "/:provider/collections/:collection_id", StacController, :get_collection
    get "/:provider/collections/:collection_id/items", StacController, :list_items
    get "/:provider/collections/:collection_id/items/:item_id", StacController, :get_item
  end

  # Authentication routes
  scope "/", AltabarraWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AltabarraWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AltabarraWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AltabarraWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", AltabarraWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AltabarraWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", AltabarraWeb do
    pipe_through [:browser, :require_authenticated_user, :admin]

    live_session :analytics,
      on_mount: [{AltabarraWeb.UserAuth, :ensure_authenticated}] do
      live "/analytics", AnalyticsDashboardLive, :index
    end
  end

  if Application.compile_env(:altabarra, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AltabarraWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  @ignored_paths ["/status", "/admin"]
  defp track_page_view_analytics(conn, _opts) do
    unless Enum.any?(@ignored_paths, &String.starts_with?(conn.request_path, &1)) do
      Task.start(fn -> Analytics.track_page_view(conn) end)
    end

    conn
  end

  defp track_api_access_analytics(conn, _opts) do
    Task.start(fn -> Analytics.track_api_access(conn) end)

    conn
  end

  defp ensure_admin(conn, _) do
    case conn.assigns[:current_user] do
      %User{role: "admin"} ->
        conn

      _ ->
        conn
        |> put_flash(:error, "You must be an administrator to access this page.")
        |> redirect(to: "/")
        |> halt()
    end
  end
end
