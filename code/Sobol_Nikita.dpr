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


procedure ClearScreen;
var
  cursor: COORD;
  r: cardinal;
begin
  r := 300;
  cursor.X := 0;
  cursor.Y := 0;
  FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', 80 * r, cursor, r);
  SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor);
end;


function ReadDate(Prompt: string = ''): TDateTime;
var
  S: string;
  Date: TDateTime;
  isCorrect: boolean;
begin
  S := '';
  isCorrect := true;
  repeat
    if not isCorrect then
      writeln('�������� ������. ��������: ');
    Write(Prompt, '(��.��.����): ');
    Readln(S);
    isCorrect := false;
  until TryStrToDate(S, Date);
  Result := Date;
end;

//Clear memory

procedure ClearEmployees(var Head: PEmployeeNode);
var
  Current, Temp: PEmployeeNode;
begin
  Current := Head;
  while Current <> nil do
  begin
    Temp := Current;
    Current := Current^.Next;
    Dispose(Temp);
  end;
  Head := nil;
end;

procedure ClearProjects(var Head: PProjectNode);
var
  Current, Temp: PProjectNode;
begin
  Current := Head;
  while Current <> nil do
  begin
    Temp := Current;
    Current := Current^.Next;
    Dispose(Temp);
  end;
  Head := nil;
end;


//Files

procedure LoadData(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode);
var
  FEmployees: file of TEmployee;
  FProjects: file of TProject;
  Emp: TEmployee;
  Proj: TProject;
  NewNodeEmp: PEmployeeNode;
  NewNodeProj: PProjectNode;
begin
  // Loading employees
  if FileExists('employees.TEmployee') then
  begin
    AssignFile(FEmployees, 'employees.TEmployee');
    Reset(FEmployees);
    while not Eof(FEmployees) do
    begin
      Read(FEmployees, Emp);
      New(NewNodeEmp);
      NewNodeEmp^.Data := Emp;
      NewNodeEmp^.Next := EmployeesHead;
      EmployeesHead := NewNodeEmp;
    end;
    CloseFile(FEmployees);
  end;

  // Loading projects
  if FileExists('projects.TProject') then
  begin
    AssignFile(FProjects, 'projects.TProject');
    Reset(FProjects);
    while not Eof(FProjects) do
    begin
      Read(FProjects, Proj);
      New(NewNodeProj);
      NewNodeProj^.Data := Proj;
      NewNodeProj^.Next := ProjectsHead;
      ProjectsHead := NewNodeProj;
    end;
    CloseFile(FProjects);
  end;
  Writeln('������ ���������. ������� ����� ������� ��� �����������...');
  readln;
end;

procedure SaveData(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode);
var
  CurrentEmp: PEmployeeNode;
  CurrentProj: PProjectNode;
  FEmployees: file of TEmployee;
  FProjects: file of TProject;
begin
  // Save employees
  AssignFile(FEmployees, 'employees.TEmployee');
  Rewrite(FEmployees);
  CurrentEmp := EmployeesHead;
  while CurrentEmp <> nil do
  begin
    Write(FEmployees, CurrentEmp^.Data);
    CurrentEmp := CurrentEmp^.Next;
  end;
  CloseFile(FEmployees);

  // Save projects
  AssignFile(FProjects, 'projects.TProject');
  Rewrite(FProjects);
  CurrentProj := ProjectsHead;
  while CurrentProj <> nil do
  begin
    Write(FProjects, CurrentProj^.Data);
    CurrentProj := CurrentProj^.Next;
  end;
  CloseFile(FProjects);
  Writeln('������ ���������. ������� Enter...');
  readln;
end;

// Print data

procedure ViewEmployee(const Employee: PEmployeeNode);
begin
  Writeln('���: ', Employee^.Data.Code);
  Writeln('���: ', Employee^.Data.Name);
  Writeln('���������: ', Employee^.Data.Position);
  Writeln('����� � ����: ', Employee^.Data.HoursPerDay);
  Writeln('��� ������������: ', Employee^.Data.ManagerCode);
end;

procedure ViewEmployees(const EmployeesHead: PEmployeeNode);
var
  Current: PEmployeeNode;
begin
  Current := EmployeesHead;
  while Current <> nil do
  begin
    ViewEmployee(Current);
    Writeln('---------------------');
    Current := Current^.Next;
  end;
