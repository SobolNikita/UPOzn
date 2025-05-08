program Sobol_Nikita;

{$APPTYPE CONSOLE}

uses
  SysUtils, DateUtils, windows;

type
  TEmployee = record
    Code: Integer;
    Name: string[50];
    Position: string[30];
    HoursPerDay: Integer;
    ManagerCode: Integer;
  end;

  TProject = record
    ProjectName: string[50];
    Task: string[255];
    Code: integer;
    EmployeeCode: Integer;
    ManagerCode: Integer;
    IssueDate: TDate;
    Deadline: TDate;
  end;

  PEmployeeNode = ^TEmployeeNode;
  TEmployeeNode = record
    Data: TEmployee;
    Next: PEmployeeNode;
  end;

  PProjectNode = ^TProjectNode;
  TProjectNode = record
    Data: TProject;
    Next: PProjectNode;
  end;

  TEmployeeSortField = (esfCode, esfName, esfPosition, esfHours, esfManagerCode);
  TSortDirection = (sdAscending, sdDescending);
  TProjectSortField = (psfName, psfEmployeeCode, psfManagerCode, psfIssueDate, psfDeadline);


var
  EmployeesHead: PEmployeeNode = nil;
  ProjectsHead: PProjectNode = nil;
  empCode, projCode: integer;

procedure ClearScreen;
var
  hConsole: THandle;
  cursorPos: TCoord;
