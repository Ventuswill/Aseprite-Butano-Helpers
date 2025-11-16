function init(plugin)
    plugin:newMenuSeparator{
        group="edit_insert"
    }
    plugin:newMenuGroup{
        id="gba",
        title="GBA",
        --TODO: some groups seem to fail to display the new group, for example main_menu.
        --Find out if this bug is on my end, Aseprite's end, or intentional behaviour.
        --They've had an issue open since August but nobody's responded yet: https://github.com/aseprite/aseprite/issues/5379
        group="edit_insert"
    }

    --Saves the last export path, or defaults to the Aseprite path
    if plugin.preferences.default == nil then
        plugin.preferences.default = app.fs.currentPath
    end


    --Usage: Add new tiles underneath the current ones. Currently they're blank tiles.
    --TODO: "Tile to fill with" section should fill the new tiles with a previous tile
        --TODO: Display showing which tile is being copied
    --TODO: Error handling for when image has bad dimensions
    plugin:newCommand{
        id="addtiletosheet",
        title="Add Tile to Sheet",
        group="gba",
        onclick = function()
            local dlg = Dialog { title = "Add Tile to Sheet" }

            dlg:slider {
            	id = "numAdd",
            	label = "Tiles to add:",
            	min = 1,
            	max = 10,
            	value = 1
            }

            dlg:slider {
                id="tileToFill",
                title="Tile to fill with:",
                min=0,
                max = app.sprite.bounds.height/app.sprite.bounds.width,
                value = 0
            }
            
            dlg:button {
            	id = "cancel",
                text = "CANCEL",
                onclick = function()
                    dlg:close()
                end
            }

            
            
            dlg:button {
            	id = "add",
                text = "ADD",
                onclick = function()
                    local w = app.sprite.bounds.width
                    local im = app.image
                    --app.command.CanvasSize { ui=false, bottom=w*dlg.data.numAdd }
                    --if dlg.data.tileToFill > 0 then
                    --    for i = 1,dlg.data.numAdd,1
                    --    im.
                    dlg:close()
                end
            }
            
            dlg:show { wait = false }
        end
    }
    --Usage: Exporting the sprite/tilesheet in addition to its Butano JSON configuration.
    --TODO: literally any error handling
    --TODO: Butano seems to be fussy about capital letters in file names, should auto convert to snake_case
    plugin:newCommand{
        id="exportToButano",
        title="Export to Butano",
        group="gba",
        onclick = function()
            local dlg = Dialog { title = "Export to Butano" }
            local fname = app.sprite.filename

            --Unsaved files have no extension, so we need to make sure there's a match looking for a dot
            if string.match(fname,".*%.") == nil then
                fname = app.sprite.filename..".bmp"
            else
                fname = string.match(fname,".*%.").."bmp"
            end

            dlg:combobox{
                id="exportType",
                label="Export As:",
                options={"Sprite", "Sprite Tiles", "Sprite Palette", "Regular Background", "Affine Background", "Affine Background Tiles", "Background Palette"},
                option="Sprite"
            }
            dlg:file{
                id="exportLoc",
                label="Export Location:",
                --Setting extension to .bmp no matter the original extension
                filename = fname,
                open=false,
                save=true,
                basepath = plugin.preferences.default,
                filetypes={"bmp"}
            }
            dlg:button {
            	id = "cancel",
                text = "CANCEL",
                onclick = function()
                    dlg:close()
                end
            }
            dlg:button {
            	id = "export",
                text = "EXPORT",
                onclick = function()

                    --saving the file location for future exports
                    plugin.preferences.default = string.match(dlg.data.exportLoc, "^.*\\")

                    --let's start with the JSON
                    local json = io.open(string.match(dlg.data.exportLoc,".*%.").."json", "w")
                    json:write("{\n \"type\": ")

                    local sel = dlg.data.exportType
                    if sel == "Sprite" then
                        json:write("\"sprite\"")
                    elseif sel == "Sprite Tiles" then
                        json:write("\"sprite_tiles\"")
                    elseif sel == "Sprite Palette" then
                        json:write("\"sprite_palette\"")
                    elseif sel == "Regular Background" then
                        json:write("\"regular_bg\"")
                    elseif sel == "Affine Background" then
                        json:write("\"affine_bg\"")
                    elseif sel == "Affine Background Tiles" then
                        json:write("\"affine_bg_tiles\"")
                    elseif sel == "Background Palette" then
                        json:write("\"bg_palette\"")
                    else
                        --Todo: Error handling here
                    end

                    json:write(",\n  \"width\": \""..app.sprite.bounds.width.."\"")
                    json:write(",\n  \"height\": \""..app.sprite.bounds.width.."\"")
                    json:write("\n}")
                    json:close()

                    --And drop the .bmp in the same spot
                    app.command.ExportSpriteSheet{
                        ui=false,
                        recent=true,
                        askOverwrite=false,
                        textureFilename=dlg.data.exportLoc
                    }
                end
            }
            dlg:show{ wait = false }
        end
    }
end