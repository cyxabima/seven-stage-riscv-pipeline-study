#!/usr/bin/env bash
# Export the report's TikZ diagrams as high-resolution PNGs for the README.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$ROOT/assets"

export_fig() {
  local name="$1" src="$2"
  cat > "$TMP/$name.tex" <<EOF
\documentclass[tikz,border=10pt]{standalone}
\usepackage{tikz}
\usetikzlibrary{arrows.meta,matrix,positioning,calc,fit,backgrounds}
\usepackage{amsmath,amssymb,xcolor,graphicx}
\definecolor{accent}{HTML}{1E3A8A}
\definecolor{muted}{HTML}{475569}
\begin{document}
\input{$ROOT/diagrams/$src}
\end{document}
EOF
  (cd "$TMP" && pdflatex -interaction=nonstopmode -halt-on-error "$name.tex" >/dev/null)
  pdftocairo -png -r 300 -singlefile "$TMP/$name.pdf" "$ROOT/assets/$name"
  echo "  assets/$name.png"
}

echo "Exporting figures:"
export_fig cpu-pipeline       cpu_pipeline.tikz
export_fig forwarding-interface forwarding_interface.tikz
export_fig hdu-interface      hdu-interface.tikz
export_fig load-use-hazard    q4-load-use.tikz
export_fig fetch-buffer       fetch-buffer.tikz
