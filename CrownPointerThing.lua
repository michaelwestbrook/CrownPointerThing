-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
CrownPointerThing = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
CrownPointerThing.name = "CrownPointerThing"

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

local LeftArrow, RightArrow

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
  local left
  local top
  if
    CrownPointerThing.savedVariables and CrownPointerThing.savedVariables.left and
      CrownPointerThing.savedVariables.right
   then
    left = CrownPointerThing.savedVariables.left
    top = CrownPointerThing.savedVariables.top
  else
    left = 0
    right = 0
  end

  CrownPointerThingIndicator:ClearAnchors()
  CrownPointerThingIndicator:SetAnchor(CENTER, GuiRoot, CENTER, left, top)
end

-- Event Handlers
function CrownPointerThing.EVENT_PLAYER_ACTIVATED(eventCode, initial)
  d(CrownPointerThing.name)
  CrownPointerThing.RestorePosition()
  LeftArrow = WINDOW_MANAGER:CreateControl("LeftArrow", CrownPointerThingIndicator, CT_TEXTURE)
  LeftArrow:SetDimensions(80, 80) -- Set the size of the texture control
  LeftArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 0)
  LeftArrow:SetTexture("esoui/art/miscellaneous/transform_arrow.dds") -- Set the actual texture to use
  LeftArrow:SetTextureRotation(-math.pi)
  LeftArrow:SetAlpha(0)

  RightArrow = WINDOW_MANAGER:CreateControl("RightArrow", CrownPointerThingIndicator, CT_TEXTURE)
  RightArrow:SetDimensions(80, 80) -- Set the size of the texture control
  RightArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 0)
  RightArrow:SetTexture("esoui/art/miscellaneous/transform_arrow.dds") -- Set the actual texture to use
  RightArrow:SetAlpha(0)

  UpArrow = WINDOW_MANAGER:CreateControl("UpArrow", CrownPointerThingIndicator, CT_TEXTURE)
  UpArrow:SetDimensions(80, 80) -- Set the size of the texture control
  UpArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 0)
  UpArrow:SetTexture("esoui/art/miscellaneous/transform_arrow.dds") -- Set the actual texture to use
  UpArrow:SetAlpha(0)
  UpArrow:SetTextureRotation(math.pi / 2)
  UpArrow:SetColor(0, 1, 0)

end

function UpdateTexture(DistanceToTarget, AngleToTarget, AbsoluteLinear)
  if not LeftArrow or not RightArrow then
    return
  end
  local R = 1
  local G = 1 - AbsoluteLinear
  local B = 1 - math.min(AbsoluteLinear, 0.05) * 20
  local AbsAlpha = 0.3 + (0.9 - 0.3) * AbsoluteLinear

  if AngleToTarget > 0.2 then
    LeftArrow:SetColor(0, 0, 0)
    RightArrow:SetColor(R, G, B)
    LeftArrow:SetAlpha(-AbsAlpha)
    RightArrow:SetAlpha(AbsAlpha)
    UpArrow:SetAlpha(0)
  elseif AngleToTarget < -0.2 then
    LeftArrow:SetColor(R, G, B)
    RightArrow:SetColor(0, 0, 0)
    LeftArrow:SetAlpha(AbsAlpha)
    RightArrow:SetAlpha(-AbsAlpha)
    UpArrow:SetAlpha(0)
  else
    LeftArrow:SetColor(0, 1, 0)
    RightArrow:SetColor(0, 1, 0)
    LeftArrow:SetAlpha(0)
    RightArrow:SetAlpha(0)
    UpArrow:SetAlpha(1)
  end
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