begin
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  Write(#27'[2J'#27'[3J');
  cursorPos.X := 0;
  cursorPos.Y := 0;
  SetConsoleCursorPosition(hConsole, cursorPos);
end;


function ReadDate(Prompt: string = ''): TDateTime;
var
  s: string;
  date: TDateTime;
  isCorrect: boolean;
begin
  s := '';
  isCorrect := true;
  repeat
    if not isCorrect then
      Writeln('�������� ������. ��������.');
    Write(Prompt, '(��.��.����): ');
    Readln(S);
    isCorrect := false;
  until TryStrToDate(S, Date);
  Result := Date;
end;

function ReadInt: integer;
var
  s: string[255];
  res: integer;
  isCorrect: boolean;
begin
  isCorrect := true;
  repeat
    if not isCorrect then
      Write('������ �����. ���������: ');
    Readln(s);
    isCorrect := false;
  until (Length(s) > 0) and (TryStrToInt(string(s), res));
  Result := res;
end;

function ReadStr: string;
var
  str: string;
  secondIter: boolean;
begin
  secondIter := false;
  repeat
    if secondIter then
    begin
      writeln('������ ������ ��������� �� ����� ������ �������, ��������� �� �������!');
      write('��������� ����: ');
    end;
    readln(str);
    str := trim(str);
    secondIter := true;
  until (Length(str) > 0);
  Result := str;
end;

//Clear memory

procedure ClearEmployees(var Head: PEmployeeNode);
var
  current, temp: PEmployeeNode;
begin
  current := Head;
  while current <> nil do
  begin
    temp := current;
    current := current^.Next;
    Dispose(temp);
  end;
  Head := nil;
end;

procedure ClearProjects(var Head: PProjectNode);
var
  current, temp: PProjectNode;
begin
  current := Head;
  while current <> nil do
  begin
    temp := current;
    current := current^.Next;
    Dispose(temp);
  end;
  Head := nil;
end;


//Files

procedure LoadData(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode;
                  var empCode: integer);
var
  FEmployees: file of TEmployee;
  FProjects: file of TProject;
  emp: TEmployee;
  proj: TProject;
  NewNodeEmp: PEmployeeNode;
  NewNodeProj: PProjectNode;
  haveData: boolean;
begin
  clearScreen;
  haveData := FileExists('employees.TEmployee') and FileExists('projects.TProject');

  // Loading employees
  if haveData then
  begin
    empCode := 1;
    AssignFile(FEmployees, 'employees.TEmployee');
    Reset(FEmployees);
    while not Eof(FEmployees) do
    begin
      Read(FEmployees, Emp);
      if Emp.Code + 1 > empCode then
        empCode := Emp.Code + 1;
      New(NewNodeEmp);
      NewNodeEmp^.Data := emp;
      NewNodeEmp^.Next := EmployeesHead;
      EmployeesHead := NewNodeEmp;
    end;
    CloseFile(FEmployees);
  end;

  // Loading projects
  if haveData then
  begin
    projCode := 1;
    AssignFile(FProjects, 'projects.TProject');
    Reset(FProjects);
    while not Eof(FProjects) do
    begin
      Read(FProjects, Proj);
      if Proj.Code + 1 > projCode then
        projCode := Proj.Code + 1;
      New(NewNodeProj);
      NewNodeProj^.Data := proj;
      NewNodeProj^.Next := ProjectsHead;
      ProjectsHead := NewNodeProj;
    end;
    CloseFile(FProjects);
  end;
  if haveData then
    Writeln('������ ���������. ������� Enter ��� �����������...')
  else
    writeln('������ ��������. ��������� ������ �� ����������. ������� Enter ��� �����������...');
  Readln;
end;

procedure SaveData(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode);
var
  currentEmp: PEmployeeNode;
  currentProj: PProjectNode;
  FEmployees: file of TEmployee;
  FProjects: file of TProject;
begin
  // Save employees
  AssignFile(FEmployees, 'employees.TEmployee');
  Rewrite(FEmployees);
  currentEmp := EmployeesHead;
  while currentEmp <> nil do
  begin
    Write(FEmployees, currentEmp^.Data);
    currentEmp := currentEmp^.Next;
  end;
  CloseFile(FEmployees);

  // Save projects
  AssignFile(FProjects, 'projects.TProject');
  Rewrite(FProjects);
  currentProj := ProjectsHead;
  while currentProj <> nil do
  begin
    Write(FProjects, currentProj^.Data);
    currentProj := currentProj^.Next;
  end;
  CloseFile(FProjects);
  Writeln('������ ���������. ������� Enter...');
  Readln;
end;

// Print data

procedure ViewEmployee(const employee: PEmployeeNode);
begin
  writeln('------------------------------------------------------------------');
  Writeln('���: ', employee^.Data.Code);
  Writeln('���: ', employee^.Data.Name);
  Writeln('���������: ', employee^.Data.Position);
  Writeln('����� � ����: ', employee^.Data.HoursPerDay);
  if employee^.Data.ManagerCode <> -1 then
    Writeln('��� ������������: ', employee^.Data.ManagerCode)
  else
    Writeln('��� ������������ �����������');
  writeln('------------------------------------------------------------------');
  writeln;
end;

procedure ViewEmployees(const EmployeesHead: PEmployeeNode);
var
  current: PEmployeeNode;

begin
  current := EmployeesHead;
  if current = nil then
    writeln('������ ����������� ����');
  while current <> nil do
  begin
    ViewEmployee(current);
    current := current^.Next;
  end;
end;


procedure ViewProject(const project: PProjectNode);
begin
    Writeln('------------------------------------------------------------------');
    Writeln('������: ', project^.Data.ProjectName);
    Writeln('���: ', project^.Data.Code);
    Writeln('������: ', project^.Data.Task);
    Writeln('�����������: ', project^.Data.EmployeeCode);
    Writeln('������������: ', project^.Data.ManagerCode);
    Writeln('���� ������: ', DateToStr(project^.Data.IssueDate));
    Writeln('���� ����������: ', DateToStr(project^.Data.Deadline));
    Writeln('------------------------------------------------------------------');
    Writeln;
end;

procedure ViewProjectFile(const curFile: TextFile; const project: PProjectNode);
begin
    Writeln(curFile, AnsiToUtf8('------------------------------------------------------------------'));
    Writeln(curFile, AnsiToUtf8('������: '), AnsiToUtf8(string(project^.Data.ProjectName)));
    Writeln(curFile, AnsiToUtf8('���: '), AnsiToUtf8(intToStr(project^.Data.Code)));
    Writeln(curFile, '������: ', AnsiToUtf8(string(project^.Data.Task)));
    Writeln(curFile, '�����������: ', AnsiToUtf8(intToStr(project^.Data.EmployeeCode)));
    Writeln(curFile, '������������: ', AnsiToUtf8(intToStr(project^.Data.ManagerCode)));
    Writeln(curFile, '���� ������: ', AnsiToUtf8(DateToStr(project^.Data.IssueDate)));
    Writeln(curFile, '���� ����������: ', AnsiToUtf8(DateToStr(project^.Data.Deadline)));
    Writeln(curFile, '------------------------------------------------------------------');
    Writeln(curFile, '');

end;

procedure ViewProjects(const ProjectsHead: PProjectNode);
var
  current: PProjectNode;
begin
  current := ProjectsHead;
  if current = nil then
    writeln('������ �������� ����');
  while current <> nil do
  begin
    ViewProject(current);
    current := current^.Next;
  end;
end;

// Add data

function genEmpCode(var empCode: integer): integer;
begin
  Result := empCode;
  empCode := empCode + 1;
end;

function genProjCode(var projCode: integer): integer;
begin
  Result := projCode;
  projCode := projCode + 1;
end;

function getEmpByCode(var EmployeesHead: PEmployeeNode; const capt: string;
                      const addValue: integer): integer;
var
  haveCode, secondIter: boolean;
  curEmployee: PEmployeeNode;
begin
  haveCode := false;
  secondIter := false;
  Result := 0;
  while not haveCode do
  begin
    if secondIter then
      Writeln('������. ��������� � ����� ����� �� ������. ��������� ����');
    Write(capt); Result := readInt;
    curEmployee := EmployeesHead;
    if Result = addValue then
      haveCode := true;
    while (not haveCode) and (curEmployee <> nil) do
    begin
      if curEmployee^.Data.Code = Result then
        haveCode := true;
      curEmployee := curEmployee^.Next;
    end;
    secondIter := true;
  end;
end;

function genManagerCode(var EmployeesHead: PEmployeeNode; const capt: string;
                      const empCode: integer): integer;
var
  s: string;
  isCorrect, haveCode: boolean;
  curEmp: PEmployeeNode;
begin
  Result := -1;
  write(capt);
  repeat
    Readln(s);
    s := trim(s);

    isCorrect := true;

    if (Length(s) <> 0) and (not TryStrToInt(s, Result)) then
    begin
      writeln('������ �����. ���������: ');
      isCorrect := false;
    end;
    if isCorrect and (Result = empCode) then
    begin
      isCorrect := false;
      writeln('������. ��������� �� ����� ���� ����������� ������ ����. ��������� ����: ');
    end;

    if isCorrect then
    begin
      if Length(s) = 0 then
        Result := -1
      else
      begin
        curEmp := EmployeesHead;
        haveCode := false;
        while curEmp <> nil do
        begin
          if (curEmp^.Data.code <> empCode) and (curEmp^.Data.code = Result) then
          begin
            haveCode := true;
          end;
          curEmp := curEmp^.Next;
        end;

        if not haveCode then
        begin
          write('������. ��������� � ����� ����� �� ������. ��������� ����: ');
          isCorrect := false;
        end;

      end;

    end;
  until (isCorrect);
end;

procedure AddEmployee(var EmployeesHead: PEmployeeNode; var empCode: integer);
var
  emp: TEmployee;
  newNode: PEmployeeNode;
  secondIter: boolean;
begin
  Writeln('���������� ����������');
  emp.Code := genEmpCode(empCode);//emp.Code := readEmpCode(EmployeesHead);
  writeln('������� ��� ����������: ', emp.Code);
  Write('���: '); emp.Name := ShortString(ReadStr());
  Write('���������: '); emp.Position := ShortString(ReadStr());
  secondIter := false;
  Write('����� � ����: ');
  repeat
    if secondIter then
    begin
      write('������. ����� ������ ���� �� 0 �� 24: ')
    end;
    emp.HoursPerDay := readInt;
    secondIter := true;
  until (emp.HoursPerDay >= 0) and (emp.HoursPerDay <= 24);
  emp.ManagerCode := genManagerCode(EmployeesHead, '��� ������������: ', emp.Code);

  New(newNode);
  newNode^.Data := emp;
  newNode^.Next := EmployeesHead;
  EmployeesHead := newNode;
end;


procedure AddProject(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode; const empCode: integer);
var
  proj: TProject;
  newNode: PProjectNode;
begin

  Writeln('���������� �������');
  proj.Code := genProjCode(projCode);
  writeln('������� ��� �������: ', proj.Code);
  Write('�������� �������: ');
  proj.ProjectName := shortString(ReadStr());
  Write('������: '); proj.Task := ShortString(ReadStr());
  proj.EmployeeCode := getEmpByCode(EmployeesHead, '��� �����������: ', -1);
  proj.ManagerCode := getEmpByCode(EmployeesHead, '��� ������������: ', -1);
  proj.IssueDate := ReadDate('���� ������');
  proj.Deadline := ReadDate('���� ����������');
  while proj.Deadline < proj.IssueDate do
  begin
    writeln('������. ���� ���������� ������ ���� �����, ��� ���� ������. ��������� ����');
    proj.Deadline := ReadDate('���� ����������');
  end;

  New(newNode);
  newNode^.Data := proj;
  newNode^.Next := ProjectsHead;
  ProjectsHead := newNode;
end;


function checkProjUsedCode(const ProjectsHead: PProjectNode; const code: integer): boolean;
var
  curProject: PProjectNode;
begin
  curProject := ProjectsHead;
  Result := false;
  while curProject <> nil do
  begin
    if curProject^.Data.EmployeeCode = code then
      Result := true;
    if curProject^.Data.ManagerCode = code then
      Result := true;
    curProject := curProject^.Next;
  end;
end;

function checkEmpUsedCode(const EmployeesHead: PEmployeeNode; const code: integer): boolean;
var
  curEmp: PEmployeeNode;
begin
  curEmp := EmployeesHead;
  Result := false;
  while curEmp <> nil do
  begin
    if curEmp^.Data.ManagerCode = code then
      Result := true;
    curEmp := curEmp^.Next;
  end;
end;

// Delete data
procedure DeleteEmployeeByCode(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode;
                               const codes: boolean; const can: array of integer);
var
  code, choose, i: integer;
  current, prev: PEmployeeNode;
  found, confirm, inArray: boolean;
begin
  Write('������� ��� ���������� ��� ��������: ');
  code := readInt;

  if codes then
  begin
    inArray := false;
    for i := Low(can) to High(can) do
    begin
      if can[i] = code then
        inArray := true;
    end;
    while not inArray do
    begin
      Writeln('������. ���� ��� ����� �������� ����. ��������� ����');
      Write('������� ��� ���������� ��� ��������: ');
      code := readInt;
      for i := Low(can) to High(can) do
      begin
        if can[i] = code then
          inArray := true;
      end;
    end;
  end;

  current := EmployeesHead;
  prev := nil;
  Found := False;
  confirm := false;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.Code = code then
    begin
      confirm := false;
      writeln('������������� ������� ����� ����������?');
      writeln('1. ��');
      writeln('2. ���');
      choose := ReadInt;
      while (choose > 2) or (choose < 1) do
      begin
        write('�������� ����. ���������: ');
        choose := ReadInt;
      end;

      if checkProjUsedCode(ProjectsHead, code) then
      begin
        writeln('������. ��������� ������������ � ������������ �������');
        choose := 2;
      end
      else if checkEmpUsedCode(EmployeesHead, code) then
      begin
        writeln('������. ��������� �������� ����������� ��� ������ �����������');
        choose := 2;
      end;

      if choose = 1 then
        confirm := true;

      if confirm then
      begin
        if prev = nil then
          EmployeesHead := current^.Next
        else
          prev^.Next := current^.Next;

        Dispose(current);
      end;
      found := True;
    end
    else
    begin
      prev := current;
      current := current^.Next;
    end;
  end;

  if found and confirm then
    Writeln('��������� ������')
  else if found and (not confirm) then
    Writeln('��������')
  else
    Writeln('��������� �� ������');
  Writeln('������� Enter ��� �����������...');
  Readln;
end;

procedure DeleteEmployee(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode);
var
  choice, siz, i: integer;
  current: PEmployeeNode;
  name: string[50];
  codes: array of integer;
begin
  Writeln('=== �������� ���������� ===');

  Writeln('1. �������� �� ���');
  Writeln('2. �������� �� ����');
  Writeln('0. �����');
  Write('��������: ');

  choice := ReadInt;
  case choice of
  0:
    begin

    end;
  1:
    begin
      write('������� ���: ');
      name := ShortString(ReadStr());
      current := EmployeesHead;
      siz := 0;
      while current <> nil do
      begin
        if current^.Data.Name = name then
        begin
          Inc(siz);
          ViewEmployee(current);
        end;
        current := current^.Next;
      end;
      setLength(codes, siz);
      i := Low(codes);

      current := EmployeesHead;
      while current <> nil do
      begin
        if current^.Data.Name = name then
        begin
          codes[i] := current^.Data.Code;
          Inc(i);
        end;
        current := current^.Next;
      end;
      if siz = 0 then
      begin
        writeln('����������� � ����� ������ �� ����������. ������� Enter');
        readln;
      end
      else
      begin
        DeleteEmployeeByCode(EmployeesHead, ProjectsHead, true, codes);
      end;
    end;
  2:
    begin
      DeleteEmployeeByCode(EmployeesHead, ProjectsHead, false, []);
    end;
  else
    begin
      clearScreen;
      DeleteEmployee(EmployeesHead, ProjectsHead);
    end;
  end;
end;

procedure DeleteTaskByCode(var ProjectsHead: PProjectNode;
                           const codes: boolean; const can: array of integer);
var
  code, choose, i: integer;
  current, prev: PProjectNode;
  found, confirm, inArray: boolean;
begin
  Write('������� ��� ������� ��� ��������: ');
  code := readInt;

  if codes then
  begin
    inArray := false;
    for i := Low(can) to High(can) do
    begin
      if can[i] = code then
        inArray := true;
    end;
    while not inArray do
    begin
      Writeln('������. ���� ��� ����� �������� �������. ��������� ����');
      Write('������� ��� ������� ��� ��������: ');
      code := readInt;
      for i := Low(can) to High(can) do
      begin
        if can[i] = code then
          inArray := true;
      end;
    end;
  end;

  current := ProjectsHead;
  prev := nil;
  Found := False;
  confirm := false;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.Code = code then
    begin
      confirm := false;
      writeln('������������� ������� ��� �������?');
      writeln('1. ��');
      writeln('2. ���');
      choose := ReadInt;
      while (choose < 1) or (choose > 2) do
      begin
        write('�������� ����. ���������: ');
        choose := ReadInt;
      end;

      if choose = 1 then
        confirm := true;

      if confirm then
      begin
        if prev = nil then
          ProjectsHead := current^.Next
        else
          prev^.Next := current^.Next;

        Dispose(current);
      end;
      found := True;
    end
    else
    begin
      prev := current;
      current := current^.Next;
    end;
  end;

  if found and confirm then
    Writeln('������� �������')
  else if found and (not confirm) then
    Writeln('��������')
  else
    Writeln('������� �� �������');
  Writeln('������� Enter ��� �����������...');
  Readln;
end;

procedure DeleteProject(var ProjectsHead: PProjectNode);
var
  choice, i, siz: integer;
  current: PProjectNode;
  name: string[50];
  codes: array of integer;
begin
  Writeln('=== �������� ������� ===');

  Writeln('1. �������� �� �������� �������');
  Writeln('2. �������� �� ����');
  Writeln('0. �����');
  Write('��������: ');
  choice := ReadInt;
  case choice of
  0:
    begin

    end;
  1:
    begin
      write('������� �������� �������: ');
      name := ShortString(ReadStr());
      siz := 0;
      current := ProjectsHead;
      while current <> nil do
      begin
        if current^.Data.ProjectName = name then
        begin
          ViewProject(current);
          Inc(siz);
        end;
        current := current^.Next;
      end;
      setLength(codes, siz);
      current := ProjectsHead;
      i := Low(codes);
      while current <> nil do
      begin
        if current^.Data.ProjectName = name then
        begin
          codes[i] := current^.Data.code;
        end;
        current := current^.Next;
      end;
      if siz = 0 then
      begin
        writeln('������� � ��������� ������ �� ����������. ������� Enter');
        readln;
      end
      else
      begin
        DeleteTaskByCode(ProjectsHead, true, codes);
      end;
    end;
  2:
    begin
      DeleteTaskByCode(ProjectsHead, false, []);
    end;
  else
    begin
      clearScreen;
      DeleteProject(ProjectsHead);
    end;
  end;
end;

procedure DeleteData(var EmployeesHead: PEmployeeNode; var ProjectssHead: PProjectNode);
var
  choice: integer;
begin
  Writeln('=== �������� ������ ===');

  Writeln('1. �������� �����������');
  Writeln('2. �������� ��������');
  Writeln('0. �����');
  Write('��������: ');
  choice := readInt;
  case choice of
    0:
      begin

      end;
    1:
      begin
        clearScreen;
        DeleteEmployee(EmployeesHead, ProjectssHead);
      end;
    2:
      begin
        clearScreen;
        DeleteProject(ProjectssHead);
      end;
    else
      begin
        clearScreen;
        DeleteData(EmployeesHead, ProjectssHead);
      end;

  end;
end;

// Edit data
procedure EditEmployeeById(var EmployeesHead: PEmployeeNode;
                           const codes: boolean; const can: array of integer);
var
  code, choice, i: integer;
  current: PEmployeeNode;
  Found, waschange, secondIter, inArray: boolean;
begin
  Write('������� ��� ����������, �������� ���������� ��������: ');
  code := ReadInt;

  if codes then
  begin
    inArray := false;
    for i := Low(can) to High(can) do
    begin
      if can[i] = code then
        inArray := true;
    end;
    while not inArray do
    begin
      Writeln('������. ���� ��� ����� �������� �����������. ��������� ����');
      Write('������� ��� ����������, �������� ���������� ��������: ');
      code := readInt;
      for i := Low(can) to High(can) do
      begin
        if can[i] = code then
          inArray := true;
      end;
    end;
  end;

  current := EmployeesHead;
  Found := False;
  waschange := false;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.Code = code then
    begin
      clearScreen;
      writeln('������� ����� ���������, ������� ����� ��������');
      writeln('1. ���');
      writeln('2. ���������');
      writeln('3. ����� � ����');
      writeln('4. ��� ������������');
      writeln('0. �����');
      choice := ReadInt;

      case choice of
        0:
          begin

          end;
        1:
          begin
            Write('����� ���: ');
            current^.Data.Name := ShortString(ReadStr());
            waschange := true;
          end;
        2:
          begin
            Write('����� ���������: ');
            current^.Data.Position := ShortString(ReadStr());
            waschange := true;
          end;
        3:
          begin
            Write('����� �������� ���������� ������� ����� � ����: ');
            secondIter := false;
            repeat
              if secondIter then
              begin
                write('������. ����� ������ ���� �� 0 �� 24: ')
              end;
              current^.Data.HoursPerDay := readInt;
              secondIter := true;
            until (current^.Data.HoursPerDay >= 0) and (current^.Data.HoursPerDay <= 24);
            waschange := true;
          end;
        4:
          begin
            current^.Data.ManagerCode := genManagerCode(EmployeesHead, '����� ��� ������������: ', current^.Data.code);
            waschange := true;
          end;
        else
          begin
            writeln('������ �������� �������. �����');
          end;
      end;
      Found := true;
    end
    else
    begin
      current := current^.next;
    end;
  end;

  if found then
    if wasChange then
      Writeln('������ ���������� ��������')
    else
      Writeln('������ ���������� �� ���� ��������')
  else
    Writeln('��������� �� ������');
end;

procedure EditEmployee(var EmployeesHead: PEmployeeNode);
var
  i, siz: integer;
  current: PEmployeeNode;
  choice: integer;
  name: string[50];
  codes: array of integer;
begin

  Writeln('1. �������������� �� ���');
  Writeln('2. �������������� �� ����');
  Writeln('0. �����');
  Write('��������: ');
  choice := ReadInt;

  while (choice < 0) or (choice > 2) do
  begin
    write('�������� ����, ���������: ');
    choice := ReadInt;
  end;

  if choice <> 0 then
  begin
    if choice = 1 then
    begin
      write('������� ���: ');
      name := ShortString(ReadStr());
      current := EmployeesHead;
      siz := 0;
      while current <> nil do
      begin
        if current^.Data.Name = name then
        begin
          ViewEmployee(current);
          Inc(siz);
        end;
        current := current^.Next;
      end;
      setLength(codes, siz);
      i := Low(codes);
      while current <> nil do
      begin
        if current^.Data.Name = name then
        begin
          codes[i] := current^.Data.code;
          Inc(i);
        end;
        current := current^.Next;
      end;
      EditEmployeeById(EmployeesHead, true, codes);
    end
    else
    begin
      EditEmployeeById(EmployeesHead, false, []);
    end;
    Writeln('������� Enter ��� �����������...');
    Readln;
  end;
end;

procedure EditProjectByCode(var ProjectsHead: PProjectNode;
                            const codes: boolean; const can: array of integer);
var
  code, choice, i: integer;
  current: PProjectNode;
  Found, waschange, inArray: boolean;
begin
  Write('������� ��� �������, ������� ���������� ��������: ');
  code := ReadInt;

  if codes then
  begin
    inArray := false;
    for i := Low(can) to High(can) do
    begin
      if can[i] = code then
        inArray := true;
    end;
    while not inArray do
    begin
      Writeln('������. ���� ��� ����� �������� �������. ��������� ����');
      Write('������� ��� �������, �������� ���������� ��������: ');
      code := readInt;
      for i := Low(can) to High(can) do
      begin
        if can[i] = code then
          inArray := true;
      end;
    end;
  end;

  current := ProjectsHead;
  Found := False;
  waschange := false;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.Code = code then
    begin
      clearScreen;
      writeln('������� ����� ���������, ������� ����� ��������');
      writeln('1. ��������');
      writeln('2. ������');
      writeln('3. �����������');
      writeln('4. ������������');
      writeln('5. ���� ������');
      writeln('6. ���� ����������');
      writeln('0. �����');
      choice := ReadInt;
      case choice of
        0:
          begin

          end;
        1:
          begin
            Write('����� �������� �������: ');

            current^.Data.ProjectName := shortString(ReadStr());
            //current^.Data.ProjectName := shortString(getProjName(ProjectsHead));
            wasChange := true;
          end;
        2:
          begin
            Write('����� ������: ');
            current^.Data.Task := ShortString(ReadStr());
            wasChange := true;
          end;
        3:
          begin
            current^.Data.EmployeeCode := getEmpByCode(EmployeesHead, '����� ��� �����������: ', -1);
            wasChange := true;
          end;
        4:
          begin
            current^.Data.EmployeeCode := getEmpByCode(EmployeesHead, '����� ��� ������������: ', -1);
            wasChange := true;
          end;
        5:
          begin
            current^.Data.IssueDate := ReadDate('����� ���� ������: ');
            while current^.Data.IssueDate > current^.Data.Deadline do
            begin
              writeln('������. ���� ������ ������ ���� ������, ��� ���� ����������');
              current^.Data.IssueDate := ReadDate('����� ���� ������: ');
            end;

            wasChange := true;
          end;
        6:
          begin
            current^.Data.Deadline := ReadDate('����� ���� ����������: ');

            while current^.Data.IssueDate > current^.Data.Deadline do
            begin
              writeln('������. ���� ������ ������ ���� ������, ��� ���� ����������');
              current^.Data.Deadline := ReadDate('����� ���� ����������: ');
            end;
            wasChange := true;
          end;
        else
          begin
            writeln('������ �������� �������. �����');
          end;
      end;
      Found := true;
    end
    else
    begin
      current := current^.next;
    end;
  end;

  if found then
    if wasChange then
      Writeln('������ ������')
    else
      Writeln('������ �� ��� ������')
  else
    Writeln('������ �� ������');
  Writeln('������� Enter ��� �����������...');
  Readln;
end;

procedure EditProject(var ProjectsHead: PProjectNode);
var
  name: string[50];
  current: PProjectNode;
  choice, siz, i: integer;
  codes: array of integer;
begin

  Writeln('1. �������������� �� �������� �������');
  Writeln('2. �������������� �� ����');
  Writeln('0. �����');
  Write('��������: ');

  choice := ReadInt;
  while (choice < 0) or (choice > 2) do
  begin
    write('�������� ����. ���������: ');
    choice := ReadInt;
  end;
  if choice <> 0 then
  begin
    if choice = 1 then
    begin
      write('������� �������� �������: ');
      name := ShortString(ReadStr());
      current := ProjectsHead;
      siz := 0;
      while current <> nil do
      begin
        if current^.Data.ProjectName = name then
        begin
          ViewProject(current);
          Inc(siz);
        end;
        current := current^.Next;
      end;
      setLength(codes, siz);
      i := Low(codes);
      current := ProjectsHead;
      while current <> nil do
      begin
        if current^.Data.ProjectName = name then
        begin
          codes[i] := current^.Data.code;
        end;
        current := current^.Next;
      end;
      EditProjectByCode(ProjectsHead, true, codes);
    end
    else
    begin
      EditProjectByCode(ProjectsHead, false, []);
    end;
  end;
end;

procedure EditData(var EmployeesHead: PEmployeeNode; var ProjectssHead: PProjectNode);
var
  choice: integer;
begin
  Writeln('=== �������������� ������ ===');

  Writeln('1. �������������� �����������');
  Writeln('2. �������������� ��������');
  Writeln('0. �����');
  Write('��������: ');
  choice := readInt;
  case choice of
    0:
      begin

      end;
    1:
      begin
        clearScreen;
        EditEmployee(EmployeesHead);
      end;
    2:
      begin
        clearScreen;
        EditProject(ProjectssHead);
      end;
    else
      begin
        clearScreen;
        EditData(EmployeesHead, ProjectssHead);
      end;
  end;
end;

// Special func

procedure SpecialFunctions(const ProjectsHead: PProjectNode);
var
  Choice: Integer;
  ProjectName: string[255];
  CurrentDate: TDate;
  CurrentProj: PProjectNode;
  OutputFile: TextFile;
  HasData: Boolean;
  ProjectsEmpty: Boolean;
begin
  Writeln('1. ������ ����� �� �������');
  Writeln('2. ������ � ��������� ������ (�����)');
  Writeln('0. �����');
  Write('�������� �������: ');
  Choice := readInt;
  while (Choice < 0) or (Choice > 2) do
  begin
    write('�������� ����. ���������: ');
    Choice := readInt;
  end;

  if Choice = 1 then
  begin
    ProjectsEmpty := (ProjectsHead = nil);
    AssignFile(OutputFile, 'project_tasks.txt');
    Rewrite(OutputFile);

    if not ProjectsEmpty then
    begin
      Write('������� �������� �������: ');
      ProjectName := ShortString(ReadStr());
      HasData := False;
      CurrentProj := ProjectsHead;
      while (CurrentProj <> nil) do
      begin
        if CurrentProj^.Data.ProjectName = ProjectName then
        begin
          if not HasData then
          begin
            writeln('-------------------------------------------------------');
            writeln(OutputFile, AnsiToUtf8('-------------------------------------------------------'));
            writeln('������ �� ������� ', ProjectName, ':');
            writeln(OutputFile, AnsiToUtf8('������ �� ������� '),
                     AnsiToUtf8(string(ProjectName)), AnsiToUtf8(':'));
          end;

          Writeln('������: ', CurrentProj^.Data.Task, ', ��� �����������: ',
          CurrentProj^.Data.EmployeeCode, ', ��� ������������: ',
          CurrentProj^.Data.ManagerCode);

          Writeln(OutputFile, AnsiToUtf8('������: '), AnsiToUtf8(string(CurrentProj^.Data.Task)),
          AnsiToUtf8(', ��� �����������: '), AnsiToUtf8(string(intToStr(CurrentProj^.Data.EmployeeCode))),
          AnsiToUtf8(', ��� ������������: '), AnsiToUtf8(string(intToStr(CurrentProj^.Data.ManagerCode))));

          //ViewProject(CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
      begin
        writeln(OutputFile, AnsiToUtf8('������ �� ������'));
        Writeln('������ �� ������');
      end
      else
      begin
        writeln('-------------------------------------------------------');
        writeln(OutputFile, AnsiToUtf8('-------------------------------------------------------'));
      end;
    end
    else
    begin
      Writeln('������ �������� ����!');
      Writeln(OutputFile, AnsiToUtf8('������ �������� ����!'));
    end;
    CloseFile(OutputFile);
  end
  else if Choice = 2 then
  begin
    ProjectsEmpty := (ProjectsHead = nil);
    AssignFile(OutputFile, 'urgent_tasks.txt');
    Rewrite(OutputFile);

    if not ProjectsEmpty then
    begin
      CurrentDate := Date();
      HasData := False;
      CurrentProj := ProjectsHead;
      while CurrentProj <> nil do
      begin
        if DaysBetween(CurrentDate, CurrentProj^.Data.Deadline) <= 30 then
        begin
          ViewProject(CurrentProj);
          ViewProjectFile(OutputFile, CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
      begin
        Writeln('��� ����� � ��������� ������');
        Writeln(OutputFile, AnsiToUtf8('��� ����� � ��������� ������'));
      end;

    end
    else
    begin
      Writeln('������ �������� ����!');
      Writeln(OutputFile, AnsiToUtf8('������ �������� ����!'));
    end;

    CloseFile(OutputFile);
  end;

  if (Choice = 1) or (Choice = 2) then
  begin
    Write('������� Enter...');
    Readln;
  end;
end;


// Exit

procedure exitConfirm(var quit: boolean);
var
  Choice: integer;
begin
  writeln('������������� ������ ����� ��� ����������?');
  Writeln('1. ��');
  Writeln('2. ���');
  Writeln('0. �����');
  Write('��������: ');
  Choice := readInt;
  while (Choice < 0) or (Choice > 2) do
  begin
    writeln('������ �����. ���������: ');
    Choice := readInt;
  end;
  if Choice = 1 then
  begin
    quit := true;
  end;
end;


// Find

procedure SearchEmployees(var EmployeesHead: PEmployeeNode;
                          Field: TEmployeeSortField; const Value: string);
var
  Current: PEmployeeNode;
  Found: Boolean;
  SearchCode: Integer;
  Quit: boolean;
begin
  Current := EmployeesHead;
  Found := False;
  Quit := false;

  case Field of
    esfCode, esfHours, esfManagerCode:
      if not TryStrToInt(Value, SearchCode) then
      begin
        Writeln('������������ ������ �����. ������� Enter');
        readln;
        Quit := true;
      end;
  end;
  if not quit then
  begin
    while Current <> nil do
    begin
      case Field of
        esfCode:
          if Current^.Data.Code = SearchCode then
          begin
            ViewEmployee(Current);
            Found := True;
          end;

        esfName:
          if LowerCase(Value) = LowerCase(string(Current^.Data.Name)) then
          begin
            ViewEmployee(Current);
            Found := True;
          end;

        esfPosition:
          if LowerCase(Value) = LowerCase(string(Current^.Data.Position)) then
          begin
            ViewEmployee(Current);
            Found := True;
          end;

        esfHours:
          if Current^.Data.HoursPerDay = SearchCode then
          begin
            ViewEmployee(Current);
            Found := True;
          end;

        esfManagerCode:
          if Current^.Data.ManagerCode = SearchCode then
          begin
            ViewEmployee(Current);
            Found := True;
          end;
      end;
      Current := Current^.Next;
    end;

    if not Found then
      Writeln('���������� �� �������');
  end;
end;


procedure SearchProjects(var ProjectsHead: PProjectNode;
                        Field: TProjectSortField; const Value: string);
var
  Current: PProjectNode;
  Found: Boolean;
  SearchCode: Integer;
  SearchDate: TDateTime;
  Quit: boolean;
begin
  Current := ProjectsHead;
  Found := False;
  Quit := false;

  case Field of
    psfEmployeeCode, psfManagerCode:
      if not TryStrToInt(Value, SearchCode) then
      begin
        Writeln('������������ ������ �����. ������� Enter');
        readln;
        Quit := true;
      end;

    psfIssueDate, psfDeadline:
      if not TryStrToDate(Value, SearchDate) then
      begin
        Writeln('������������ ������ ����');
        Quit := true;
      end;
  end;
  if not Quit then
  begin
    while Current <> nil do
    begin
      case Field of
        psfName:
          if LowerCase(Value) = LowerCase(string(Current^.Data.ProjectName)) then
          begin
            ViewProject(Current);
            Found := True;
          end;

        psfEmployeeCode:
          if Current^.Data.EmployeeCode = SearchCode then
          begin
            ViewProject(Current);
            Found := True;
          end;

        psfManagerCode:
          if Current^.Data.ManagerCode = SearchCode then
          begin
            ViewProject(Current);
            Found := True;
          end;

        psfIssueDate:
          if Current^.Data.IssueDate = SearchDate then
          begin
            ViewProject(Current);
            Found := True;
          end;

        psfDeadline:
          if Current^.Data.Deadline = SearchDate then
          begin
            ViewProject(Current);
            Found := True;
          end;
      end;
      Current := Current^.Next;
    end;

    if not Found then
      Writeln('������� �� �������');
  end;
end;

// Sort

procedure SortEmployees(var EmployeesHead: PEmployeeNode;
                        Field: TEmployeeSortField; Direction: TSortDirection);
var
  Current, NextNode, prevNode, temp: PEmployeeNode;
  Swapped: Boolean;
begin
  if EmployeesHead <> nil then
  begin
    repeat
      Swapped := False;
      Current := EmployeesHead;
      NextNode := Current^.Next;
      prevNode := nil;

      while NextNode <> nil do
      begin
        var CompareResult: Integer;
        case Field of
          esfCode:
            CompareResult := Current^.Data.Code - NextNode^.Data.Code;
          esfName:
            CompareResult := CompareText(string(Current^.Data.Name), string(NextNode^.Data.Name));
          esfPosition:
            CompareResult := CompareText(string(Current^.Data.Position), string(NextNode^.Data.Position));
          esfHours:
            CompareResult := Current^.Data.HoursPerDay - NextNode^.Data.HoursPerDay;
          esfManagerCode:
            CompareResult := Current^.Data.ManagerCode - NextNode^.Data.ManagerCode;
          else
            CompareResult := 0;
        end;

        if Direction = sdDescending then
          CompareResult := -CompareResult;

        if CompareResult > 0 then
        begin
          if prevNode <> nil then
            prevNode^.Next := NextNode
          else
            EmployeesHead := NextNode;

          Current^.Next := NextNode^.Next;
          NextNode^.Next := Current;
          temp := Current;
          Current := NextNode;
          NextNode := temp;
          Swapped := true;

        end;
        prevNode := Current;
        Current := NextNode;
        NextNode := NextNode^.Next;
      end;
    until not Swapped;
  end;
end;


procedure SortProjects(var ProjectsHead: PProjectNode;
                      Field: TProjectSortField; Direction: TSortDirection);
var
  Current, NextNode, prevNode, temp: PProjectNode;
  Swapped: Boolean;
  CompareResult: Integer;
begin
  if ProjectsHead <> nil then
  begin
    repeat
      Swapped := False;
      Current := ProjectsHead;
      NextNode := Current^.Next;
      prevNode := nil;
      while NextNode <> nil do
      begin
        case Field of
          psfName:
            CompareResult := CompareText(string(Current^.Data.ProjectName), string(NextNode^.Data.ProjectName));
          psfEmployeeCode:
            CompareResult := Current^.Data.EmployeeCode - NextNode^.Data.EmployeeCode;
          psfManagerCode:
            CompareResult := Current^.Data.ManagerCode - NextNode^.Data.ManagerCode;
          psfIssueDate:
            CompareResult := CompareDate(Current^.Data.IssueDate, NextNode^.Data.IssueDate);
          psfDeadline:
            CompareResult := CompareDate(Current^.Data.Deadline, NextNode^.Data.Deadline);
          else
            CompareResult := 0;
        end;

        if Direction = sdDescending then
          CompareResult := -CompareResult;

        if CompareResult > 0 then
        begin
          if prevNode <> nil then
            prevNode^.Next := NextNode
          else
            ProjectsHead := NextNode;

          Current^.Next := NextNode^.Next;
          NextNode^.Next := Current;
          temp := Current;
          Current := NextNode;
          NextNode := temp;
          Swapped := true;
        end;

        prevNode := Current;
        Current := NextNode;
        NextNode := NextNode^.Next;
      end;
    until not Swapped;
  end;
end;

// Menu

procedure SortMenu(var ProjectsHead: PProjectNode; var EmployeesHead: PEmployeeNode);
var
  SortField: Integer;
  Direction: Integer;
begin
  ClearScreen;
  Writeln('=== ���������� ������ ===');

  Writeln('1. ����������');
  Writeln('2. �������');
  Writeln('0. �����');
  Write('�������� ������: ');
  SortField := readInt;
  while (SortField < 0) or (SortField > 2) do
  begin
    write('�������� ������. ���������: ');
    SortField := readInt;
  end;
  ClearScreen;
  Writeln('����������� ����������:');
  Writeln('1. �� �����������');
  Writeln('2. �� ��������');
  Write('�������� �����������: ');
  Direction := readInt;
  while (Direction < 1) or (Direction > 2) do
  begin
    write('�������� ������. ���������: ');
    Direction := readInt;
  end;

  ClearScreen;
  if SortField = 1 then
  begin
    Writeln('��������� ���������� �����������:');
    Writeln('1. ��� ����������');
    Writeln('2. ���');
    Writeln('3. ���������');
    Writeln('4. ������� ����');
    Writeln('5. ��� ������������');
    Write('�������� ��������: ');
    SortField := readInt;
    while (SortField < 1) or (SortField > 5) do
    begin
      write('�������� ������. ���������: ');
      SortField := readInt;
    end;
    SortEmployees(
      EmployeesHead,
      TEmployeeSortField(SortField - 1),
      TSortDirection(Direction - 1)
    );
  end
  else if SortField = 2 then
  begin
    Writeln('��������� ���������� ��������:');
    Writeln('1. �������� �������');
    Writeln('2. ��� �����������');
    Writeln('3. ��� ������������');
    Writeln('4. ���� ������');
    Writeln('5. ���� ����������');
    Write('�������� ��������: ');
    SortField := readInt;
    while (SortField < 1) or (SortField > 5) do
    begin
      write('�������� ������. ���������: ');
      SortField := readInt;
    end;
    SortProjects(
      ProjectsHead,
      TProjectSortField(SortField - 1),
      TSortDirection(Direction - 1)
    );
  end;
  clearScreen;
  Writeln('���������� ���������');
  Write('������� Enter...');
  Readln;
end;

procedure SearchMenu(var ProjectsHead: PProjectNode; var EmployeesHead: PEmployeeNode);
var
  Choice, SubChoice: Integer;
  SearchValue: string;
begin
  ClearScreen;
  Writeln('=== ����� ������ ===');

  Writeln('1. ����� �����������');
  Writeln('2. ����� ��������');
  Writeln('3. �����');
  Write('��������: ');
  Choice := readInt;
  while (Choice < 1) or (Choice > 3) do
  begin
    write('�������� ������. ���������: ');
    Choice := readInt;
  end;
  if Choice <> 3 then
  begin
    ClearScreen;
    if Choice = 1 then
    begin
      Writeln('��������� ������:');
      Writeln('1. �� ���� ����������');
      Writeln('2. �� ���');
      Writeln('3. �� ���������');
      Writeln('4. �� ������� �����');
      Writeln('5. �� ���� ������������');
      Write('�������� ��������: ');
      SubChoice := readInt;
      while (SubChoice < 1) or (SubChoice > 5) do
      begin
        write('�������� ������. ���������: ');
        SubChoice := readInt;
      end;

      Write('������� �������� ��� ������: ');
      if (SubChoice = 1) or (SubChoice = 4) or (SubChoice = 5) then
      begin
        SearchValue := intToStr(ReadInt);
        if SubChoice = 4 then
          while (strToInt(SearchValue) > 24)  or (strToInt(SearchValue) < 0) do
          begin
            write('������. �������� ������ ���� �� 0 �� 24');
            SearchValue := intToStr(ReadInt);
          end;

      end

      else
        SearchValue := ReadStr;

      SearchEmployees(EmployeesHead, TEmployeeSortField(SubChoice - 1), SearchValue);

    end
    else if Choice = 2 then
    begin
      Writeln('��������� ������:');
      Writeln('1. �� �������� �������');
      Writeln('2. �� ���� �����������');
      Writeln('3. �� ���� ������������');
      Writeln('4. �� ���� ������');
      Writeln('5. �� ����� ����������');
      Write('�������� ��������: ');
      SubChoice := readInt;
      while (SubChoice < 1) or (SubChoice > 5) do
      begin
        write('�������� ������. ���������: ');
        SubChoice := readInt;
      end;
      Write('������� �������� ��� ������: ');

      if (SubChoice = 2) or (SubChoice = 3) then
        SearchValue := intToStr(ReadInt)
      else if SubChoice = 1 then
        SearchValue := ReadStr
      else
        SearchValue := DateToStr(ReadDate);

      SearchProjects(ProjectsHead, TProjectSortField(SubChoice - 1), SearchValue);
    end;

    Write('������� Enter ��� �����������...');
    Readln;
  end;
end;

procedure SubMenu(const Title: string; var Choice: Integer);
begin
  ClearScreen;
  Writeln(Title);
  Writeln('1. ����������');
  Writeln('2. �������');
  Writeln('0. �����');
  Write('��������: ');
  Choice := readInt;
  while (Choice < 0) or (Choice > 2) do
  begin
    write('�������� ������. ���������: ');
    Choice := readInt;
  end;
end;

procedure ShowMenu(EmployeesHead: PEmployeeNode;
                    ProjectsHead: PProjectNode; var empCode: integer);
var
  Choice, SubChoice: Integer;
  quit, wasLoad: boolean;
begin
  wasLoad := false;
  quit := false;
  repeat
    ClearScreen;
    Writeln('1. ������ ������');
    Writeln('2. �������� ������');
    Writeln('3. ����������');
    Writeln('4. �����');
    Writeln('5. ����������');
    Writeln('6. ��������');
    Writeln('7. ��������������');
    Writeln('8. ������ ����� �� ������� / ������ � ��������� ������ (�����)');
    Writeln('9. ����� ��� ����������');
    Writeln('10. ����� � �����������');
    Write('�������� �����: ');
    Choice := readInt;

    case Choice of
      1:
      begin
        if wasLoad then
        begin
          clearScreen;
          writeln('������. ������ ��� ���� ���������!');
          writeln('������� Enter ��� �����������');
          readln;
        end
        else
        begin
          LoadData(EmployeesHead, ProjectsHead, empCode);
          wasLoad := true;
        end;
      end;
      2:
        begin
          SubMenu('�������� ������', SubChoice);
          clearScreen;
          case SubChoice of
            1:
              begin
                ViewEmployees(EmployeesHead);
                Write('������� Enter...'); Readln;
              end;
            2:
              begin
                ViewProjects(ProjectsHead);
                Write('������� Enter...'); Readln;
              end;
            else
              begin
                writeln('�������� �������. ������� Enter ��� ������');
                readln;
              end;
          end;
        end;
      3: SortMenu(ProjectsHead, EmployeesHead);
      4: SearchMenu(ProjectsHead, EmployeesHead);
      5:
        begin
          SubMenu('���������� ������', SubChoice);
          case SubChoice of
            0:
              begin

              end;
            1:
              begin
                AddEmployee(EmployeesHead, empCode);
                writeln('������ ������� ���������! ������� Enter...');
                readln;
              end;
            2:
              begin
                AddProject(EmployeesHead, ProjectsHead, empCode);
                writeln('������ ������� ���������! ������� Enter...');
                readln;
              end;
            else
              begin
                writeln('������ �������� �������. ������� Enter...');
                readln;
              end;
          end;


        end;
      6:
        begin
          ClearScreen;
          DeleteData(EmployeesHead, ProjectsHead);
        end;
      7:
        begin
          ClearScreen;
          EditData(EmployeesHead, ProjectsHead);
        end;
      8:
        begin
          ClearScreen;
          SpecialFunctions(ProjectsHead);
        end;
      9:
        begin
          ClearScreen;
          exitConfirm(quit);
        end;
      10:
        begin
          SaveData(EmployeesHead, ProjectsHead);
          quit := true;
        end;
    end;
  until quit;
end;

begin
  empCode := 1;
  projCode := 1;
  ShowMenu(EmployeesHead, ProjectsHead, empCode);
  ClearEmployees(EmployeesHead);
  ClearProjects(ProjectsHead);
end.
