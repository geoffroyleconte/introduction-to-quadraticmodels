# In this tutorial you will learn how to create and use QuadraticModels.

# \toc

## Create a QuadraticModel

#=
QuadraticModels represent the optimization problem

$$
\begin{aligned}
\min \quad & \tfrac{1}{2}x^T H x + c^T x + c0 \\
& lcon  \leq Ax \leq ucon \\
& \ell \leq  x \leq u.
\end{aligned}
$$

`H` should be a lower triangular matrix.
QuadraticModels can work with different input matrix types:
=#

H = [
  6.0 2.0 1.0
  2.0 5.0 2.0
  1.0 2.0 4.0
]
c = [-8.0; -3; -3]
A = [
  1.0 0.0 1.0
  0.0 2.0 1.0
]
lcon = [-2.0; 0.]
ucon = [10.0; 20.0]
l = [0.0; 0; 0]
u = [Inf; Inf; Inf]
using LinearAlgebra, SparseArrays, QuadraticModels, SparseMatricesCOO, LinearOperators
HCOO = SparseMatrixCOO(tril(H))
ACOO = SparseMatrixCOO(A)
HCSC = sparse(tril(H))
ACSC = sparse(A)
qmCSC = QuadraticModel(c, HCSC, A = ACSC, lcon = lcon, ucon = ucon, lvar = l, uvar = u, 
                       c0 = 0.0, name = "QM_CSC")

#

qmCOO = QuadraticModel(c, HCOO, A = ACOO, lcon = lcon, ucon = ucon, lvar = l, uvar = u, 
                       c0 = 0.0, name = "QM_COO")

#

qmDense = QuadraticModel(c, tril(H), A = A, lcon = lcon, ucon = ucon, lvar = l, uvar = u,
                         c0 = 0.0, name = "QM_Dense")

#

qmLinop = QuadraticModel(c, LinearOperator(Symmetric(H)), A = LinearOperator(A),
                         lcon = lcon, ucon = ucon, lvar = l, uvar = u,
                         c0 = 0.0, name = "QM_Linop")

# You can also create a COO QuadraticModel directly from the coordinates (without using [`SparseMatricesCOO.jl`](https://github.com/JuliaSmoothOptimizers/SparseMatricesCOO.jl)):

Hrows, Hcols, Hvals = findnz(sparse(tril(H)))
Arows, Acols, Avals = findnz(sparse(A))
qmCOO2 = QuadraticModel(c, Hrows, Hcols, Hvals, Arows = Arows, Acols = Acols, Avals = Avals, 
                        lcon = lcon, ucon = ucon, lvar = l, uvar = u,
                        c0 = 0.0, name = "QM_COO2")

#=
## Convert your model

Some functions work best with SparseMatricesCOO.
You can convert your QuadraticModel with
=#

T = Float64
S = Vector{T}
qmCOO3 = convert(QuadraticModel{T, S, SparseMatrixCOO{T, Int}, SparseMatrixCOO{T, Int}},
                 qmDense)

qmCOO4 = convert(QuadraticModel{T, S, SparseMatrixCOO{T, Int}, SparseMatrixCOO{T, Int}},
                 qmCSC)

#=
## Use the NLPModels.jl API

You can use the API from [`NLPModels.jl`](https://juliasmoothoptimizers.github.io/NLPModels.jl/stable/api/#Reference-guide) with QuadraticModels.
Here are some examples:
=#

using NLPModels
x = rand(3)
grad(qmCOO, x)

#

hess(qmCOO, x)

# It is possible to convert the model to a QuadraticModel with linear inequality constraints to equality constraints and bounds using [`SlackModel`](https://juliasmoothoptimizers.github.io/NLPModelsModifiers.jl/stable/reference/#NLPModelsModifiers.SlackModel)

using NLPModelsModifiers
qmSlack = SlackModel(qmCOO)

#=
## Read MPS/SIF files

You can read directly MPS or SIF files using [`QPSReader.jl`](https://github.com/JuliaSmoothOptimizers/QPSReader.jl)
=#

using QPSReader
qps = readqps("AFIRO.SIF")
qmCOO4 = QuadraticModel(qps)

#=
## Solving

You can use [`RipQP.jl`](https://github.com/JuliaSmoothOptimizers/RipQP.jl) to solve QuadraticModels:
=#

using RipQP
stats = ripqp(qmCOO)
println(stats)

#