#=
Author: Ksymena Poradzisz
Updated: [2024-07-16]
=#


using Symbolics
using QuadGK
using DoubleExponentialFormulas
using PolynomialRoots
using Polynomials
using Dates, CSV
using DataFrames

const v = -1/2 # predkosc w jedn. c
const β = 2  # Thermodynamic β=1/(kT), aka coolness
const γ = 1 / sqrt(1 - v^2) #global usage unnecessary
const infinity = 150
M = 1; m_0 = 1;

#######SCHWARZSCHILD#############
λ_max_sch(ξ, ε) = ξ * sqrt(ε^2 / (1 - 2 / ξ) - 1)
λ_c_sch(ε) = sqrt(12 / (1 - 4 / (1 + 3 * ε / sqrt(9 * ε^2 - 8))^2))
U_λ_sch(ξ, λ) = (1 - 2 / ξ) * (1 + λ^2 / ξ^2)
function R_sch(ξ, ε, λ)
    temp = ε^2 - U_λ_sch(ξ, λ)
    if temp <= 0
        return Inf
    else
        return temp
    end

end

X_sch(ξ, ε, λ) = quadde(_ξ_-> λ/(_ξ_^2*sqrt(R_sch(_ξ_, ε, λ))),ξ,Inf)[1]

function ε_min_sch(ξ)
    if ξ<= 3
        temp =  Inf
    elseif ξ >= 4
        temp = 1
    elseif ξ <4 && ξ >3
        temp = sqrt((1-2/ξ)*(1+1/(ξ-3)))
    else
        temp=  nothing
    end

    return temp
end

function J_t_ABS_sch(ξ,φ)
    coeff = -2*m_0^3/ξ
  #  coeff = 1
    integral = coeff *  quadgk( ε-> ε* quadgk(λ-> cosh(β*γ*v*sqrt(ε^2-1)*sin(φ)*sin(X_sch(ξ, ε, λ)))*
    exp(-β*γ*(ε+v*sqrt(ε^2-1)*cos(φ)*cos(X_sch(ξ,ε,λ))))/sqrt(R_sch(ξ, ε, λ)),0,λ_c_sch(ε))[1],1,infinity)[1]
    return integral
end
function J_t_SCATT_sch(ξ, φ)
    coeff = -4*m_0^3/ξ
    #coeff = 1
    integral=  coeff*quadgk( 
                ε-> exp(-β*γ*ε) * ε *
                 quadgk( λ ->  1*cosh(β*γ*v*sqrt(ε^2-1)*cos(φ)*cos(X_sch(ξ, ε, λ))) *cosh(β*γ*v*sqrt(ε^2-1)*sin(φ)*sin(X_sch(ξ, ε, λ)))/sqrt(R_sch(ξ, ε, λ)), λ_c_sch(ε), λ_max_sch(ξ,ε))[1],ε_min_sch(ξ), infinity)[1]
    return integral
end
function J_r_ABS_sch(ξ,φ)
    coeff = -2*m_0^3/(ξ-2) 
    #coeff = 1
    integral = coeff *quadgk( ε->  
    quadgk(λ-> cosh(β*γ*v*sqrt(ε^2-1)*sin(φ)*sin(X_sch(ξ, ε, λ)))*exp(-β*γ*(ε+v*sqrt(ε^2-1)*cos(φ)*cos(X_sch(ξ,ε,λ)))),0,λ_c_sch(ε))[1],1,infinity)[1]
    return integral
end
function J_r_SCATT_sch(ξ,φ)
    coeff = 4*m_0^3/(ξ-2)
    integral = coeff * quadgk(ε-> exp(-β*γ*ε) * quadgk(λ-> cosh(β*γ*v*sqrt(ε^2-1)*sin(φ)*sin(X_sch(ξ,ε,λ)))*sinh(β*γ*v*sqrt(ε^2-1)*cos(φ)*cos(X_sch(ξ,ε,λ))),λ_c_sch(ε),λ_max_sch(ξ,ε))[1],ε_min_sch(ξ), infinity)[1]
    return integral
end

function J_φ_ABS_sch(ξ, φ)
    coeff = -2 *M* m_0^3*M / ξ 
   # coeff = 1
    integral = coeff *quadgk(
        ε -> quadgk(
         λ-> λ/sqrt(R_sch(ξ, ε, λ)) * exp(-β*γ*(ε+v*sqrt(ε^2-1)*cos(φ)*cos(X_sch(ξ,ε,λ))))* 
         sinh(β*γ*v*sqrt(ε^2-1)*sin(φ)*sin(X_sch(ξ,ε,λ))),0, λ_c_sch(ε))[1],1,infinity)[1]
    return integral
