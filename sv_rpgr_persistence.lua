if SERVER then
    util.AddNetworkString("RPGR_update_bookdata")
    util.AddNetworkString("RPGR_SendBookList")
    util.AddNetworkString("RPGR_DeleteBook")
    util.AddNetworkString("RPGR_ChangeBookModel")
    util.AddNetworkString("RPGR_TeleportBook")
    util.AddNetworkString("RPGR_ChangeBookAuthor")
    util.AddNetworkString("RPGR_BackupSave")
    util.AddNetworkString("RPGR_ListBackups")
    util.AddNetworkString("RPGR_SendBackups")
    util.AddNetworkString("RPGR_RestoreBackup")
    util.AddNetworkString("RPGR_ExportBook")
    util.AddNetworkString("RPGR_DeleteBackup")
    util.AddNetworkString("RPGR_RenameBackup")
    util.AddNetworkString("RPGR_RemoteEditRequest")
    util.AddNetworkString("RPGR_RemoteEditData")
    util.AddNetworkString("RPGR_RemoteEditSubmit")
end

--  ―――――――――――――――――――――――――――――――――――
--  Création du dossier de save  & définition de GetSavePath
local saveDir = "rpgr_booksaves"
local function GetSavePath()
    return saveDir .. "/" .. game.GetMap() .. ".json"
end

if SERVER and not file.IsDir(saveDir, "DATA") then
    file.CreateDir(saveDir)
end



-- hook.Add("Initialize", "RPGR_DefineChatCommands", function()
--     if not DarkRP or not DarkRP.defineChatCommand then return end

--     DarkRP.defineChatCommand("listbooks", function(ply, args)
--         if not ply:IsAdmin() then return "" end

--         local js  = file.Read(GetSavePath(), "DATA") or "[]"
--         local tbl = util.JSONToTable(js) or {}

--         net.Start("RPGR_SendBookList")
--           net.WriteTable(tbl)
--         net.Send(ply)

--         ply:ChatPrint("Voici la liste des livres.")
--         return ""
--     end)
-- end)





-- serialize an rpgr entity
local function SerializeEnt(ent)
    return {
        class       = ent:GetClass(),
        pos         = ent:GetPos(),
        ang         = ent:GetAngles(),
        title       = ent.bookdata.title    or "",
        text        = ent.bookdata.text     or "",
        style       = ent.bookdata.style    or "",
        author      = ent.bookdata.author   or "",
        owner       = ent.bookdata.owner    or "",
        description = ent.description       or "",
        model       = ent:GetModel()
    }
end

-- spawn from saved data
local function SpawnEnt(data)
    local ent = ents.Create(data.class)
    if not IsValid(ent) then return end

    ent:SetPos(data.pos)
    ent:SetAngles(data.ang)
    ent:Spawn()
    ent:Activate()

    -- ← changement ici
    if data.model and util.IsValidModel(data.model) then
        timer.Simple(0, function()
            if not IsValid(ent) then return end
    
            ent:SetModel(data.model)
    
            -- ré-initialise le corps physique pour correspondre au nouveau modèle
            ent:PhysicsInit(SOLID_VPHYSICS)
            ent:SetMoveType(MOVETYPE_VPHYSICS)
            ent:SetSolid(SOLID_VPHYSICS)
    
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetMass(5) -- tu peux ajuster la masse si besoin
            end
        end)
    end

    -- restore fields
    ent.bookdata = {
        title  = data.title,
        text   = data.text,
        style  = data.style,
        author = data.author,
        owner  = data.owner
    }
    ent.description = data.description

    -- notify clients to refresh
    net.Start("RPGR_update_bookdata")
      net.WriteEntity(ent)
      net.WriteTable(ent.bookdata)
      net.WriteString(ent.description)
    net.Broadcast()
end


