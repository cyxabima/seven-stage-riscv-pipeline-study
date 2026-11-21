.PHONY: all pdf figures test clean

all: pdf

pdf: main.pdf

main.pdf: main.tex $(wildcard diagrams/*.tikz) design.sv testbench.sv test-result.png
	latexmk -pdf -interaction=nonstopmode main.tex

figures:
	./scripts/export-figures.sh

test:
	@mkdir -p build
	@command -v iverilog >/dev/null || { echo "iverilog is required for 'make test'"; exit 1; }
	iverilog -g2012 -o build/alu_tb design.sv testbench.sv
	vvp build/alu_tb

clean:
	rm -f *.aux *.bbl *.blg *.dvi *.fls *.fdb_latexmk *.log *.nav *.out *.snm *.synctex.gz *.toc *.vrb
	rm -rf build
