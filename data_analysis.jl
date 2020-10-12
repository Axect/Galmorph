### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 507df8a6-066f-11eb-2e42-0392afc38cba
using CSV, DataFrames, FITSIO, Plots, AstroImages

# ╔═╡ 21061fde-066f-11eb-36b4-fda69d212653
md"""
# Data Analysis with ALFALFA & NSA
"""

# ╔═╡ 48b66fd4-066f-11eb-0f93-033890cb5428
md"""
## Import Data
"""

# ╔═╡ 9d88f28e-066f-11eb-3850-036031837db5
df = CSV.read("data/a100.code12.table2.190808.csv")

# ╔═╡ b8492062-066f-11eb-16d2-17fb9f1d6cd3
f = FITS("data/nsa_v1_0_1.fits")

# ╔═╡ c5c17276-066f-11eb-10f8-593f36567188
f[2]

# ╔═╡ dbae3696-066f-11eb-2634-4f7160196495
md"""
## FITS to DataFrame
"""

# ╔═╡ f5c20a1c-0c34-11eb-3eb7-857e14d09bae
minimum(Set(read(f[2], "IALFALFA")))

# ╔═╡ e565f690-066f-11eb-3d59-95fea8939246
begin
	dg = DataFrame();
	dg[:IAUNAME] = read(f[2], "IAUNAME");
	dg[:RA] = read(f[2], "RA");
	dg[:DEC] = read(f[2], "DEC");
	dg[:RUN] = read(f[2], "RUN");
	dg[:CAMCOL] = map(x -> convert(Int, x), read(f[2], "CAMCOL"));
	dg[:FIELD] = read(f[2], "FIELD");
	dg[:ZDIST] = read(f[2], "ZDIST");
	dg[:MAG] = read(f[2], "MAG");
	dg[:SERSIC_N] = read(f[2], "SERSIC_N");
	dg[:SERSIC_BA] = read(f[2], "SERSIC_BA");
	dg[:SERSIC_TH50] = read(f[2], "SERSIC_TH50");
	dg[:SERSIC_PHI] = read(f[2], "SERSIC_PHI");
	dg[:IALFALFA] = read(f[2], "IALFALFA");
	print()
end

# ╔═╡ 2c3dcb94-0670-11eb-194a-f1f8cc824f40
dg

# ╔═╡ 7e090852-0671-11eb-134a-1f94e5ebae6d
md"""
## Data Filtering (ALFALFA)
"""

# ╔═╡ c926ebe2-0671-11eb-1700-2b0f8f043ced
md"""
### Filter by `HIcode` (greater than 1)
"""

# ╔═╡ 85c03e76-0671-11eb-1f29-5f0e9f824a7b
filtered_df = filter(row -> row[:HIcode] > 1, df)

# ╔═╡ ecc2f83a-06bb-11eb-3d62-c5720f67c539
md"""
### Filter by $D < 250 \text{ Mpc}$
"""

# ╔═╡ fd7f6b7c-06bb-11eb-0fab-8fa28c878a63
filtered_df2 = filter(row -> row[:Dist] <= 250, filtered_df)

# ╔═╡ 7cb9dcf2-06bb-11eb-0b43-832a0e17bffc
md"""
## Data Filtering (NSA)
"""

# ╔═╡ 397f53ca-0c35-11eb-1642-21a72fc401d6
md"""
### Filter by IALFALFA (matching)
"""

# ╔═╡ 44af0b6e-0c35-11eb-1f9e-c35fa465997e
filtered_dg = filter(row -> row[:IALFALFA] != -1, dg)

# ╔═╡ 5a6ae3b8-06ba-11eb-3ad0-5169ec489574
md"""
### Filter by $b/a = 0.15$
"""

# ╔═╡ 76e3e08a-06ba-11eb-1b55-5321dbf50c0a
filtered_dg1 = filter(row -> row[:SERSIC_BA] == Float32(0.15), filtered_dg)

# ╔═╡ 1ad909fe-06bb-11eb-3c83-9d47d88f1ccd
md"""
### Filter by $M_r < -17.7$
"""

# ╔═╡ 468b02e6-06bb-11eb-0c90-e377dd75808b
filtered_dg2 = filter(row -> row[:MAG] > Float32(17.7), filtered_dg1) 

# ╔═╡ 0689ac1c-0c36-11eb-3e1d-e7e57f872d6a
iau_name_list = filtered_dg2[:IAUNAME]

# ╔═╡ 16375e3e-0c36-11eb-15a0-7b9279bda3b9
begin
	open("link.txt", "w") do io
		for name in iau_name_list
			println(io, name)
		end
	end
end

# ╔═╡ 10c5e1b8-0c37-11eb-026c-115f87e1e05a
read("link.txt", String)

# ╔═╡ 3411644e-0c37-11eb-35b5-a94fac72c46f
println("Hi")

# ╔═╡ d7e9ce1e-0a1c-11eb-2a4a-a1fdeca44aa2
img_fits = FITS("images/J114622.90+134937.0-r.fits")

# ╔═╡ f88d9010-0a1c-11eb-2ab7-cb2775389432
data = read(img_fits[2]);

# ╔═╡ 2168c1be-0a1d-11eb-29cf-adb1865eaf16
heatmap(data)

# ╔═╡ Cell order:
# ╟─21061fde-066f-11eb-36b4-fda69d212653
# ╟─48b66fd4-066f-11eb-0f93-033890cb5428
# ╠═507df8a6-066f-11eb-2e42-0392afc38cba
# ╟─9d88f28e-066f-11eb-3850-036031837db5
# ╠═b8492062-066f-11eb-16d2-17fb9f1d6cd3
# ╠═c5c17276-066f-11eb-10f8-593f36567188
# ╟─dbae3696-066f-11eb-2634-4f7160196495
# ╠═f5c20a1c-0c34-11eb-3eb7-857e14d09bae
# ╠═e565f690-066f-11eb-3d59-95fea8939246
# ╠═2c3dcb94-0670-11eb-194a-f1f8cc824f40
# ╟─7e090852-0671-11eb-134a-1f94e5ebae6d
# ╟─c926ebe2-0671-11eb-1700-2b0f8f043ced
# ╠═85c03e76-0671-11eb-1f29-5f0e9f824a7b
# ╠═ecc2f83a-06bb-11eb-3d62-c5720f67c539
# ╠═fd7f6b7c-06bb-11eb-0fab-8fa28c878a63
# ╟─7cb9dcf2-06bb-11eb-0b43-832a0e17bffc
# ╠═397f53ca-0c35-11eb-1642-21a72fc401d6
# ╠═44af0b6e-0c35-11eb-1f9e-c35fa465997e
# ╟─5a6ae3b8-06ba-11eb-3ad0-5169ec489574
# ╠═76e3e08a-06ba-11eb-1b55-5321dbf50c0a
# ╟─1ad909fe-06bb-11eb-3c83-9d47d88f1ccd
# ╠═468b02e6-06bb-11eb-0c90-e377dd75808b
# ╠═0689ac1c-0c36-11eb-3e1d-e7e57f872d6a
# ╠═16375e3e-0c36-11eb-15a0-7b9279bda3b9
# ╠═10c5e1b8-0c37-11eb-026c-115f87e1e05a
# ╠═3411644e-0c37-11eb-35b5-a94fac72c46f
# ╠═d7e9ce1e-0a1c-11eb-2a4a-a1fdeca44aa2
# ╠═f88d9010-0a1c-11eb-2ab7-cb2775389432
# ╠═2168c1be-0a1d-11eb-29cf-adb1865eaf16
