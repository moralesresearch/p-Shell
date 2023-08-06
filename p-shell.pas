{$mode objfpc}{$H+}{$J-} // Just use this line in all modern sources
program pShell;

uses SysUtils, Crt;

const
  Version = '3.3.1'; // Set the shell version number here
  ShellName = 'p-Shell'; // Set the shell name here
  MaxPathLength = 255;
  MaxCommandLength = 50;

var
  CurrentPath: string;
  Command: string;
  CommandParams: array [1..5] of string;
  NumParams: Integer;

procedure DisplayCompatibilityWarning;
begin
  WriteLn('Warning: The current command is not supported in older versions of ', ShellName);
  WriteLn('Please consider upgrading to the latest version (', Version, ') to use all features.');
  WriteLn;
end;

procedure DisplayCopyrightNotice;
begin
  WriteLn(ShellName, ' v', Version);
  WriteLn;
  WriteLn('(C) 1979 Apple Inc. All rights reserved.');
  WriteLn('(C) 2023 Morales Research Inc. All rights reserved.');
  WriteLn;
end;

function GetScreenWidth: Integer;
begin
  // On Linux, we cannot get the screen width directly.
  // You may implement a cross-platform solution using Crt unit.
  // For this demonstration, we'll return a default value.
  Result := 80;
end;

procedure Initialize;
begin
  CurrentPath := '/';
end;

procedure ParseCommand;
var
  CommandStr: string;
  ParamCount: Integer;
begin
  Write('': (GetScreenWidth - Length(ShellName + ' v' + Version)) div 2);
  WriteLn(ShellName, ' v', Version); // Display centered version and name

  Write(ShellName, ' v', Version, ' >> '); // Display version and name
  ReadLn(CommandStr);

  ParamCount := 0;
  while Length(CommandStr) > 0 do
  begin
    Inc(ParamCount);
    CommandParams[ParamCount] := Trim(ExtractWord(1, CommandStr, [' ']));
  end;

  Command := CommandParams[1];
  NumParams := ParamCount - 1;
end;

procedure DisplayVersion;
begin
  WriteLn('Shell Name: ', ShellName);
  WriteLn('Shell Version: ', Version);
  // Display the copyright notice when "version" command is executed
  DisplayCopyrightNotice;
  {$IFDEF MSWINDOWS}
    WriteLn('Operating System: Windows');
  {$ELSE}
    WriteLn('Operating System: Unix'); // Since this is a Unix-compatible p-Shell
  {$ENDIF}
end;

procedure ExecuteCommand;
begin
  case Command of
    'cd': ChangeDirectory;
    'ls': ListDirectory;
    'copy': CopyFile;
    'cat': DisplayFileContents;
    'shutdown': ShutdownSystem;
    'reboot': RebootSystem;
    'logout': Logout;
    'version': DisplayVersion;
    'tree': DisplayFileTree;
    'memchk': MemoryCheck;
    'clear': ClearScreen;
    'pascal': ExecutePascalInterpreter;
    'exit': Exit; // Command to exit back to the p-Shell
  else
    begin
      // Check for older versions before executing certain commands
      if (Command = 'grep') or (Command = 'diskcopy') then
        DisplayCompatibilityWarning
      else
        WriteLn('Command not recognized: ', Command);
    end;
  end;
end;

procedure ChangeDirectory;
begin
  if NumParams >= 1 then
  begin
    if DirectoryExists(CommandParams[1]) then
    begin
      CurrentPath := IncludeTrailingPathDelimiter(CommandParams[1]);
    end
    else
    begin
      WriteLn('Directory not found: ', CommandParams[1]);
    end;
  end
  else
  begin
    WriteLn('Usage: cd <directory>');
  end;
end;

procedure ListDirectory;
var
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  FindResult := FindFirst(CurrentPath + '*', faAnyFile, SearchRec);
  if FindResult = 0 then
  begin
    repeat
      WriteLn(SearchRec.Name);
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

procedure CopyFile;
begin
  if NumParams >= 2 then
  begin
    if FileExists(CommandParams[1]) then
    begin
      if not FileExists(CommandParams[2]) then
      begin
        FileCopy(CommandParams[1], CommandParams[2]);
        WriteLn('File copied successfully.');
      end
      else
      begin
        WriteLn('Destination file already exists: ', CommandParams[2]);
      end;
    end
    else
    begin
      WriteLn('Source file not found: ', CommandParams[1]);
    end;
  end
  else
  begin
    WriteLn('Usage: copy <source> <destination>');
  end;
end;

procedure DisplayFileContents;
var
  FileHandle: TextFile;
  Line: string;
begin
  if NumParams >= 1 then
  begin
    if FileExists(CommandParams[1]) then
    begin
      Assign(FileHandle, CommandParams[1]);
      Reset(FileHandle);
      while not Eof(FileHandle) do
      begin
        ReadLn(FileHandle, Line);
        WriteLn(Line);
      end;
      Close(FileHandle);
    end
    else
    begin
      WriteLn('File not found: ', CommandParams[1]);
    end;
  end
  else
  begin
    WriteLn('Usage: cat <file>');
  end;
end;

procedure SearchFileContents;
var
  FileHandle: TextFile;
  Line: string;
  SearchPattern: string;
begin
  if NumParams >= 2 then
  begin
    SearchPattern := CommandParams[1];
    if FileExists(CommandParams[2]) then
    begin
      Assign(FileHandle, CommandParams[2]);
      Reset(FileHandle);
      while not Eof(FileHandle) do
      begin
        ReadLn(FileHandle, Line);
        if Pos(SearchPattern, Line) > 0 then
        begin
          WriteLn(Line);
        end;
      end;
      Close(FileHandle);
    end
    else
    begin
      WriteLn('File not found: ', CommandParams[2]);
    end;
  end
  else
  begin
    WriteLn('Usage: grep <search pattern> <file>');
  end;
