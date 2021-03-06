#=
# 7. Lid-driven cavity flow
In this notebook we will simulate the flow in a square cavity with a top moving wall.
=#
using ViscousFlow
#-
using Plots

#=
## Problem specification
Take $Re=100$ for example:
=#
Re = 100

#=
## Discretization
Note that the rectangle function used for making the cavity shape requires a specified half length. The
immersed boundary projection method for internal flow requires the size of the domain to
be at least a step size greater at the boundaries (i.e. `halflength + Δx`).
=#
Δt,Δx = setstepsizes(Re,gridRe=1.0)
halflength=0.5
domain_lim=halflength+1.01*Δx
xlim, ylim = (-domain_lim,domain_lim),(-domain_lim,domain_lim)

#=
## Cavity Geometry
A square cavity can be created using the `Rectangle()` function with the half length defined above.
The `shifted=true` argument ensures that points are not placed at the corners, where
they have ill-defined normal vectors.
=#
body = Rectangle(halflength,halflength,1.5*Δx,shifted=true)
plot(body,fillrange=nothing)

#=
## Boundary Condition at the moving wall
Assign velocity to the top boundary. The `LidDrivenCavity()` function can be used
to specify the velocity value at the top wall. Note : Non-dimensional velocity = 1
=#
m = ViscousFlow.LidDrivenCavity(1.0)

#=
## Construct the system structure
The last two input `flow_side` and `static_points` must specified so the default setting in the
 `NavierStokes()` function can be overwritten.

`static_points` is set to true because the cavity wall points are not actually moving.
=#
sys = NavierStokes(Re,Δx,xlim,ylim,Δt,body,m,flow_side = InternalFlow,static_points = true)

#=
Initialize
=#
u0 = newstate(sys)

#=
Set up integrator
=#
tspan = (0.0,10.0)
integrator = init(u0,tspan,sys)

#=
## Solve
=#
step!(integrator,10)

#=
## Examine
Plot the vorticity and streamlines
=#

plot(
plot(vorticity(integrator),sys,title="Vorticity",clim=(-10,10),color=:turbo,linewidth=1.5,ylim=ylim,levels=-6:0.5:5),
plot(streamfunction(integrator),sys,title="Streamfunction",color=:black,levels=vcat(0.009:0.01:0.11,0.1145,0.11468,0.11477),ylim=ylim)
   )

#=
Make a movie:
=#
sol = integrator.sol;
@gif for (u,t) in zip(sol.u,sol.t)
    plot(vorticity(u,sys,t),sys,clim=(-10,10),levels=range(-10,10,length=30),color=:turbo)
end every 5
