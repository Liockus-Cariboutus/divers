--[[
    Player is requesting the admin panel. Send the request to the
    server only if the user is a superadmin!!
]]--
concommand.Add("rpgr_config", function(ply, cmd, args, argstr) 
    if (ply:IsSuperAdmin()) then
        net.Start("RPGR_adminpanel")

        net.WriteUInt(GetConVar("rpgr_maxbooks"):GetInt(), 16)
        net.WriteUInt(GetConVar("rpgr_maxjournals"):GetInt(), 16)
        net.WriteUInt(GetConVar("rpgr_maxstickynotes"):GetInt(), 16)
        net.WriteUInt(GetConVar("rpgr_adminignore"):GetInt(), 2)
        net.WriteUInt(GetConVar("rpgr_allowbookdupes"):GetInt(), 2)
        net.WriteUInt(GetConVar("rpgr_allowsnotereuse"):GetInt(), 2)
        net.WriteUInt(GetConVar("rpgr_allowdesc"):GetInt(), 3)
        net.WriteString(GetConVar("rpgr_descchatflag"):GetString())

        net.Send(ply)
    end
end)

--[[
    Describe the entity you are looking at (Within set limits)
]]--
concommand.Add("rpgr_setdesc", function(ply, cmd, args, argstr)
    describe(ply, argstr)
end, function() end, "Describe the object you are looking at.")

concommand.Add("rpgr_getallbooks", function (ply, cmd, args, argstr)
    net.Start("RPGR_request_pbooks")
    local t = getPublishedBooks()
    net.WriteInt(#t, 16)
    net.WriteData(t, #t)
    net.Send(ply)
end)

--[[
  Establish Console Variables for customization
]]--

CreateConVar("rpgr_adminignore", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), 
[[Admins can ignore limits
    0 = false
    1 = true
    2 = true, but admins may not edit other players' books/notes/etc
]], 0, 2)
CreateConVar("rpgr_maxbooks", 3, bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "The maximum amount of books each player may own. 0 to disable", 0, 999)
CreateConVar("rpgr_maxjournals", 3, bit.bor(FCVAR_ARCHIVE,FCVAR_NOTIFY), "The maximum amount of journals each player may own. 0 to disable", 0, 999)
CreateConVar("rpgr_maxstickynotes", 10, bit.bor(FCVAR_ARCHIVE,FCVAR_NOTIFY), "The maximum amount of sticky notes each player may place. 0 to disable", 0, 999)
CreateConVar("rpgr_allowstickynotes", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "Allow players to wield the stickynote swep", 0, 1)
CreateConVar("rpgr_allowbookdupes", 1, bit.bor(FCVAR_ARCHIVE,FCVAR_NOTIFY), 
[[Allow players to duplicate books and journals with the duplicator
    0 = disable
    1 = allow
    2 = owner only
]], 0, 2)
CreateConVar("rpgr_allowsnotereuse", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "Allow players to reuse sticky notes", 0, 1)
CreateConVar("rpgr_allowdesc", 2, bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), 
[[Allow players to use descriptions
    0 = disable
    1 = only books and notes
    2 = any valid prop
    3 = everything except for world and other players
]], 0, 3)
CreateConVar("rpgr_descchatflag", "/desc", bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), 
[[Set the text flag that will trigger the description command. This text will be consumed on use.
    eg: rpgr_descchatflag /d
        Player: /d This is a description
        (On Hover) This is a description
]])
