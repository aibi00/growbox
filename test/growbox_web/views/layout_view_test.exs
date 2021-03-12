defmodule GrowboxWeb.LayoutViewTest do
  use GrowboxWeb.ConnCase, async: true

  # When testing helpers, you may want to import Phoenix.HTML and
  # use functions such as safe_to_string() to convert the helper
  # result into an HTML string.
  # import Phoenix.HTML

  import Phoenix.HTML
  import GrowboxWeb.LayoutView

  describe "render_link/2" do
    test "renders a link with the given icon" do
      html =
        safe_to_string(
          render_link "Home", to: "/" do
            Phoenix.HTML.Tag.tag(:img)
          end
        )

      assert html =~ "Home"
      assert html =~ "<img>"
      assert html =~ "text-gray-900"
    end

    test "marks a link as active when both given_path and to arguments are equal" do
      html =
        safe_to_string(
          render_link "Home", to: "/", current_path: "/" do
            Phoenix.HTML.Tag.tag(:img)
          end
        )

      assert html =~ "text-lime-600"
    end

    test "forwards all other arguments to the link/2 function" do
      html =
        safe_to_string(
          render_link "Home", to: "/", target: "_blank", role: :link do
            Phoenix.HTML.Tag.tag(:img)
          end
        )

      assert html =~ ~s[target="_blank"]
      assert html =~ ~s[role="link"]
    end
  end
end
