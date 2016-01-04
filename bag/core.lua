local addonName, ns = ...

local settings = ns.bag.settings

local impl = {}
impl.__index = impl

ns.bag.impl = impl