-- load all on map start
hook.Add("InitPostEntity","RPGR_LoadSaves",function()
    local js = file.Read(GetSavePath(),"DATA")
    if not js then return end
    local tbl = util.JSONToTable(js) or {}
    -- remove existing to avoid dupes
    for _,cls in ipairs({"rpgr_book","rpgr_journal","rpgr_stickynote"}) do
        for _,e in ipairs(ents.FindByClass(cls)) do e:Remove() end
    end
    -- respawn saved
    for _,data in ipairs(tbl) do
        SpawnEnt(data)
    end
    SaveAll()
end)

function SaveAll()
    local out = {}
     for _,cls in ipairs({"rpgr_book","rpgr_journal","rpgr_stickynote"}) do
         for _,e in ipairs(ents.FindByClass(cls)) do
             table.insert(out, SerializeEnt(e))
         end
     end
    -- on réécrit toujours, même si out=={}
    file.Write(GetSavePath(), util.TableToJSON(out,true))
 end

timer.Create("RPGR_AutoSave",60,0,SaveAll)
hook.Add("OnEntityCreated","RPGR_SaveOnCreate",function(e)
    if e:GetClass():match("^rpgr_") then timer.Simple(1, SaveAll) end
end)

hook.Add("PlayerCleanup", "RPGR_RestoreAfterCleanup", function(ply, cleanupType)
    -- délai mini pour laisser GMod finir son cleanup
    timer.Simple(1, function()
        hook.Run("InitPostEntity")
    end)
end)

hook.Add("PostCleanupMap", "RPGR_RestoreAfterCleanup2", function()
    timer.Simple(1, function()
        hook.Run("InitPostEntity")
    end)
end)




net.Receive("RPGR_DeleteBook", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local id = net.ReadInt(16)
    local js = file.Read(GetSavePath(),"DATA")
    local tbl = util.JSONToTable(js) or {}

    if tbl[id] then
        -- supprime l’entité en jeu
        for _, e in ipairs(ents.FindByClass(tbl[id].class)) do
            if e:GetPos() == tbl[id].pos and e:GetAngles() == tbl[id].ang then
                e:Remove()
            end
        end

        -- supprime du JSON et réécrit
        table.remove(tbl, id)
        file.Write(GetSavePath(), util.TableToJSON(tbl, true))
    end
end)

-- handle model change
net.Receive("RPGR_ChangeBookModel", function(len, ply)
    if not ply:IsAdmin() then return end
    local id = net.ReadInt(16)
    local model = net.ReadString()

    local js = file.Read(GetSavePath(), "DATA")
    local tbl = util.JSONToTable(js) or {}

    if tbl[id] then
        tbl[id].model = model
        file.Write(GetSavePath(), util.TableToJSON(tbl, true))

        -- Met à jour l'entité en jeu si elle existe
        for _, e in ipairs(ents.FindByClass(tbl[id].class)) do
            if e:GetPos() == tbl[id].pos and e:GetAngles() == tbl[id].ang then
                if util.IsValidModel(model) then
                    e:SetModel(model)
                end
            end
        end
    end
end)

-- Téléporter le joueur vers le livre sélectionné
net.Receive("RPGR_TeleportBook", function(len, ply)
    if not ply:IsAdmin() then return end
    local id = net.ReadInt(16)
    local js = file.Read(GetSavePath(), "DATA")
    local tbl = util.JSONToTable(js) or {}
    local data = tbl[id]
    if data then
        -- téléporte un peu au-dessus pour ne pas tomber à travers
        local tp = data.pos + Vector(0,0,50)
        ply:SetPos(tp)
    end
end)

-- Changer l'auteur dans le JSON et en jeu
net.Receive("RPGR_ChangeBookAuthor", function(len, ply)
    if not ply:IsAdmin() then return end
    local id = net.ReadInt(16)
    local newAuthor = net.ReadString()
    local js = file.Read(GetSavePath(), "DATA")
    local tbl = util.JSONToTable(js) or {}
    local data = tbl[id]
    if data then
        data.author = newAuthor
        file.Write(GetSavePath(), util.TableToJSON(tbl,true))
        -- applique en live
        for _, e in ipairs(ents.FindByClass(data.class)) do
            if e:GetPos()==data.pos and e:GetAngles()==data.ang then
                e.bookdata.author = newAuthor
                break
            end
        end
    end
end)

