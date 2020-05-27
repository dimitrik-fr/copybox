-- CopyBox (dim) v2 : plugin for Micro Editor v2.x
--  * select Start & End text selection points by keys..
--  * save/restore text selection to/from file..
--  * execute text selection or the current line as Bash script..

VERSION = "2.0"

local config = import( "micro/config" )
local buffer = import( "micro/buffer" )
local shell  = import( "micro/shell" )
local micro  = import( "micro" )

-- >>: global vals
copy_x, copy_y = 0, 0
copy_set = false
selection = ""


function Fname( bp )
  local nm = bp.Buf.Settings[ "copybox_filename" ]

  if nm == nil then
    nm = "/tmp/copybox.out"
  end

  return nm
end


function Set( bp, args )
  local c = bp.Cursor

  if( copy_set or c:HasSelection() ) then
    copy_set = false
    End( bp )
  else
    copy_set = true
    copy_x, copy_y = c.X, c.Y
    micro.InfoBar():Message( "Set CopyBox start point.." )
  end
end


function End( bp )
  local c = bp.Cursor

  if c:HasSelection() then
    copy_x = c.CurSelection[1].X
    copy_y = c.CurSelection[1].Y
  end

  c:SetSelectionStart( buffer.Loc( copy_x, copy_y ) )
  c:SetSelectionEnd( buffer.Loc( c.X, c.Y ) )
  selection = c:GetSelection()
  c:Relocate()
  micro.InfoBar():Message( "Saved CopyBox selection.." )
end


function Paste( bp, args )
  local c = bp.Cursor
  local b = buffer.Loc( c.X, c.Y )

  if c:HasSelection() then
    selection = c:GetSelection()
  end

  bp.Buf:Replace( b, b, selection )
  c.X = b.X
  c.Y = b.Y
  c:Relocate()
  c:GetVisualX()
  micro.InfoBar():Message( "Pasted CopyBox selection.." )
end


function Load( bp, args )
  local c = bp.Cursor
  local b = buffer.Loc( c.X, c.Y )

  local fname = Fname( bp )
  micro.InfoBar():Message( "Loading CopyBox from file: " .. fname )
  local fp = assert( io.open( fname, "r" ) )

  selection = fp:read( "*all" )
  fp:close()

  bp.Buf:Replace( b, b, selection )
  c.X = b.X
  c.Y = b.Y
  c:Relocate()
  c:GetVisualX()
end


function SaveToFile( bp, shell )
  local c = bp.Cursor
  local str = ""
  local i = 0

  if c:HasSelection() then
    for i = c.CurSelection[1].Y, c.CurSelection[2].Y-1 do
      str = str .. bp.Buf:Line( i ) .. "\n"
    end

    i = c.CurSelection[2].Y-1 - c.CurSelection[1].Y

    if( c.CurSelection[2].X > 0 ) then
      str = str .. bp.Buf:Line( c.CurSelection[2].Y ) .. "\n"
      i = i + 1
    end
  else
    str = bp.Buf:Line( c.Y ) .. "\n"
  end

  if( str ~= "" ) then
    local fname = Fname( bp )
    os.remove( fname )
    local fp = assert( io.open( fname, "w") )

    if( shell ) then
      fp:write( "cat << EOF-Shell\n" )
      fp:write( "\n------------------------------------------------------------------------\n" )
      fp:write( "$ bash> " )
      if( i > 0 ) then
        fp:write( "\\ \n" )
      end
      fp:write( str )
      fp:write( "------------------------------------------------------------------------\n" )
      fp:write( "\nEOF-Shell\n" )
    end

    fp:write( str )
    fp:close()

    return fname
  end

  return ""
end


function Save( bp, args )
  local fname = SaveToFile( bp, false )

  if fname ~= "" then
    micro.InfoBar():Message( "Saved CopyBox to file: " .. fname )
  end
end


function Exec( bp, args )
  local fname = SaveToFile( bp, true )
  shell.RunInteractiveShell(  "bash " .. fname, true, false )
  SaveToFile( bp, false )
end


function init()
  -- >>: Commands
  config.MakeCommand( "copy_set"   , Set   , config.NoComplete )
  config.MakeCommand( "copy_paste" , Paste , config.NoComplete )
  config.MakeCommand( "copy_exec"  , Exec  , config.NoComplete )
  config.MakeCommand( "copy_save"  , Save  , config.NoComplete )
  config.MakeCommand( "copy_load"  , Load  , config.NoComplete )

  -- >>: Keys
  config.TryBindKey( "F3" , "lua:copybox2.Set"   , false )
  config.TryBindKey( "F4" , "lua:copybox2.Save"  , false )
  config.TryBindKey( "F5" , "lua:copybox2.Paste" , false )
  config.TryBindKey( "F6" , "lua:copybox2.Load"  , false )
  config.TryBindKey( "F9" , "lua:copybox2.Exec"  , false )
end