end
function J_φ_SCATT_sch(ξ, φ)
    coeff = -4 * M * m_0^3*M / ξ
   # coeff = 1
    integral = coeff * quadgk(ε-> exp(-β*γ*ε) *  quadgk(λ-> λ* sinh(β*γ*v*sqrt(ε^2-1)*sin(φ)*sin(X_sch(ξ,ε,λ))) * cosh(β*γ*v*sqrt(ε^2-1)*cos(φ)*cos(X_sch(ξ,ε,λ))) / sqrt(R_sch(ξ, ε, λ)),λ_c_sch(ε),λ_max_sch(ξ,ε))[1], ε_min_sch(ξ), infinity)[1]
    return integral
end

#############KERR################
X_kerr(ξ, ε, λ, α) = quadde(_ξ_ -> (λ + (α * ε) / (1 - 2 / _ξ_)) / (((α^2) / (1 - 2 / _ξ_) + _ξ_^2) * sqrt((ε^2 - (1 - 2 / _ξ_) * (1 + λ^2 / _ξ_^2) - (α^2 + 2 * ε * λ * α) / (_ξ_^2)))), ξ, infinity)[1]

U_λ_kerr(ξ, λ) = (1 - 2 / ξ) * (1 + λ^2 / ξ^2)
function ε_min_kerr(ξ, α, ϵ_σ)
    if ξ < ξ_ph(ϵ_σ, α)
        temp = Inf
    elseif ξ_ph(ϵ_σ, α) < ξ && ξ < ξ_mb(ϵ_σ, α)
        temp = sqrt((-2 * ϵ_σ * α * (α^2 + (ξ - 2) * ξ) * ξ^(-1 / 2) + α^2 * (5 - 3 * ξ) + (ξ - 3) * (ξ - 2)^2 * ξ) / (ξ * ((ξ - 3)^2 * ξ - 4 * α^2)))
    elseif ξ >= ξ_mb(ϵ_σ, α)
        temp = 1
    end
    # print("eps_min = ", temp)
    return temp
end

function R̃_kerr(ξ, ε, α, λ, ϵ_σ)
    temp = ε^2 - U_λ_kerr(ξ, λ) - α * (α + 2 * ε * λ * ϵ_σ) / ξ^2
    if temp < 0
        return 0
    else
        return temp
    end
end

S(ξ, ε, λ, α, ϵ_σ, ϵ_r,φ) = exp(-(ε + ϵ_σ * v * sqrt(ε^2 - 1) * sin(φ - ϵ_σ * ϵ_r * (π / 2 - X_kerr(ξ, ε, λ, α)))) * β / sqrt(1 - v^2))
function ξ_ph(eps_sigma, alfa)
    temp = 2 + 2 * cos(2 / 3 * acos(-eps_sigma * alfa))
    # println("ξ_ph = ", temp)
    return temp
end
function ξ_mb(eps_sigma, alfa)

    temp = 2 - eps_sigma * alfa + 2 * sqrt(1 - eps_sigma * alfa)
    #println("ξ_mb = ", temp)
    return temp
end
function λ_max_kerr(ξ, ε, α, ϵ_σ)
    if ξ == 2 && sign(α) * ϵ_σ == 1
        temp = -(α^2 - 4 * ε^2) / (2 * ε * α)
    else
        temp = ξ / (ξ - 2) * (-ϵ_σ * ε * α + sqrt(α^2 * (ε^2 + 2 / ξ - 1) + (ξ - 2) * (ξ * (ε^2 - 1) + 2)))
    end
    return temp
end

