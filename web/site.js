// Adds the Pagefind search box to the top of LaTeXML's navigation sidebar.
// The pagefind/ folder is generated next to the pages by `make web`.
document.addEventListener("DOMContentLoaded", () => {
  const nav = document.querySelector(".ltx_page_navbar");
  if (!nav) return;

  const box = document.createElement("div");
  box.id = "search";
  nav.prepend(box);

  const css = document.createElement("link");
  css.rel = "stylesheet";
  css.href = "pagefind/pagefind-ui.css";
  document.head.append(css);

  const js = document.createElement("script");
  js.src = "pagefind/pagefind-ui.js";
  js.onload = () => new PagefindUI({ element: "#search", showSubResults: true, showImages: false });
  document.head.append(js);
});
