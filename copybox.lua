-- CopyBox (dim) v1 : plugin for Micro Editor v.1.x
--  * select Start & End text selection points by keys..
--  * save/restore text selection to/from file..
--  * execute text selection or the current line as Bash script..

VERSION = "1.1"

-- >>: global vals
copy_x, copy_y = 0, 0
copy_set = false
selection = ""


function Fname()
  local nm = GetOption( "copybox_filename" )

  if nm == nil then
    nm = "/tmp/copybox.out"
  end

  return nm
end


function Set()
  local v = CurView()
  local c = v.Cursor

  if( copy_set or v.Buf.Cursor:HasSelection() ) then
    copy_set = false
    End()
  else
    copy_set = true
    copy_x, copy_y = c.Loc.X, c.Loc.Y
    messenger:Message( "Set CopyBox start point.." )
  end
end


function End()
  local v = CurView()
  local c = v.Cursor

  if v.Buf.Cursor:HasSelection() then
    copy_x = v.Buf.Cursor.CurSelection[1].X
    copy_y = v.Buf.Cursor.CurSelection[1].Y
  end

  c:SetSelectionStart( Loc( copy_x, copy_y) )
  c:SetSelectionEnd( Loc( c.Loc.X, c.Loc.Y ) )
  selection = c:GetSelection()
  messenger:Message( "Saved CopyBox selection.." )
end


function Paste()
  local v = CurView()
  local c = v.Cursor
  local b = Loc( c.Loc.X, c.Loc.Y )

  if v.Buf.Cursor:HasSelection() then
    selection = c:GetSelection()
  end

  v.Buf:Replace( b, b, selection )
  messenger:Message( "Pasted CopyBox selection.." )
end


function Load()
  local v = CurView()
  local c = v.Cursor
  local b = Loc( c.Loc.X, c.Loc.Y )

  local fname = Fname()
  messenger:Message( "Loading CopyBox from file: " .. fname )
  local fp = assert( io.open( fname, "r") )
  selection = fp:read( "*all" )
  fp:close()

  v.Buf:Replace( b, b, selection )
end


function SaveToFile( shell )
  local v = CurView()
  local c = v.Cursor

  if v.Buf.Cursor:HasSelection() then
    selection = c:GetSelection()
  else
    selection = v.Buf:Line( c.Loc.Y )
  end

  if( selection ~= "" ) then
    local fname = Fname(v)
    os.remove( fname )
    local fp = assert( io.open( fname, "w") )

    if( shell ) then
      fp:write( "cat << EOF-Shell\n" )
      fp:write( "\n------------------------------------------------------------------------\n bash $ " )
      fp:write( selection )
      fp:write( "\n------------------------------------------------------------------------\n" )
      fp:write( "\nEOF-Shell\n" )
    end

    fp:write( selection )
    fp:write( "\n" )
    fp:close()

    return fname
  end

  return ""
end


function Save()
  local fname = SaveToFile( false )

  if fname ~= "" then
    messenger:Message( "Saved CopyBox to file: " .. fname )
  end
end


function Exec()
  local fname = SaveToFile( true )
  RunInteractiveShell(  "bash " .. fname, true, false )
  SaveToFile( false )
end


-- >>: Commands
MakeCommand( "copy_set"   , "copybox.Set"   )
MakeCommand( "copy_paste" , "copybox.Paste" )
MakeCommand( "copy_exec"  , "copybox.Exec"  )
MakeCommand( "copy_save"  , "copybox.Save"  )
MakeCommand( "copy_load"  , "copybox.Load"  )

-- >>: Keys
BindKey( "F3" , "copybox.Set"   )
BindKey( "F4" , "copybox.Save"  )
BindKey( "F5" , "copybox.Paste" )
BindKey( "F6" , "copybox.Load"  )
BindKey( "F9" , "copybox.Exec"  )