function λ_c_kerr(α, ε, ϵ_σ, ξ)
    # println("alfa = ", α, " ε =  ", ε, "ϵ_σ = " ,ϵ_σ, " ξ = ", ξ)
    poly_coeffs = [-α^4 - α^6 * (-1 + ε^2),
        (-4 * ϵ_σ * α^3 * ε - 6 * ϵ_σ * α^5 * ε * (-1 + ε^2)),
        (16 - 2 * α^2 - 4 * ϵ_σ^2 * α^2 * ε^2 + 18 * α^2 * (-1 + ε^2) - 3 * α^4 * (-1 + ε^2) - 12 * ϵ_σ^2 * α^4 * ε^2 * (-1 + ε^2)),
        (-4 * ϵ_σ * α * ε + 36 * ϵ_σ * α * ε * (-1 + ε^2) - 12 * ϵ_σ * α^3 * ε * (-1 + ε^2) - 8 * ϵ_σ^3 * α^3 * ε^3 * (-1 + ε^2)),
        (-1 + 18 * (-1 + ε^2) - 3 * α^2 * (-1 + ε^2) - 12 * ϵ_σ^2 * α^2 * ε^2 * (-1 + ε^2) + 27 * (-1 + ε^2)^2),
        6 * ϵ_σ * α * ε * (-1 + ε^2),
        1 - ε^2]
    poly = Polynomial(poly_coeffs)
    sols_imaginary = PolynomialRoots.roots(Float64.(poly_coeffs))
    sols = filter(sol -> abs(imag(sol)) < 1e-15, sols_imaginary)
    limit_λ = -ϵ_σ * α + 2 + 2 * sqrt(1 - ϵ_σ * α)
    if isempty(sols)
        return nothing
    else
        real_sols = broadcast(abs, (real.(sols)))
        maks = maximum(real_sols)
        return maks >= limit_λ ? maks : nothing
    end
end

function __jt_integrals__(ξ, λ, ε, α, ϵ_σ, ϵ_r,φ)
    if R̃_kerr(ξ, ε, α, λ, ϵ_σ) == 0
        return 0
    else
        temp = ε * S(ξ, ε, λ, α, ϵ_σ, ϵ_r,φ) / sqrt(R̃_kerr(ξ, ε, α, λ, ϵ_σ))
        return temp
    end
end
function __jr_integrals__(ξ, λ, ε, α, ϵ_σ, ϵ_r,φ)
   # if R̃_kerr(ξ, ε, α, λ, ϵ_σ) == 0
    #    return 0
   # else
    temp = ϵ_r * S(ξ, ε, λ, α, ϵ_σ, ϵ_r,φ)
    return temp
   # end
end
function __jφ_integrals__(ξ, λ, ε, α, ϵ_σ, ϵ_r,φ)
    R = R̃_kerr(ξ, ε, α, λ, ϵ_σ)
    
    if R̃_kerr(ξ, ε, α, λ, ϵ_σ) == 0
        return 0
    else
        temp = ϵ_σ * S(ξ, ε, λ, α, ϵ_σ, ϵ_r,φ) * (λ + ϵ_σ * α * ε) / sqrt(R̃_kerr(ξ, ε, α, λ, ϵ_σ))
        #println("R = $(R) for ξ = $(ξ), λ = $(λ), ε = $(ε), ϵ_σ = $(ϵ_σ), funkcja podcałkowa = $(temp)")
        return temp
    end
end
function J_t_ABS_kerr(f, ksi,φ, alfa, m_0)
    temp1(λ, ε) = -m_0^3 / ksi * f(ksi, λ, ε, alfa,  1, -1,φ) #eps_sigma = 1; eps_r = -1
    temp2(λ, ε) = -m_0^3 / ksi * f(ksi, λ, ε, alfa, -1, -1,φ) #eps_sigma = -1; eps_r = -1
    result1, err1 = quadgk(ε -> quadgk(λ -> temp1(λ, ε), 0, λ_c_kerr(alfa, ε,  1, ksi))[1], 1, Inf)
    result2, err2 = quadgk(ε -> quadgk(λ -> temp2(λ, ε), 0, λ_c_kerr(alfa, ε, -1, ksi))[1], 1, Inf)
    result = result1 + result2
    return result

end
function J_φ_ABS_kerr(f, ksi,φ, alfa, m_0, M)
    temp1(λ, ε) = M * m_0^3 / ksi * f(ksi, λ, ε, alfa,  1, -1,φ) #eps_sigma = 1; eps_r = -1
    temp2(λ, ε) = M * m_0^3 / ksi * f(ksi, λ, ε, alfa, -1, -1,φ) #eps_sigma = -1; eps_r = -1
    result1, err1 = quadgk(ε -> quadgk(λ -> temp1(λ, ε), 0, λ_c_kerr(alfa, ε,  1, ksi))[1], 1, Inf)
    result2, err2 = quadgk(ε -> quadgk(λ -> temp2(λ, ε), 0, λ_c_kerr(alfa, ε, -1, ksi))[1], 1, Inf)
    result = result1 + result2
    return result
