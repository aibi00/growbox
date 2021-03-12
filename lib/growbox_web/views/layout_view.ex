defmodule GrowboxWeb.LayoutView do
  use GrowboxWeb, :view

  @doc """
  Render a link suitable for the main menu.
  """
  def render_link(text, opts \\ [], do: icon) do
    {to, opts} = Keyword.pop!(opts, :to)
    {current_path, opts} = Keyword.pop(opts, :current_path)

    render("_link.html",
      text: text,
      to: to,
      current?: to == current_path,
      icon: icon,
      opts: opts
    )
  end
end
