# From Nocedal & Wright, p. 288-289

# Jacobian is singular at the starting point.
# Used to test the behavior of algorithms in that context.

function f!(x, fvec)
    fvec[1] = x[1]
    fvec[2] = 10*x[1]/(x[1]+convert(eltype(x), 0.1))+2*x[2]^2
end

function g!(x, fjac)
    fjac[1, 1] = 1
    fjac[1, 2] = 0
    fjac[2, 1] = 1/(x[1]+convert(eltype(x), 0.1))^2
    fjac[2, 2] = 4*x[2]
end

df = DifferentiableMultivariateFunction(f!, g!)

# Test disabled, not stable across runs
#r = nlsolve(df, [ 3.0; 0], method = :newton, ftol = 1e-5)
#@assert converged(r)
#@assert norm(r.zero) < 1e-5

r = nlsolve(df, [ 3.0; 0], method = :trust_region)
@assert converged(r)
@assert norm(r.zero) < 1e-6

r = nlsolve(df, [3.0f0; 0], method = :trust_region)
@assert converged(r)
@assert norm(r.zero) < 1e-6

let a = rand(10)
    const A = a*a'
    global f!, g!
    function f!(x, fvec)
        copy!(fvec, A*x)
    end

    function g!(x, fjac)
        copy!(fjac, A)
    end
end

df = DifferentiableMultivariateFunction(f!, g!)
r = nlsolve(df, rand(10), method = :trust_region)
