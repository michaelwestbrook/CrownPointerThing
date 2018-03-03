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
  LeftArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 15) 
  LeftArrow:SetTexture("esoui/art/miscellaneous/transform_arrow.dds") -- Set the actual texture to use
  LeftArrow:SetTextureRotation(-math.pi)
  LeftArrow:SetAlpha(1)

  RightArrow = WINDOW_MANAGER:CreateControl("RightArrow", CrownPointerThingIndicator, CT_TEXTURE)
  RightArrow:SetDimensions(80, 80) -- Set the size of the texture control
  RightArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, -15)
  RightArrow:SetTexture("esoui/art/miscellaneous/transform_arrow.dds") -- Set the actual texture to use
  RightArrow:SetAlpha(1)
  d(LeftArrow:GetColor())
end

function UpdateTexture(DistanceToTarget, AngleToTarget)
  if not LeftArrow or not RightArrow then
    return
  end
  local R, G, B
  if DistanceToTarget < .002 then
    R = 0
    G = 1
    B = 0
  elseif DistanceToTarget < .005 then
    R = 1
    G = 1
    B = 0
  elseif DistanceToTarget >= .005 then
    R = 1
    G = 0
    B = 0
  end

  LeftArrow:ClearAnchors()
  RightArrow:ClearAnchors()
  if AngleToTarget > 0 then
    LeftArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 0)
    RightArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 100, 0)
  else
    LeftArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, -100, 0)
    RightArrow:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, 0, 0)
  end
  -- RightArrow:SetColor(RightTargetColor.R, RightTargetColor.G, RightTargetColor.B)
  -- if state.Linear > 0 then
  -- Texture:SetAnchor(RIGHT, CrownPointerThingIndicator, LEFT, 10, 0)
  -- left:SetDimensions(24)
  -- left:SetColor(state.Color)
  -- left:SetAlpha(state.Settings.MinAlpha)
  --   right:SetAnchor(LEFT, RIGHT, state.Distance, 0)
  --   right:SetDimensions(state.Size)
  --   right:SetColor(state.Color)
  --   right:SetAlpha(state.Alpha)
  -- else
  --   left:SetAnchor(RIGHT, LEFT, -state.Distance, 0)
  --   left:SetDimensions(state.Size)
  --   left:SetColor(state.Color)
  --   left:SetAlpha(state.Alpha)
  --   right:SetAnchor(LEFT, RIGHT, state.Settings.MinDistance, 0)
  --   right:SetDimensions(state.Settings.MinSize)
  --   right:SetColor(state.Color)
  --   right:SetAlpha(state.Settings.MinAlpha)
  -- end
  -- FooTexture:ClearAnchors()
  -- FooTexture:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, -100, -100)
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

  CrownPointerThingIndicatorLabel:SetText(
    string.format(
      "DX: %.5f, Dy: %.5f, D%.5f, Heading: %.5f, Angle: %.5f, Linear: %.5f, ALinear: %.5f",
      DX,
      DY,
      D,
      Heading,
      Angle,
      Linear,
      AbsoluteLinear
    )
  )

  UpdateTexture(D, Angle)
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
