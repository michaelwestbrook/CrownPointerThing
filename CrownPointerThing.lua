-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
CrownPointerThing = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
CrownPointerThing.name = "CrownPointerThing"

-- Next we create a function that will initialize our addon
function CrownPointerThing:Initialize()
  self.savedVariables = ZO_SavedVars:New(string.format("%sSavedVariables", CrownPointerThing.name), 1, nil, {})
  EVENT_MANAGER:RegisterForEvent(
    CrownPointerThing.name,
    EVENT_PLAYER_ACTIVATED,
    CrownPointerThing.EVENT_PLAYER_ACTIVATED
  )
  EVENT_MANAGER:RegisterForEvent(
    CrownPointerThing.name,
    EVENT_PLAYER_COMBAT_STATE,
    CrownPointerThing.EVENT_PLAYER_COMBAT_STATE
  )
end

function CrownPointerThing.OnIndicatorMoveStop()
  CrownPointerThing.savedVariables.left = CrownPointerThingIndicator:GetLeft()
  CrownPointerThing.savedVariables.top = CrownPointerThingIndicator:GetTop()
end

function CrownPointerThing:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top

  CrownPointerThingIndicator:ClearAnchors()
  CrownPointerThingIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Event Handlers
function CrownPointerThing.EVENT_PLAYER_ACTIVATED(eventCode, initial)
  d(CrownPointerThing.name)
  CrownPointerThing:RestorePosition()
end

local heading = -1.0
function CrownPointerThing.onUpdate()
  newHeading = GetPlayerCameraHeading()
  bar = {}
  -- if heading ~= newHeading then
  heading = newHeading
  bar.X, bar.Y, bar.H = GetMapPlayerPosition("player")
  CrownPointerThingIndicatorLabel:SetText(bar.X)
  -- end
  -- newHeading = GetPlayerCameraHeading()
  -- -- entity.Zone = GetUnitZone(entity.Tag)
  -- -- entity.Name = GetUnitName(entity.Tag)
  -- if heading ~= newHeading then
  --   heading = newHeading
  --   local tagByIndex
  --   local unitName
  --   for xmemberid = 1, GetGroupSize(), 1 do
  --     tagByIndex = GetGroupUnitTagByIndex(xmemberid)
  --     unitName = GetUnitName(tagByIndex)
  --     d(tagByIndex)
  --     d(unitName)
  --     d('$$$$$')
  --   -- CrownPointerThingIndicatorLabel:SetText(foo)
  --   end
  -- end
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function CrownPointerThing.EVENT_ADD_ON_LOADED(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CrownPointerThing.name then
    CrownPointerThing:Initialize()
  end
end

function CrownPointerThing.EVENT_PLAYER_COMBAT_STATE(event, inCombat)
  d(inCombat)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(CrownPointerThing.name, EVENT_ADD_ON_LOADED, CrownPointerThing.EVENT_ADD_ON_LOADED)
