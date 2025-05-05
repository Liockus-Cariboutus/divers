-- lua/autorun/client/cl_rpgr_listbooks.lua

net.Receive("RPGR_SendBookList", function()
    local list = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Gestion des livres")
    frame:SetSize(1000, 800)
    frame:Center()
    frame:MakePopup()

    local grid = vgui.Create("DListView", frame)
    grid:Dock(FILL)
    grid:AddColumn("ID")
    grid:AddColumn("Classe")
    grid:AddColumn("Titre")

    for _, b in ipairs(list) do
        grid:AddLine(b.id, b.class, b.title)
    end

    -- BOUTON SUPPRIMER LE LIVRE SÉLECTIONNÉ
    local btnDelete = vgui.Create("DButton", frame)
    btnDelete:Dock(BOTTOM)
    btnDelete:SetText("Supprimer sélection")
    btnDelete.DoClick = function()
        local line = grid:GetSelectedLine()
        if not line then return end

        local id = tonumber(grid:GetLine(line):GetValue(1))
        -- Demande au serveur de supprimer
        net.Start("RPGR_DeleteBook")
        net.WriteInt(id, 16)
        net.SendToServer()

        -- On ferme la fenêtre
        frame:Close()
    end

    local btnModel = vgui.Create("DButton", frame)
    btnModel:Dock(BOTTOM)
    btnModel:SetText("Changer le modèle")
    btnModel.DoClick = function()
        local line = grid:GetSelectedLine()
        if not line then return end
        local id = tonumber(grid:GetLine(line):GetValue(1))

        Derma_StringRequest(
            "Changer le modèle",
            "Entrez le chemin du nouveau modèle .mdl :",
            "",
            function(input)
                net.Start("RPGR_ChangeBookModel")
                    net.WriteInt(id, 16)
                    net.WriteString(input)
                net.SendToServer()
            end,
            nil
        )
    end

    local btnTeleport = vgui.Create("DButton", frame)
    btnTeleport:Dock(BOTTOM)
    btnTeleport:SetText("Téléporter au livre")
    btnTeleport.DoClick = function()
        local line = grid:GetSelectedLine()
        if not line then return end
        local id = tonumber(grid:GetLine(line):GetValue(1))
        net.Start("RPGR_TeleportBook")
        net.WriteInt(id,16)
        net.SendToServer()
        frame:Close()
    end

    local btnAuthor = vgui.Create("DButton", frame)
    btnAuthor:Dock(BOTTOM)
    btnAuthor:SetText("Modifier l'auteur")
    btnAuthor.DoClick = function()
        local line = grid:GetSelectedLine()
        if not line then return end
        local id = tonumber(grid:GetLine(line):GetValue(1))
        Derma_StringRequest(
          "Nouvel auteur",
          "Entrez le nom de l'auteur :",
          "",
          function(input)
            net.Start("RPGR_ChangeBookAuthor")
            net.WriteInt(id,16)
            net.WriteString(input)
            net.SendToServer()
            frame:Close()
          end
        )
    end

    local btnBackup = vgui.Create("DButton", frame)
    btnBackup:Dock(BOTTOM)
    btnBackup:SetText("Créer un backup")
    btnBackup.DoClick = function()
        net.Start("RPGR_BackupSave")
        net.SendToServer()
        frame:Close()
    end   

    local btnListBackups = vgui.Create("DButton", frame)
    btnListBackups:Dock(BOTTOM)
    btnListBackups:SetText("Gérer les backups")
    btnListBackups.DoClick = function()
        -- demande la liste au serveur
        net.Start("RPGR_ListBackups")
        net.SendToServer()
    end

    local btnRemoteEdit = vgui.Create("DButton", frame)
    btnRemoteEdit:Dock(BOTTOM)
    btnRemoteEdit:SetText("Éditer à distance")
    btnRemoteEdit.DoClick = function()
        local line = grid:GetSelectedLine()
        if not line then return end
        local id = tonumber(grid:GetLine(line):GetValue(1))
        net.Start("RPGR_RemoteEditRequest")
        net.WriteInt(id, 16)
        net.SendToServer()
        frame:Close()
    end

    local btnExport = vgui.Create("DButton", frame)
    btnExport:Dock(BOTTOM)
    btnExport:SetText("Exporter en .txt")
    btnExport.DoClick = function()
        local line = grid:GetSelectedLine()
        if not line then return end
        local id = tonumber(grid:GetLine(line):GetValue(1))
        net.Start("RPGR_ExportBook")
        net.WriteInt(id, 16)
        net.SendToServer()
    end


end)