end;

procedure ShutdownSystem;
begin
  {$IFDEF MSWINDOWS}
    WriteLn('Shutting down Windows system...');
    // Use the appropriate OS command or API to shutdown the Windows system
  {$ELSE}
    WriteLn('Shutting down Unix system...');
    // Use the appropriate Unix OS command or API to shutdown the system
    {$IFDEF UNIX}
      SysUtils.ExecuteProcess('/sbin/shutdown', '-h now', []);
    {$ELSE}
      WriteLn('Shutdown command is not supported in this OS.');
    {$ENDIF}
  {$ENDIF}
end;

procedure RebootSystem;
begin
  {$IFDEF MSWINDOWS}
    WriteLn('Rebooting Windows system...');
    // Use the appropriate OS command or API to reboot the Windows system
  {$ELSE}
    WriteLn('Rebooting Unix system...');
    // Use the appropriate Unix OS command or API to reboot the system
    {$IFDEF UNIX}
      SysUtils.ExecuteProcess('/sbin/reboot', '', []);
    {$ELSE}
      WriteLn('Reboot command is not supported in this OS.');
    {$ENDIF}
  {$ENDIF}
end;

procedure Logout;
begin
  {$IFDEF MSWINDOWS}
    WriteLn('Logging out from Windows...');
    // Implement user logout logic here if applicable for Windows
  {$ELSE}
    WriteLn('Logging out from Unix...');
    // Use the appropriate Unix OS command or API to logout the user
    {$IFDEF UNIX}
      SysUtils.ExecuteProcess('/usr/bin/logout', '', []);
    {$ELSE}
      WriteLn('Logout command is not supported in this OS.');
    {$ENDIF}
  {$ENDIF}
end;

procedure DisplayFileTree;
begin
  {$IFDEF MSWINDOWS}
    WriteLn('Displaying file tree is not supported in Windows.');
  {$ELSE}
    WriteLn('Displaying file tree in Unix...');
    // Use the appropriate Unix OS command or API to display the file tree
    {$IFDEF UNIX}
      SysUtils.ExecuteProcess('/usr/bin/tree', CurrentPath, []);
    {$ELSE}
      WriteLn('Displaying file tree command is not supported in this OS.');
    {$ENDIF}
  {$ENDIF}
end;

procedure MemoryCheck;
begin
  {$IFDEF MSWINDOWS}
    WriteLn('Checking memory usage in Windows...');
    // Use the appropriate OS command or API to check memory usage in Windows
  {$ELSE}
    WriteLn('Checking memory usage in Unix...');
    // Use the appropriate Unix OS command or API to check memory usage
    {$IFDEF UNIX}
      SysUtils.ExecuteProcess('/usr/bin/free', '-h', []);
    {$ELSE}
      WriteLn('Memory check command is not supported in this OS.');
    {$ENDIF}
  {$ENDIF}
end;

procedure ClearScreen;
begin
  // Implement the clear screen command here
  ClrScr;
end;

procedure DiskCopy;
begin
  {$IFDEF MSWINDOWS}
    WriteLn('Disk copy is not supported in Windows.');
  {$ELSE}
    WriteLn('Copying disks in Unix...');
    // Use the appropriate Unix OS command or API to perform disk copying
    {$IFDEF UNIX}
      if NumParams >= 2 then
      begin
        SysUtils.ExecuteProcess('/bin/dd', 'if=' + CommandParams[1] + ' of=' + CommandParams[2], []);
      end
      else
      begin
        WriteLn('Usage: diskcopy <source> <destination>');
      end;
    {$ELSE}
      WriteLn('Disk copy command is not supported in this OS.');
    {$ENDIF}
  {$ENDIF}
end;

procedure ExecutePascalInterpreter;
var
  PascalCode: TStringList;
  TempPascalFile: string;
  ExecutionResult: Integer;
begin
  PascalCode := TStringList.Create;
  try
    WriteLn('Enter your Pascal code. Type "##" on a new line and press Enter to finish:');
    repeat
      PascalCode.Add(ReadLn);
    until PascalCode[PascalCode.Count - 1] = '##';

    TempPascalFile := GetCurrentDir + PathDelim + 'temp.pas';
    PascalCode.SaveToFile(TempPascalFile);

    WriteLn('Executing ', PascalInterpreterName, ' v', PascalInterpreterVersion, '...');
    ExecutionResult := SysUtils.ExecuteProcess('/usr/bin/fpc', TempPascalFile, []);
    if ExecutionResult = 0 then
    begin
      WriteLn(PascalInterpreterName, ' v', PascalInterpreterVersion, ': Pascal code executed successfully.');
      SysUtils.ExecuteProcess('./temp', '', []); // Execute the compiled program
    end
    else
    begin
      WriteLn(PascalInterpreterName, ' v', PascalInterpreterVersion, ': Pascal code execution failed.');
    end;

    PascalCode.Clear;
    DeleteFile(TempPascalFile);
  finally
    PascalCode.Free;
  end;
end;

begin
  ClrScr;
  DisplayCopyrightNotice; // Display copyright notice at startup
  Initialize;

  while True do
  begin
    ParseCommand;
    if Command = 'exit' then
      Break
    else if Command = 'version' then
    begin
      DisplayVersion; // Execute DisplayVersion procedure for the "version" command
    end
    else
      ExecuteCommand;
  end;

  WriteLn('Exiting ', ShellName);
end.