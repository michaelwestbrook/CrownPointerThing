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

local FooTexture

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

  FooTexture = WINDOW_MANAGER:CreateControl("MyAddonExampleTexture", CrownPointerThingIndicator, CT_TEXTURE) -- Create a texture control
  FooTexture:SetDimensions(150, 150) -- Set the size of the texture control
  FooTexture:SetAnchor(TOPLEFT, CrownPointerThingIndicator, TOPLEFT, 0, 0) -- Set the position in relation to the topleft corner of the character screen
  FooTexture:SetTexture("esoui/art/miscellaneous/transform_arrow.dds") -- Set the actual texture to use
  FooTexture:SetAlpha(1)
  UpdateTexture(FooTexture)
  d(FooTexture:GetColor())
end

function UpdateTexture()
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


  FooTexture:ClearAnchors()
  FooTexture:SetAnchor(CENTER, CrownPointerThingIndicator, CENTER, -100, -100)
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
  -- MyTexture:SetAnchor(CENTER, CrownPointerThingIndicator, LEFT, 0, 0) -- Set the position in relation to the topleft corner of the character screen
  -- MyTexture:SetTexture("art/fx/texture/dandelionfluff_512x4.dd")
  -- CrownPointerThingIndicatorLabel:SetText(
  --   string.format("DX: %.5f, Dy: %.5f, D%.5f, Heading: %.5f, Angle: %.5f, Linear: %.5f, ALinear: %.5f", DX, DY, D, Heading, Angle, Linear, AbsoluteLinear)
  -- )
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
