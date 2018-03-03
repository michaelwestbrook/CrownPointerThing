-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
CrownPointerThing = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
CrownPointerThing.name = "CrownPointerThing"

CrownPointerThing.texture = "esoui/art/miscellaneous/transform_arrow.dds"

-- From Exterminatus http://www.esoui.com/downloads/info329-0.1.html
local function NormalizeAngle(c)
  if c > math.pi then
    return c - 2 * math.pi
  end
  if c < -math.pi then
    return c + 2 * math.pi
  end
  return c
end

local Arrow

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
  CrownPointerThingIndicator:ClearAnchors()
  CrownPointerThingIndicator:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

-- Event Handlers
function CrownPointerThing.EVENT_PLAYER_ACTIVATED(eventCode, initial)
  d(CrownPointerThing.name)
  CrownPointerThing.RestorePosition()

  Arrow = WINDOW_MANAGER:CreateControl("Arrow", CrownPointerThingIndicator, CT_TEXTURE)
  Arrow:SetDimensions(80, 80) -- Set the size of the texture control
  Arrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 0)
  Arrow:SetTexture(CrownPointerThing.texture) -- Set the actual texture to use
  Arrow:SetAlpha(1)
end

function UpdateTexture(DistanceToTarget, AngleToTarget, AbsoluteLinear)
  if not Arrow then
    return
  end
  local R = 1
  local G = 1 - AbsoluteLinear
  local B = 1 - math.min(AbsoluteLinear, 0.05) * 20
  -- local AbsAlpha = 0.3 + (0.9 - 0.3) * AbsoluteLinear
  Arrow:SetTextureRotation(-AngleToTarget + math.pi / 2)
  Arrow:SetColor(R, G, B)
  -- Arrow:SetAlpha(AbsAlpha)
end

function CrownPointerThing.onUpdate()
  local leader = GetGroupLeaderUnitTag()
  local Px, Py, Ph = GetMapPlayerPosition("player")
  local Tx, Ty, Th = GetMapPlayerPosition(leader)
  local Heading = GetPlayerCameraHeading()

  local DX = Px - Tx
  local DY = Py - Ty
  local D = math.sqrt((DX * DX) + (DY * DY))

  local Angle = NormalizeAngle(Heading - math.atan2(DX, DY))
  local Linear = Angle / math.pi
  local AbsoluteLinear = math.abs(Linear)

  -- CrownPointerThingIndicatorLabel:SetText(
  --   string.format(
  --     "DX: %.5f, Dy: %.5f, D%.5f, Heading: %.5f, Angle: %.5f, Linear: %.5f, ALinear: %.5f",
  --     DX,
  --     DY,
  --     D,
  --     Heading,
  --     Angle,
  --     Linear,
  --     AbsoluteLinear
  --   )
  -- )

  UpdateTexture(D, Angle, AbsoluteLinear)
  -- CrownPointerThingIndicatorTopDivider:SetHidden(false)
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