end
function J_r_ABS_kerr(f, ksi,φ, alfa, m_0)
    temp1(λ, ε) = (m_0^3 * ksi) / (ksi * (ksi - 2) + alfa^2) * (f(ksi, λ, ε, alfa, 1, -1,φ)) #eps_sigma = 1; eps_r = -1
    temp2(λ, ε) = (m_0^3 * ksi) / (ksi * (ksi - 2) + alfa^2) * (f(ksi, λ, ε, alfa, -1, -1,φ)) #eps_sigma = -1; eps_r = -1
    result1, err = quadgk(ε -> quadgk(λ -> temp1(λ, ε), 0, λ_c_kerr(alfa, ε, 1, ksi))[1], 1, Inf)
    result2, err = quadgk(ε -> quadgk(λ -> temp2(λ, ε), 0, λ_c_kerr(alfa, ε, -1, ksi))[1], 1, Inf)
    result = result1 + result2
    return result
end

function J_t_SCATT_kerr(f, ksi,φ, alfa, m_0)
    coeff = -m_0^3 / ksi
    temp1(λ, ε) = coeff * (f(ksi, λ, ε, alfa, 1, 1,φ)) #eps_sigma = 1; eps_r = 1
    temp2(λ, ε) = coeff * (f(ksi, λ, ε, alfa, -1, 1,φ)) #eps_sigma = -1; eps_r = 1
    temp3(λ, ε) = coeff * (f(ksi, λ, ε, alfa, 1, -1,φ)) #eps_sigma = 1; eps_r = -1
    temp4(λ, ε) = coeff * (f(ksi, λ, ε, alfa, -1, -1,φ)) #eps_sigma = 1; eps_r = 1
    result1, err1 = quadgk(ε -> quadgk(λ -> temp1(λ, ε), λ_c_kerr(alfa, ε, 1, ksi), λ_max_kerr(ksi, ε, alfa, 1))[1], ε_min_kerr(ksi, alfa, 1), infinity) #lower boundary = λ_c; upper_boundary = λ_max 
    result2, err2 = quadgk(ε -> quadgk(λ -> temp2(λ, ε), λ_c_kerr(alfa, ε, -1, ksi), λ_max_kerr(ksi, ε, alfa, -1))[1], ε_min_kerr(ksi, alfa, -1),  infinity)
    result3, err3 = quadgk(ε -> quadgk(λ -> temp3(λ, ε), λ_c_kerr(alfa, ε, 1, ksi), λ_max_kerr(ksi, ε, alfa, 1))[1], ε_min_kerr(ksi, alfa, 1), infinity)
    result4, err4 = quadgk(ε -> quadgk(λ -> temp4(λ, ε), λ_c_kerr(alfa, ε, -1, ksi), λ_max_kerr(ksi, ε, alfa, -1))[1], ε_min_kerr(ksi, alfa, -1), infinity)
    result = result1 + result2 + result3 + result4
    return result
end
function J_φ_SCATT_kerr(f, ksi,φ, alfa, m_0, M)
    eps_sigma1 = 1;eps_r1 = 1
    eps_sigma2 = -1; eps_r2 = 1
    eps_sigma3 = 1; eps_r3 = -1
    eps_sigma4 = 1; eps_r4 = 1
    coeff = M * m_0^3 / ksi
    temp1(λ, ε) = coeff * (f(ksi, λ, ε, alfa, 1, 1,φ)) #eps_sigma = 1; eps_r = 1
    temp2(λ, ε) = coeff * (f(ksi, λ, ε, alfa, -1, 1,φ)) #eps_sigma = -1; eps_r = 1
    temp3(λ, ε) = coeff * (f(ksi, λ, ε, alfa, 1, -1,φ)) #eps_sigma = 1; eps_r = -1
    temp4(λ, ε) = coeff * (f(ksi, λ, ε, alfa, -1, -1,φ)) #eps_sigma = 1; eps_r = 1
    result1, err1 = quadgk(ε -> quadgk(λ -> temp1(λ, ε), λ_c_kerr(alfa, ε, 1, ksi), λ_max_kerr(ksi, ε, alfa, 1))[1], ε_min_kerr(ksi, alfa, 1), infinity) #lower boundary = λ_c; upper_boundary = λ_max 
    result2, err2 = quadgk(ε -> quadgk(λ -> temp2(λ, ε), λ_c_kerr(alfa, ε, -1, ksi), λ_max_kerr(ksi, ε, alfa, -1))[1], ε_min_kerr(ksi, alfa, -1),  infinity)
    result3, err3 = quadgk(ε -> quadgk(λ -> temp3(λ, ε), λ_c_kerr(alfa, ε, 1, ksi), λ_max_kerr(ksi, ε, alfa, 1))[1], ε_min_kerr(ksi, alfa, 1), infinity)
    result4, err4 = quadgk(ε -> quadgk(λ -> temp4(λ, ε), λ_c_kerr(alfa, ε, -1, ksi), λ_max_kerr(ksi, ε, alfa, -1))[1], ε_min_kerr(ksi, alfa, -1), infinity)
    result = result1 + result2 + result3 + result4
    return result
