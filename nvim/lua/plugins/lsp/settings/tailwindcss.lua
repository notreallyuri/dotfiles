return {
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          { [[class="([^"]*)"]] },
          { [[class=move\s*\|\|\s*\{?"?([^"}\)]*)"?\}?]] },
          { [[cn!\(([^)]*)\)]],                          [["([^"]*)"]] },
          { [[cn!\s*\(([^)]*)\)]] },
        },
      },
      includeLanguages = {
        rust = "html",
      },
    },
  },
  filetypes = {
    "html", "css", "typescript", "typescriptreact",
    "javascript", "javascriptreact", "rust"
  },
}