end;

procedure ViewProject(const Project: PProjectNode);
begin
    Writeln('������: ', Project^.Data.ProjectName);
    Writeln('������: ', Project^.Data.Task);
    Writeln('�����������: ', Project^.Data.EmployeeCode);
    Writeln('������������: ', Project^.Data.ManagerCode);
    Writeln('���� ������: ', DateToStr(Project^.Data.IssueDate));
    Writeln('���� ����������: ', DateToStr(Project^.Data.Deadline));
end;

procedure ViewProjects(const ProjectsHead: PProjectNode);
var
  Current: PProjectNode;
begin
  Current := ProjectsHead;
  while Current <> nil do
  begin
    ViewProject(Current);
    Writeln('---------------------');
    Current := Current^.Next;
  end;
end;

// Add data

procedure AddEmployee(var EmployeesHead: PEmployeeNode);
var
  Emp: TEmployee;
  NewNode: PEmployeeNode;
begin
  Writeln('���������� ����������:');
  Write('���: '); Readln(Emp.Code);
  Write('���: '); Readln(Emp.Name);
  Write('���������: '); Readln(Emp.Position);
  Write('����� � ����: '); Readln(Emp.HoursPerDay);
  Write('��� ������������: '); Readln(Emp.ManagerCode);

  New(NewNode);
  NewNode^.Data := Emp;
  NewNode^.Next := EmployeesHead;
  EmployeesHead := NewNode;
end;

procedure AddProject(var ProjectsHead: PProjectNode);
var
  Proj: TProject;
  NewNode: PProjectNode;
begin
  Writeln('���������� �������:');
  Write('�������� �������: '); Readln(Proj.ProjectName);
  Write('������: '); Readln(Proj.Task);
  Write('��� �����������: '); Readln(Proj.EmployeeCode);
  Write('��� ������������: '); Readln(Proj.ManagerCode);
  Proj.IssueDate := ReadDate('���� ������');
  Proj.Deadline := ReadDate('���� ����������');

  New(NewNode);
  NewNode^.Data := Proj;
  NewNode^.Next := ProjectsHead;
  ProjectsHead := NewNode;
end;


// Delete data

// TODO: delete by name
procedure DeleteEmployee(var EmployeesHead: PEmployeeNode);
var
  Code: Integer;
  Current, Prev: PEmployeeNode;
  Found: Boolean;
