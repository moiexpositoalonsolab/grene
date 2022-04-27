devtools::load_all(".")
# We want to have about 4-5 thousand seeds as parents of the second generation
# to generate more seeds.
# We will use 0.1 g of seeds, which depending on the g/seed ratio, it would be
# from 4000 to 7000 approximately.

0.1 / coefficients(modcol)
0.1 / coefficients(modbur)
0.1 / coefficients(mod9965)

# I am going to use 50 trays with 40 pots each.
50*40
# So I can pipet from a falcon tube of 5 mL with a suspension of seeds, 2000 times.
# In each pot I aim to put 2-3 seds, so each aliquote would be of ml:
5 / 2000
# or ul:
5 / 2000 * 1000
# Actually better 1 litter, so 0.5 mL pipete
1000 /2000

# In each alliquote there will be a number of seeds between 2 to 3:
0.1 / coefficients(modcol) / 2000
0.1 / coefficients(modbur) / 2000
0.1 / coefficients(mod9965) / 2000