end
function J_r_SCATT_kerr(f, ksi,φ, alfa, m_0)
    coeff = m_0^3 * ksi / (ksi * (ksi - 2) + alfa^2) 
    temp1(λ, ε) = coeff * (f(ksi, λ, ε, alfa, 1, 1,φ)) #eps_sigma = 1; eps_r = 1
    temp2(λ, ε) = coeff * (f(ksi, λ, ε, alfa, -1, 1,φ)) #eps_sigma = -1; eps_r = 1
    temp3(λ, ε) = coeff * (f(ksi, λ, ε, alfa, 1, -1,φ)) #eps_sigma = 1; eps_r = -1
    temp4(λ, ε) = coeff * (f(ksi, λ, ε, alfa, -1, -1,φ)) #eps_sigma = 1; eps_r = 1
    result1, err1 = quadgk(ε -> quadgk(λ -> temp1(λ, ε), λ_c_kerr(alfa, ε, 1, ksi), λ_max_kerr(ksi, ε, alfa, 1))[1], ε_min_kerr(ksi, alfa, 1), infinity) #lower boundary = λ_c; upper_boundary = λ_max 
    result2, err2 = quadgk(ε -> quadgk(λ -> temp2(λ, ε), λ_c_kerr(alfa, ε, -1, ksi), λ_max_kerr(ksi, ε, alfa, -1))[1], ε_min_kerr(ksi, alfa, -1),  infinity)
    result3, err3 = quadgk(ε -> quadgk(λ -> temp3(λ, ε), λ_c_kerr(alfa, ε, 1, ksi), λ_max_kerr(ksi, ε, alfa, 1))[1], ε_min_kerr(ksi, alfa, 1), infinity)
    result4, err4 = quadgk(ε -> quadgk(λ -> temp4(λ, ε), λ_c_kerr(alfa, ε, -1, ksi), λ_max_kerr(ksi, ε, alfa, -1))[1], ε_min_kerr(ksi, alfa, -1), infinity)
    result = result1 + result2 + result3 + result4
    return result
end
function create_r_tbl(start, ending, step, M)
    seq1 = collect(start:step:ending)
    #seq2 = [2^k for k in 3:10]
    #seq = unique(vcat(seq1, seq2)) #unique - removes duplicates; vcat - adds sequances vertically
    result = seq1 .* M#filter(x -> !(x in [xi_hor, xi_ph, xi_mb]), seq) # .* operator multiplies sequence by a number elementwise
    return result