begin
  Write('������� ��� ���������� ��� ��������: ');
  Readln(Code);

  Current := EmployeesHead;
  Prev := nil;
  Found := False;

  while (not Found) and (Current <> nil) do
  begin
    if Current^.Data.Code = Code then
    begin
      if Prev = nil then
        EmployeesHead := Current^.Next
      else
        Prev^.Next := Current^.Next;

      Dispose(Current);
      Found := True;
    end
    else
    begin
      Prev := Current;
      Current := Current^.Next;
    end;
  end;

  if Found then
    Writeln('��������� ������')
  else
    Writeln('��������� �� ������');
  writeln('������� �����  ������� ��� �����������...');
  readln;
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
  ClearScreen;
  Writeln('1. ������ ����� �� �������');
  Writeln('2. ������ � ��������� ������ (�����)');
  Writeln('3. �����');
  Write('�������� �������: ');
  Readln(Choice);

  if Choice = 1 then
  begin
    ProjectsEmpty := (ProjectsHead = nil);
    if not ProjectsEmpty then
    begin
      Write('������� �������� �������: ');
      Readln(ProjectName);
      AssignFile(OutputFile, 'project_tasks.txt');
      Rewrite(OutputFile);

      HasData := False;
      CurrentProj := ProjectsHead;
      while CurrentProj <> nil do
      begin
        if CurrentProj^.Data.ProjectName = ProjectName then
        begin
          ViewProject(CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
        Writeln('������ �� ������ ��� �� �������� �����');
      CloseFile(OutputFile);
    end
    else
      Writeln('������ �������� ����!');
  end
  else if Choice = 2 then
  begin
    ProjectsEmpty := (ProjectsHead = nil);
    if not ProjectsEmpty then
    begin
      CurrentDate := Date();
      AssignFile(OutputFile, 'urgent_tasks.txt');
      Rewrite(OutputFile);

      HasData := False;
      CurrentProj := ProjectsHead;
      while CurrentProj <> nil do
      begin
        if DaysBetween(CurrentDate, CurrentProj^.Data.Deadline) <= 30 then
        begin
          ViewProject(CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
        Writeln('��� ����� � ��������� ������');
      CloseFile(OutputFile);
    end
    else
      Writeln('������ �������� ����!');
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
  Writeln('3. �����');
  Write('��������: ');
  readln(Choice);
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

  // �������������� �������� � ������ ���
  case Field of
    esfCode, esfHours, esfManagerCode:
      if not TryStrToInt(Value, SearchCode) then
      begin
        Writeln('������������ ������ �����');
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

  // �������������� �������� � ������ ���
  case Field of
    psfEmployeeCode, psfManagerCode:
      if not TryStrToInt(Value, SearchCode) then
      begin
        Writeln('������������ ������ �����');
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
  Current, NextNode: PEmployeeNode;
  Temp: TEmployee;
  Swapped: Boolean;
begin
  if EmployeesHead <> nil then
  begin
    repeat
      Swapped := False;
      Current := EmployeesHead;
      NextNode := Current^.Next;

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
          Temp := Current^.Data;
          Current^.Data := NextNode^.Data;
          NextNode^.Data := Temp;
          Swapped := True;
        end;

        Current := NextNode;
        NextNode := NextNode^.Next;
      end;
    until not Swapped;
  end;
end;


procedure SortProjects(var ProjectsHead: PProjectNode;
                      Field: TProjectSortField; Direction: TSortDirection);
var
  Current, NextNode: PProjectNode;
  Temp: TProject;
  Swapped: Boolean;
  CompareResult: Integer;
begin
  if ProjectsHead <> nil then
  begin
    repeat
      Swapped := False;
      Current := ProjectsHead;
      NextNode := Current^.Next;

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
          Temp := Current^.Data;
          Current^.Data := NextNode^.Data;
          NextNode^.Data := Temp;
          Swapped := True;
        end;

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
  Writeln('3. �����');
  Write('�������� ������: ');
  Readln(SortField);

  if SortField <> 3 then
  begin

    ClearScreen;
    Writeln('����������� ����������:');
    Writeln('1. �� �����������');
    Writeln('2. �� ��������');
    Write('�������� �����������: ');
    Readln(Direction);

    // ����� ���������
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
      Readln(SortField);

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
      Readln(SortField);

      SortProjects(
        ProjectsHead,
        TProjectSortField(SortField - 1),
        TSortDirection(Direction - 1)
      );
    end;

    Writeln('���������� ���������');
    Write('������� Enter...');
    Readln;
  end;
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
  Write('�������� ��� ������: ');
  Readln(Choice);

  if Choice = 3 then
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
      Readln(SubChoice);

      Write('������� �������� ��� ������: ');
      Readln(SearchValue);

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
      Readln(SubChoice);

      Write('������� �������� ��� ������: ');
      Readln(SearchValue);

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
  Writeln('3. �����');
  Write('��������: ');
  Readln(Choice);
end;

procedure ShowMenu(EmployeesHead: PEmployeeNode; ProjectsHead: PProjectNode);
var
  Choice, SubChoice: Integer;
  quit: boolean;
begin
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
    Writeln('8. ����. �������');
    Writeln('9. ����� ��� ����������');
    Writeln('10. ����� � �����������');
    Write('�������� �����: ');
    Readln(Choice);

    case Choice of
      1: LoadData(EmployeesHead, ProjectsHead);
      2:
        begin
          SubMenu('�������� ������', SubChoice);
          case SubChoice of
            1: ViewEmployees(EmployeesHead);
            2: ViewProjects(ProjectsHead);
          end;
          Write('������� Enter...'); Readln;
        end;
      3: SortMenu(ProjectsHead, EmployeesHead);
      4: SearchMenu(ProjectsHead, EmployeesHead);
      5:
        begin
          SubMenu('���������� ������', SubChoice);
          case SubChoice of
            1: AddEmployee(EmployeesHead);
            2: AddProject(ProjectsHead);
          end;
          writeln('������ ������� ���������! ������� Enter...');
          readln;
        end;
      6: DeleteEmployee(EmployeesHead);
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
  ShowMenu(EmployeesHead, ProjectsHead);
  ClearScreen;
end.