net.Receive("RPGR_SendBackups", function()
    local list = net.ReadTable()
    local f = vgui.Create("DFrame")
    f:SetTitle("Backups disponibles")
    f:SetSize(300, 400)
    f:Center()
    f:MakePopup()

    local lv = vgui.Create("DListView", f)
    lv:Dock(FILL)
    lv:AddColumn("Fichier de backup")
    for _,name in ipairs(list) do
        lv:AddLine(name)
    end

    local btnRestore = vgui.Create("DButton", f)
    btnRestore:Dock(BOTTOM)
    btnRestore:SetText("Restaurer le backup sélectionné")
    btnRestore.DoClick = function()
        local sel = lv:GetSelectedLine()
        if not sel then return end
        local name = lv:GetLine(sel):GetValue(1)
        net.Start("RPGR_RestoreBackup")
        net.WriteString(name)
        net.SendToServer()
        f:Close()
    end

    local btnDel = vgui.Create("DButton", f)
    btnDel:Dock(BOTTOM)
    btnDel:SetText("Supprimer le backup")
    btnDel.DoClick = function()
        local sel = lv:GetSelectedLine()
        if not sel then return end
        local name = lv:GetLine(sel):GetValue(1)
        net.Start("RPGR_DeleteBackup")
        net.WriteString(name)
        net.SendToServer()
        f:Close()
    end
    
    -- Bouton Renommer
    local btnRen = vgui.Create("DButton", f)
    btnRen:Dock(BOTTOM)
    btnRen:SetText("Renommer le backup")
    btnRen.DoClick = function()
        local sel = lv:GetSelectedLine()
        if not sel then return end
        local old = lv:GetLine(sel):GetValue(1)
        Derma_StringRequest(
          "Nouveau nom", "Entrez le nouveau nom (sans .json) :", old:gsub("%.json$",""),
          function(input)
            net.Start("RPGR_RenameBackup")
            net.WriteString(old)
            net.WriteString(input..".json")
            net.SendToServer()
            f:Close()
          end
        )
    end

end)


net.Receive("RPGR_RemoteEditData", function()
    local id = net.ReadInt(16)
    local d  = net.ReadTable()
    -- Ouvre l’éditeur et injecte les valeurs
    editBook({
       bookdata = { title=d.title, text=d.text, style=d.style, author=d.author, owner=d.owner },
       description = { raw = d.description },
       EntIndex = function() return id end
    })
    -- Remplace la fonction de save pour qu’elle utilise RemoteEditSubmit
    rpgr_writerPanel.save.DoClick = function()
        local newData = {
          title       = rpgr_writerPanel.titleEntry:GetValue(),
          text        = rpgr_writerPanel.textEntry:GetValue(),
          style       = rpgr_writerPanel.styleEntry:GetValue(),
          author      = rpgr_writerPanel.titleEntry:GetValue():match("~ par (.+)$") or d.author,
          description = rpgr_writerPanel.descEntry:GetValue()
        }
        net.Start("RPGR_RemoteEditSubmit")
        net.WriteInt(id,16)
        net.WriteTable(newData)
        net.SendToServer()
        rpgr_writerPanel.frame:Close()
    end
end)