end
# Creating tables for values
J_t_ABS_sch_values = Float64[]
J_r_ABS_sch_values = Float64[]
J_φ_ABS_sch_values = Float64[]
J_t_SCATT_sch_values = Float64[]
J_r_SCATT_sch_values = Float64[]
J_φ_SCATT_sch_values = Float64[]
J_X_ABS_sch_values = Float64[]
J_Y_ABS_sch_values = Float64[]
J_X_SCATT_sch_values = Float64[]
J_Y_SCATT_sch_values = Float64[]
J_X_TOTAL_sch_values = Float64[]
J_Y_TOTAL_sch_values = Float64[]
timestamps = String[]
r_values = Int64[]
φ_values = Float64[]
x_values = Float64[]
y_values = Float64[]
φ_table = LinRange(-π, π, 20)
r_table = create_r_tbl(5, 18, 1, M)
for φ in φ_table
    for ksi in r_table
        timestamp = string(Dates.now())
        push!( r_values,ksi)
        push!(φ_values,φ)
        push!(timestamps, timestamp) #date and time for which the data was produced
        #alfa = 0.0001
        #println("ksi ",ksi," φ = ", φ)
        J_t_ABSsch = J_t_ABS_sch(ksi,φ)
        J_r_ABSsch = J_r_ABS_sch(ksi,φ)
        J_φ_ABSsch = J_φ_ABS_sch(ksi,φ)
        J_t_SCATTsch = J_t_SCATT_sch(ksi, φ)
        J_r_SCATTsch = J_r_SCATT_sch(ksi, φ)
        J_φ_SCATTsch = J_φ_SCATT_sch(ksi, φ)
        push!(J_t_ABS_sch_values, J_t_ABSsch)
        push!(J_r_ABS_sch_values, J_r_ABSsch)
        push!(J_φ_ABS_sch_values, J_φ_ABSsch)
        push!(J_t_SCATT_sch_values, J_t_SCATTsch)
        push!(J_r_SCATT_sch_values, J_r_SCATTsch)
        push!(J_φ_SCATT_sch_values, J_φ_SCATTsch)
        x = ksi*cos(φ)
        y = ksi*sin(φ)
        push!(x_values, x)
        push!(y_values, y)
        J_r_TOTALsch = J_r_ABSsch+J_r_SCATTsch
        J_φ_TOTALsch = J_φ_ABSsch+J_φ_SCATTsch
        J_X_TOTALsch = J_r_TOTALsch * cos(φ) - J_φ_TOTALsch * ksi * M * sin(φ) #J^x  = J^r Cosφ - (J^φ) r Sinφ 
        J_Y_TOTALsch = J_r_TOTALsch * sin(φ) - J_φ_TOTALsch * ksi * M * cos(φ) #J^y  = J^r Sinφ + J^φ r Cosφ
        push!(J_X_TOTAL_sch_values, J_X_TOTALsch)
        push!(J_Y_TOTAL_sch_values, J_Y_TOTALsch)
    end
end
data = DataFrame(r = r_values,φ = φ_values,x = x_values, y = y_values,timestamp = timestamps,
                J_t_ABSsch = J_t_ABS_sch_values, J_r_ABSsch = J_r_ABS_sch_values,J_φ_ABSsch = J_φ_ABS_sch_values,
                J_t_SCATTsch = J_t_SCATT_sch_values, J_r_SCATTsch = J_r_SCATT_sch_values,J_φ_SCATTsch = J_φ_SCATT_sch_values,
                J_X_TOTAlsch = J_X_TOTAL_sch_values, J_Y_TOTALsch = J_Y_TOTAL_sch_values)
#saving data to a file
timestamp_for_file = Dates.format(Dates.now(), "yyyy-mm-dd_HH-MM-SS")
filename = "/home/korizekori/magisterka/Schwarzschild/data_Schwarzschild_$(timestamp_for_file).csv"
if isfile(filename)
    CSV.write(filename, data, append = true)
else
    CSV.write(filename, data)
end
#=
for x in 5.5:-0.5:5 # printing differences between two integrals 

    J_t_ABS_Rel = J_t_ABS_kerr(__jt_integrals__,x,1,0,1)   / J_t_ABS_sch(x,1)
    J_r_ABS_Rel = J_r_ABS_kerr(__jr_integrals__,x,1,0,1)   / J_r_ABS_sch(x,1)
    J_φ_ABS_Rel = J_φ_ABS_kerr(__jφ_integrals__,x,1,0,1,1) / J_φ_ABS_sch(x,1)

    println("x = $x , J_t_ABS: Kerr / Sch = ", J_t_ABS_Rel)
    println("x = $x , J_r_ABS: Kerr / Sch = ", J_r_ABS_Rel)
    println("x = $x , J_φ_ABS: Kerr / Sch = ", J_φ_ABS_Rel)    
    println("")

=#
#=
    J_t_SCATT_Rel = J_t_SCATT_kerr(__jt_integrals__, x, 1, 0, 1) / J_t_SCATT_sch(x, 1)
    J_r_SCATT_Rel = J_r_SCATT_kerr(__jr_integrals__, x, 1, 0, 1) / J_r_SCATT_sch(x, 1)
    J_φ_SCATT_Rel = J_φ_SCATT_kerr(__jφ_integrals__, x, 1,0, 1, 1)/ J_φ_SCATT_sch(x, 1)

    println("x = $x , J_t_SCATT: Kerr / Sch = ", J_t_SCATT_Rel)
    println("x = $x , J_r_SCATT: Kerr / Sch = ", J_r_SCATT_Rel)
    println("x = $x , J_φ_SCATT: Kerr / Sch = ", J_φ_SCATT_Rel)
    
    println("")
    

end
=#