concommand.Add("reloadbooks", function(ply, cmd, args)
    if not game.IsDedicated() then return end
    print("[RPGR] Reloading books from disk...")
    
    -- Supprimer les anciens livres existants
    for _, ent in ipairs(ents.FindByClass("rpgr_book")) do
        ent:Remove()
    end

    -- Re-spawn à partir du fichier de sauvegarde
    local js = file.Read(GetSavePath(), "DATA") or "[]"
    local tbl = util.JSONToTable(js) or {}

    for _, data in ipairs(tbl) do
        SpawnEnt(data)
    end
end)

net.Receive("RPGR_BackupSave", function(len, ply)
    if not ply:IsAdmin() then return end

    local path = GetSavePath()
    if not file.Exists(path, "DATA") then return end

    -- lire l'ancien JSON
    local data = file.Read(path, "DATA")

    -- construire un nom de backup avec horodatage
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupName = string.format("%s_%s.json", game.GetMap(), timestamp)
    local backupPath = saveDir.."/"..backupName

    -- écrire la copie
    file.Write(backupPath, data)

    -- notifier l’admin
    ply:ChatPrint("Backup créé : "..backupName)
end)

net.Receive("RPGR_ListBackups", function(len, ply)
    if not ply:IsAdmin() then return end
    local files = file.Find(saveDir.."/*.json", "DATA")
    net.Start("RPGR_SendBackups")
    net.WriteTable(files)
    net.Send(ply)
end)

net.Receive("RPGR_RestoreBackup", function(len, ply)
    if not ply:IsAdmin() then return end
    local name = net.ReadString()
    local src = saveDir.."/"..name
    local dst = GetSavePath()
    if file.Exists(src, "DATA") then
        local data = file.Read(src, "DATA")
        file.Write(dst, data)
        ply:ChatPrint("Backup restauré : "..name)
    end
end)

-- Export book to .txt
net.Receive("RPGR_ExportBook", function(len, ply)
    if not ply:IsAdmin() then return end
    local id = net.ReadInt(16)
    local tbl = util.JSONToTable(file.Read(GetSavePath(),"DATA") or "[]") or {}
    local d = tbl[id]
    if d then
        local fname = string.format("%s_book%d_%s.txt", game.GetMap(), id, os.date("%Y%m%d_%H%M%S"))
        local txt = ("Title: %s\nAuthor: %s\n\n%s"):format(d.title, d.author, d.text)
        file.Write(saveDir.."/"..fname, txt)
        ply:ChatPrint("Exporté : "..fname)
    end
end)

-- Supprimer un backup
net.Receive("RPGR_DeleteBackup", function(len, ply)
    if not ply:IsAdmin() then return end
    local name = net.ReadString()
    file.Delete(saveDir.."/"..name)
    ply:ChatPrint("Backup supprimé : "..name)
end)

-- Renommer un backup
net.Receive("RPGR_RenameBackup", function(len, ply)
    if not ply:IsAdmin() then return end
    local oldName = net.ReadString()
    local newName = net.ReadString()
    file.Rename(saveDir.."/"..oldName, saveDir.."/"..newName)
    ply:ChatPrint("Backup renommé : "..newName)




end)

net.Receive("RPGR_RemoteEditRequest", function(len, ply)
    if not ply:IsAdmin() then return end
    local id = net.ReadInt(16)
    local tbl = util.JSONToTable(file.Read(GetSavePath(),"DATA") or "[]") or {}
    local d = tbl[id]
    if not d then return end
    -- Envoie les données du livre au client
    net.Start("RPGR_RemoteEditData")
    net.WriteInt(id,16)
    net.WriteTable(d)
    net.Send(ply)
end)

