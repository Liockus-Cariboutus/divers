-- Establish Network Strings
util.AddNetworkString("RPGR_adminpanel")
util.AddNetworkString("RPGR_get_book")
util.AddNetworkString("RPGR_need_book")
util.AddNetworkString("RPGR_update_book")
util.AddNetworkString("RPGR_update_book_owner")
util.AddNetworkString("RPGR_set_desc")
util.AddNetworkString("RPGR_push_config")
util.AddNetworkString("RPGR_stickynote_init")
util.AddNetworkString("RPGR_stickynote_update_swep")
util.AddNetworkString("RPGR_error")
util.AddNetworkString("RPGR_publish")
util.AddNetworkString("RPGR_request_pbooks")

--[[
    Client has asked for the contents of this book.
]]--
net.Receive("RPGR_need_book", function(len, ply) 
    local i = net.ReadUInt(14)
    local e = Entity(i)
    local b = e.bookdata
    local tt = util.Compress(b.text)

    net.Start("RPGR_get_book")
    net.WriteUInt(i,14) -- 1
    net.WriteBool(b.owner == ply:SteamID64()) -- 8
    net.WriteString(b.title) -- 2
    net.WriteString(b.author) -- 3
    net.WriteUInt(#tt,20) -- 4
    net.WriteData(tt) -- 5
    net.WriteString(b.style) -- 6
    net.WriteString(e.description) -- 7
    net.Send(ply)
end)

--[[
    Client has asked for an update to this book.
]]--
-- net.Receive("RPGR_update_book", function(len, player) 
--     local i = net.ReadUInt(14)
--     local e = Entity(i)
--     if not e.bookdata then e.bookdata = {} end

--     e.bookdata.title = net.ReadString()
--     e.bookdata.text = net.ReadString()
--     e.bookdata.style = net.ReadString()
--     e.description = net.ReadString()

--     -- Broadcast the new information
--     net.Start("RPGR_update_book")
--     net.WriteUInt(e:EntIndex(), 14)
--     net.Broadcast()
--     -- if _G.RPGR_SaveAll then
--     --     _G.RPGR_SaveAll()
--     -- end
-- end)

net.Receive("RPGR_update_book", function(len, player) 
    local i = net.ReadUInt(14)
    local e = Entity(i)
    if not IsValid(e) then return end
    if not e.bookdata then e.bookdata = {} end

    e.bookdata.title = net.ReadString()
    e.bookdata.text  = net.ReadString()
    e.bookdata.style = net.ReadString()
    e.description    = net.ReadString()

    net.Start("RPGR_update_book")
    net.WriteUInt(e:EntIndex(), 14)
    net.Broadcast()

    -- 🔥 appel live de SaveAll (réécrit DATA immédiatement)
    if SaveAll then
        SaveAll()
    end
end)







--[[
    Sent by the server when asking if you would like to download
    the contents of the book
]]--
net.Receive("RPGR_set_desc", function( len, ply) 
    local i = net.ReadUInt(14)
    local e = Entity(i)
    if e == NULL then return end

    net.Start("RPGR_set_desc")
    net.WriteUInt(i, 14)
    net.WriteString(e.description)
    net.Broadcast();
end)

net.Receive("RPGR_stickynote_init", function (len, ply) 
    local i = net.ReadUInt(14)
    local e = Entity(i)
    
    net.Start("RPGR_stickynote_init")
    net.WriteUInt(i, 14)
    net.WriteString(e.noteText)
    net.Broadcast()
end)

--[[
    Sent by the client when updating the owner in the editor panel
]]--
net.Receive("RPGR_update_book_owner", function(len, ply)
    local i = net.ReadUInt(14)
    local e = Entity(i)
    local p2id = net.ReadString()

    local p1 = player.GetBySteamID64(e.bookdata.owner) -- old owner
    local p2 = player.GetBySteamID64(p2id)
    if (p1) then p1.rpgr.currentjournals = p1.rpgr.currentjournals - 1 end
    p2.rpgr.currentjournals = p2.rpgr.currentjournals + 1
    e.bookdata.owner = p2id

    net.Start("RPGR_update_book_owner")
    net.WriteUInt(e:EntIndex(), 14)
    net.WriteString(e.bookdata.owner)
    net.Broadcast()
end)

--[[
    Sent by a client (admin) after updating cvars in the panel
]]--
net.Receive("RPGR_push_config", function(len, ply)
    local pt = net.ReadTable()
    GetConVar("rpgr_maxbooks"):SetInt(pt.maxbooks)
    GetConVar("rpgr_maxjournals"):SetInt(pt.maxjournals)
    GetConVar("rpgr_maxstickynotes"):SetInt(pt.maxsnotes)
    GetConVar("rpgr_adminignore"):SetInt(pt.adminignore)
    GetConVar("rpgr_allowbookdupes"):SetInt(pt.allowdupes)
    GetConVar("rpgr_allowsnotereuse"):SetInt(pt.allowreusesnotes)
    GetConVar("rpgr_allowdesc"):SetInt(pt.allowdesc)
    GetConVar("rpgr_descchatflag"):SetString(pt.descflag)
end)

net.Receive("RPGR_publish", function (len, ply)
    local i = net.ReadUInt(14)
    local e = Entity(i)
    local result = saveToFile(e)

    if (result) then
        netNotify(ply, 2, "Published to server.")
    else
        netNotify(ply, 1, "A problem occurred while publishing.")
    end
end)

net.Receive("RPGR_request_pbooks", function (len, ply)
    -- get the client's requested book and make them an entity
    local path = net.ReadString()
    local trace = ply:GetEyeTrace()

    if(ply) then 
        ply.rpgr.currentbooks = ply.rpgr.currentbooks + 1
        if (ply.rpgr.currentbooks > GetConVar("rpgr_maxbooks"):GetInt()) and not ((ply:IsAdmin() and GetConVar("rpgr_adminignore"):GetBool())) then
            netNotify(ply, 1, "Hit max number of books!")
            ply.rpgr.currentbooks = ply.rpgr.currentbooks - 1
            return nil
        else
            local SpawnPos = trace.HitPos + trace.HitNormal * 16
            
            local ent = ents.Create( "rpgr_published_book" )
            ent:SetPos( SpawnPos )
            ent:Spawn() -- Calls Ent:Initialize()
            ent:Activate()
            
            ply.rpgr.mybooks[ent:EntIndex()] = "Spawn"
            
            loadFromFile(path, ply, ent)
            ent.bookdata.owner = ply:SteamID64()

            cleanup.Add(ply, "RPGRBooks", ent)
            undo.Create("Book")
            undo.AddEntity(ent)
            undo.SetPlayer(ply)
            undo.Finish()
            return ent
        end
    end
end)
