using Simulation
using Unitful
using Unitful.DefaultSymbols
using MyUnitful
import Simulation: matchdict, cancel, HabitatUpdate, NoChange, eraChange, AbstractBudget, checkbud, _habitatupdate!

function lcAE(lc::LandCover, maxbud::Unitful.Quantity{Float64}, area::Unitful.Area)
    lc = LandCover(lc.array[:, 0.0m .. 1.25e6m])
    dimension = size(lc.array)
    gridsquaresize = lc.array.axes[1].val[2] - lc.array.axes[1].val[1]
    gridsquaresize = uconvert(km, gridsquaresize)
    active = fill(true, dimension)
    active[isnan.(lc.array[:,:,1])] .= false

    hab = DiscreteHab(Array(lc.array), gridsquaresize,
        HabitatUpdate{Unitful.Dimensions{()}}(NoChange, 0.0/s))
    B = cancel(maxbud, area)
    bud = zeros(typeof(B), dimension)
    fill!(bud, B/(dimension[1]*dimension[2]))
    checkbud(B) || error("Unrecognised unit in budget")
    budtype = matchdict[unit(B)]
     return GridAbioticEnv{typeof(hab), budtype}(hab, active, budtype(bud))
end
function lcAE(lc::LandCover, maxbud::Unitful.Quantity{Float64}, active::Array{Bool, 2})
    lc = LandCover(lc.array[:, 0.0m .. 1.25e6m])
    dimension = size(lc.array)[1:2]
    gridsquaresize = lc.array.axes[1].val[2] - lc.array.axes[1].val[1]
    gridsquaresize = uconvert(km, gridsquaresize)
    hab = DiscreteHab(Array(lc.array), gridsquaresize,
        HabitatUpdate{Unitful.Dimensions{()}}(NoChange, 0.0/s))
    B = cancel(maxbud, area)
    bud = zeros(typeof(B), dimension)
    fill!(bud, B/(dimension[1]*dimension[2]))
    checkbud(B) || error("Unrecognised unit in budget")
    budtype = matchdict[unit(B)]
     return GridAbioticEnv{typeof(hab), budtype}(hab, active, budtype(bud))
end
function lcAE(lc::LandCover, bud::SolarTimeBudget, active::Array{Bool, 2})
    lc = LandCover(lc.array[:, 0.0m .. 1.25e6m])
    dimension = size(lc.array)[1:2]
    gridsquaresize = lc.array.axes[1].val[2] - lc.array.axes[1].val[1]
    gridsquaresize = uconvert(km, gridsquaresize)
    hab = DiscreteHab(Array(lc.array), gridsquaresize,
        HabitatUpdate{Unitful.Dimensions{()}}(NoChange, 0.0/s))

     return GridAbioticEnv{typeof(hab), SolarTimeBudget}(hab, active, bud)
end

function hadAE(had::HadUK, maxbud::Unitful.Quantity{Float64}, area::Unitful.Area)
    dimension = (size(had.array, 1), size(had.array,2))
    gridsquaresize = had.array.axes[1].val[2] - had.array.axes[1].val[1]
    active = fill(true, dimension)
    active[isnan.(had.array[:,:,1])] .= false

    hab = ContinuousTimeHab(Array(had.array), 1, gridsquaresize,
        HabitatUpdate{Unitful.Dimensions{()}}(eraChange, 0.0/s))
    B = Simulation.cancel(maxbud, area)
    bud = zeros(typeof(B), dimension)
    fill!(bud, B/(dimension[1]*dimension[2]))
    Simulation.checkbud(B) || error("Unrecognised unit in budget")
    budtype = Simulation.matchdict[unit(B)]
     return GridAbioticEnv{typeof(hab), budtype}(hab, active, budtype(bud))
end
function hadAE(had::HadUK, maxbud::Unitful.Quantity{Float64}, area::Unitful.Area, active::Array{Bool, 2})
    dimension = size(had.array)[1:2]
    gridsquaresize = had.array.axes[1].val[2] - had.array.axes[1].val[1]
    gridsquaresize = ustrip.(gridsquaresize) * 111.32km
    hab = ContinuousTimeHab(Array(era.array), 1, gridsquaresize,
        HabitatUpdate{Unitful.Dimensions{()}}(eraChange, 0.0/s))
    B = cancel(maxbud, area)
    bud = zeros(typeof(B), dimension)
    fill!(bud, B/(dimension[1]*dimension[2]))
    checkbud(B) || error("Unrecognised unit in budget")
    budtype = matchdict[unit(B)]
     return GridAbioticEnv{typeof(hab), budtype}(hab, active, budtype(bud))
end
function hadAE(had::HadUK, bud::B, active::Array{Bool, 2}) where {B <: AbstractBudget}
    dimension = size(had.array)[1:2]
    gridsquaresize = had.array.axes[1].val[2] - had.array.axes[1].val[1]
    gridsquaresize = uconvert(km, gridsquaresize)
    hab = ContinuousTimeHab(Array(had.array), 1, gridsquaresize,
        HabitatUpdate{Unitful.Dimensions{()}}(eraChange, 0.0/s))

     return GridAbioticEnv{typeof(hab), SolarTimeBudget}(hab, active, bud)
end

function _habitatupdate!(eco::Ecosystem, hab::HabitatCollection3, timestep::Unitful.Time)
    _habitatupdate!(eco, hab.h1, timestep)
    _habitatupdate!(eco, hab.h2, timestep)
    _habitatupdate!(eco, hab.h3, timestep)
end