net.Receive("RPGR_RemoteEditSubmit", function(len, ply)
    if not ply:IsAdmin() then return end
    local id = net.ReadInt(16)
    local newData = net.ReadTable()    -- { title=text, text=text, style=text, author=text, description=text, model=text }
    local tbl = util.JSONToTable(file.Read(GetSavePath(),"DATA") or "[]") or {}
    if not tbl[id] then return end
    -- Met à jour la table et réécrit le JSON
    for k,v in pairs(newData) do tbl[id][k] = v end
    file.Write(GetSavePath(), util.TableToJSON(tbl,true))
    -- Met à jour l’entité en jeu
    for _,e in ipairs(ents.FindByClass(tbl[id].class)) do
        if e:GetPos()==tbl[id].pos and e:GetAngles()==tbl[id].ang then
            e.bookdata.title       = tbl[id].title
            e.bookdata.text        = tbl[id].text
            e.bookdata.style       = tbl[id].style
            e.bookdata.author      = tbl[id].author
            e.description          = tbl[id].description
            if tbl[id].model and util.IsValidModel(tbl[id].model) then
                e:SetModel(tbl[id].model)
            end
            break
        end
    end
end)


net.Receive("RPGR_update_book", function(len, ply)
    local i = net.ReadUInt(14)
    local e = Entity(i)
    if not IsValid(e) then return end
    if not e.bookdata then e.bookdata = {} end

    e.bookdata.title = net.ReadString()
    e.bookdata.text  = net.ReadString()
    e.bookdata.style = net.ReadString()
    e.description    = net.ReadString()

    -- 🔧 Met à jour la table mémoire (mais ne sauvegarde PAS encore le fichier)
    local js = file.Read(GetSavePath(), "DATA")
    local tbl = util.JSONToTable(js) or {}

    for idx, data in ipairs(tbl) do
        if data.class == e:GetClass() and data.pos == e:GetPos() and data.ang == e:GetAngles() then
            data.title = e.bookdata.title
            data.text  = e.bookdata.text
            data.style = e.bookdata.style
            data.description = e.description
        end
    end

    -- rebroadcast
    net.Start("RPGR_update_book")
    net.WriteUInt(e:EntIndex(), 14)
    net.Broadcast()
end)


-- garde fou de l'autre fou
-- timer.Simple(0, function()
--     if GAMEMODE then
--         -- assure que la table PlayerSayHooks existe
--         if not istable(GAMEMODE.PlayerSayHooks) then
--             GAMEMODE.PlayerSayHooks = { All = {}, Team = {} }
--         else
--             GAMEMODE.PlayerSayHooks.All  = GAMEMODE.PlayerSayHooks.All  or {}
--             GAMEMODE.PlayerSayHooks.Team = GAMEMODE.PlayerSayHooks.Team or {}
--         end
--     end

--     -- assure que hook.GetTable().PlayerSay existe
--     local ht = hook.GetTable()
--     if ht and not ht.PlayerSay then
--         ht.PlayerSay = {}
--     end
-- end)


-- → LE VRAI !listbooks QUI MARCHE (version allégée)
timer.Simple(0, function()
    if GAMEMODE and not istable(GAMEMODE.PlayerSayHooks) then
        GAMEMODE.PlayerSayHooks = { All = {}, Team = {} }
    end
end)

-- ► Définit la commande DarkRP “/listbooks” qui déclenche notre commande interne
hook.Add("Initialize", "RPGR_DefineListBooksCmd", function()
    if not DarkRP or not DarkRP.defineChatCommand then return end

    DarkRP.defineChatCommand("listbooks", function(ply, args)
        if not IsValid(ply) or not ply:IsAdmin() then return "" end
        -- On invoque notre concommand serveur pour envoyer la vraie liste
        ply:ConCommand("rpgr_listbooks_internal")
        return ""
    end)
end)

-- ► Commande interne qui lit le JSON et envoie la liste épurée au client
concommand.Add("rpgr_listbooks_internal", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local js   = file.Read(GetSavePath(), "DATA") or "[]"
    local data = util.JSONToTable(js) or {}

    -- Ne renvoie que les champs id/class/title pour éviter les nil dans WriteInt
    local list = {}
    for id, d in ipairs(data) do
        list[#list+1] = {
            id    = id,
            class = d.class or "",
            title = d.title or ""
        }
    end

    net.Start("RPGR_SendBookList")
      net.WriteTable(list)
    net.Send(ply)
end)
