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
  empCode: integer;

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
  s: string;
  date: TDateTime;
  isCorrect: boolean;
begin
  s := '';
  isCorrect := true;
  repeat
    if not isCorrect then
      Writeln('Неверный формат. Повтрите: ');
    Write(Prompt, '(ДД.ММ.ГГГГ): ');
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
      Write('Ошибка ввода. Повторите: ');
    Readln(s);
    isCorrect := false;
  until TryStrToInt(string(s), res);
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
      writeln;
      writeln('Строка должна содержать не менее одного символа!');
      write('Повторите ввод: ');
    end;
    readln(str);
    str := trim(str);
    secondIter := true;
  until (Length(str) > 0);
  Result := str;
end;

//function ReadEmpCode(const Head: PEmployeeNode): integer;
//var
//  isCorrect, used: boolean;
//  curCode: integer;
//  curNode: PEmployeeNode;
//begin
//  isCorrect := false;
//  repeat
//    curCode := readInt;
//    used := false;
//    curNode := Head;
//    while curNode <> nil do
//      if (curNode^.Data.Code = curCode) then
//        used := true;
//    if used then
//    begin
//      Write('Такой код уже существует. Введите другой: ');
//    end
//    else
//    begin
//      isCorrect := true;
//    end;
//  until isCorrect;
//  Result := curCode;
//end;

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
begin
  clearScreen;
  // Loading employees
  if FileExists('employees.TEmployee') then
  begin
    AssignFile(FEmployees, 'employees.TEmployee');
    Reset(FEmployees);
    while not Eof(FEmployees) do
    begin
      empCode := empCode + 1;
      Read(FEmployees, Emp);
      New(NewNodeEmp);
      NewNodeEmp^.Data := emp;
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
      NewNodeProj^.Data := proj;
      NewNodeProj^.Next := ProjectsHead;
      ProjectsHead := NewNodeProj;
    end;
    CloseFile(FProjects);
  end;
  Writeln('Данные загружены. Нажмите Enter для продолжения...');
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
  Writeln('Данные сохранены. Нажмите Enter...');
  Readln;
end;

// Print data

procedure ViewEmployee(const employee: PEmployeeNode);
begin
writeln('------------------------------------------------------------------');
  Writeln('Код: ', employee^.Data.Code);
  Writeln('ФИО: ', employee^.Data.Name);
  Writeln('Должность: ', employee^.Data.Position);
  Writeln('Часов в день: ', employee^.Data.HoursPerDay);
  Writeln('Код руководителя: ', employee^.Data.ManagerCode);
  writeln('------------------------------------------------------------------');
  writeln;
end;

procedure ViewEmployees(const EmployeesHead: PEmployeeNode);
var
  current: PEmployeeNode;

begin
  current := EmployeesHead;
  if current = nil then
    writeln('Список сотрудников пуст');
  while current <> nil do
  begin
    ViewEmployee(current);
    current := current^.Next;
  end;
end;


procedure ViewProject(const project: PProjectNode);
begin
    writeln('------------------------------------------------------------------');
    Writeln('Проект: ', project^.Data.ProjectName);
    Writeln('Задача: ', project^.Data.Task);
    Writeln('Исполнитель: ', project^.Data.EmployeeCode);
    Writeln('Руководитель: ', project^.Data.ManagerCode);
    Writeln('Дата выдачи: ', DateToStr(project^.Data.IssueDate));
    Writeln('Срок выполнения: ', DateToStr(project^.Data.Deadline));
    writeln('------------------------------------------------------------------');
    writeln;
end;

procedure ViewProjectFile(const curFile: TextFile; const project: PProjectNode);
begin
    writeln(curFile, '------------------------------------------------------------------');
    Writeln(curFile, 'Проект: ', project^.Data.ProjectName);
    Writeln(curFile, 'Задача: ', project^.Data.Task);
    Writeln(curFile, 'Исполнитель: ', project^.Data.EmployeeCode);
    Writeln(curFile, 'Руководитель: ', project^.Data.ManagerCode);
    Writeln(curFile, 'Дата выдачи: ', DateToStr(project^.Data.IssueDate));
    Writeln(curFile, 'Срок выполнения: ', DateToStr(project^.Data.Deadline));
    writeln(curFile, '------------------------------------------------------------------');
    writeln(curFile, '');

end;

procedure ViewProjects(const ProjectsHead: PProjectNode);
var
  current: PProjectNode;
begin
  current := ProjectsHead;
  if current = nil then
    writeln('Список проектов пуст');
  while current <> nil do
  begin
    ViewProject(current);
    current := current^.Next;
  end;
end;

// Add data

function genCode(var empCode: integer): integer;
begin
  Result := empCode;
  empCode := empCode + 1;
end;

function getProjName(var ProjectsHead: PProjectNode): string;
var
  used, secondIter: boolean;
  name: string[50];
  current: PProjectNode;
begin
  secondIter := false;
  repeat
    if secondIter then
      write('Проект с таким названием уже существует. Введите другое название:');
    name := ShortString(ReadStr());

    current := ProjectsHead;
    used := false;
    while current <> nil do
    begin
      if current^.Data.ProjectName = name then
        used := true;
      current := current^.Next;
    end;
    secondIter := true;
  until not used;
  Result := string(name);
end;

procedure AddEmployee(var EmployeesHead: PEmployeeNode; var empCode: integer);
var
  emp: TEmployee;
  newNode: PEmployeeNode;
  secondIter: boolean;
begin
  Writeln('Добавление сотрудника:');
  emp.Code := genCode(empCode);//emp.Code := readEmpCode(EmployeesHead);
  Write('ФИО: '); emp.Name := ShortString(ReadStr());
  Write('Должность: '); emp.Position := ShortString(ReadStr());
  secondIter := false;
  Write('Часов в день: ');
  repeat
    if secondIter then
    begin
      write('Ошибка. Число должно быть от 0 до 24: ')
    end;
    emp.HoursPerDay := readInt;
    secondIter := true;
  until (emp.HoursPerDay >= 0) and (emp.HoursPerDay <= 24);

  Write('Код руководителя: '); emp.ManagerCode := readInt;

  New(newNode);
  newNode^.Data := emp;
  newNode^.Next := EmployeesHead;
  EmployeesHead := newNode;
end;


procedure AddProject(var ProjectsHead: PProjectNode; const empCode: integer);
var
  proj: TProject;
  newNode: PProjectNode;
begin

  Writeln('Добавление проекта:');
  Write('Название проекта: '); proj.ProjectName := shortString(getProjName(ProjectsHead));//Readln(proj.ProjectName);
  Write('Задача: '); proj.Task := ShortString(ReadStr());

  Write('Код исполнителя: ');
  proj.EmployeeCode := readInt;

  Write('Код руководителя: ');
  proj.ManagerCode := readInt;
  proj.IssueDate := ReadDate('Дата выдачи');
  proj.Deadline := ReadDate('Срок выполнения');

  New(newNode);
  newNode^.Data := proj;
  newNode^.Next := ProjectsHead;
  ProjectsHead := newNode;
end;


// Delete data
procedure DeleteEmployeeByCode(var EmployeesHead: PEmployeeNode);
var
  code, choose: integer;
  current, prev: PEmployeeNode;
  found, confirm: boolean;
begin
  Write('Введите код сотрудника для удаления: ');
  code := readInt;

  current := EmployeesHead;
  prev := nil;
  Found := False;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.Code = code then
    begin
      confirm := false;
      writeln('Действительно удалить этого сотрудника?');
      writeln('1. Да');
      writeln('2. Нет');
      choose := ReadInt;
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

  if found then
    Writeln('Сотрудник удален')
  else
    Writeln('Сотрудник не найден');
  Writeln('Нажмите Enter для продолжения...');
  Readln;
end;

procedure DeleteEmployee(var EmployeesHead: PEmployeeNode);
var
  choice: integer;
  current: PEmployeeNode;
  name: string[50];
begin
  Writeln('=== Удаление данных ===');

  Writeln('1. Удаление по ФИО');
  Writeln('2. Удаление по коду');
  Writeln('0. Назад');
  Write('Выберите: ');

  choice := ReadInt;
  if choice <> 0 then
  begin
    if choice = 1 then
    begin
      write('Введите ФИО: ');
      name := ShortString(ReadStr());
      current := EmployeesHead;
      while current <> nil do
      begin
        if current^.Data.Name = name then
        begin
          ViewEmployee(current);
        end;
        current := current^.Next;
      end;
    end;
    DeleteEmployeeByCode(EmployeesHead);
  end;
end;

procedure DeleteProject(var ProjectsHead: PProjectNode);
var
  name: string[50];
  current, prev: PProjectNode;
  found: Boolean;
begin
  Write('Введите название проекта для удаления: ');
  name := ShortString(ReadStr());

  current := ProjectsHead;
  prev := nil;
  Found := False;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.ProjectName = name then
    begin
      if prev = nil then
        ProjectsHead := current^.Next
      else
        prev^.Next := current^.Next;

      Dispose(current);
      found := True;
    end
    else
    begin
      prev := current;
      current := current^.Next;
    end;
  end;

  if found then
    Writeln('Проект удален')
  else
    Writeln('Проект не найден');
  Writeln('Нажмите Enter для продолжения...');
  Readln;
end;

procedure DeleteData(var EmployeesHead: PEmployeeNode; var ProjectssHead: PProjectNode);
var
  choice: integer;
begin
  Writeln('=== Удаление данных ===');

  Writeln('1. Удаление сотрудников');
  Writeln('2. Удаление проектов');
  Writeln('0. Назад');
  Write('Выберите: ');
  choice := readInt;
  case choice of
    0:
      begin

      end;
    1:
      begin
        clearScreen;
        DeleteEmployee(EmployeesHead);
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

procedure EditEmployee(var EmployeesHead: PEmployeeNode);
var
  code: integer;
  found, waschange, secondIter: boolean;
  current: PEmployeeNode;
  choice: integer;
  name: string[50];
begin

  Writeln('1. Редактирование по ФИО');
  Writeln('2. Редактирование по коду');
  Writeln('0. Назад');
  Write('Выберите: ');

  choice := ReadInt;
  if choice <> 0 then
  begin
    if choice = 1 then
    begin
      write('Введите ФИО: ');
      name := ShortString(ReadStr());
      current := EmployeesHead;
      while current <> nil do
      begin
        if current^.Data.Name = name then
        begin
          ViewEmployee(current);
        end;
        current := current^.Next;
      end;
    end;

    Write('Введите код сотрудника, которого необходимо изменить: ');
    code := ReadInt;

    current := EmployeesHead;
    Found := False;
    waschange := false;

    while (not Found) and (current <> nil) do
    begin
      if current^.Data.Code = code then
      begin
        clearScreen;
        writeln('Введите номер параметра, который нужно изменить');
        writeln('1. ФИО');
        writeln('2. Должность');
        writeln('3. Часов в день');
        writeln('4. Код руководителя');
        writeln('0. Выход');
        choice := ReadInt;

        case choice of
          0:
            begin

            end;
          1:
            begin
              Write('Новое ФИО: ');
              current^.Data.Name := ShortString(ReadStr());
              waschange := true;
            end;
          2:
            begin
              Write('Новая должность: ');
              current^.Data.Position := ShortString(ReadStr());
              waschange := true;
            end;
          3:
            begin
              Write('Новое значение окличества рабочих часов в день: ');
              secondIter := false;
              repeat
                if secondIter then
                begin
                  write('Ошибка. Число должно быть от 0 до 24: ')
                end;
                current^.Data.HoursPerDay := readInt;
                secondIter := true;
              until (current^.Data.HoursPerDay >= 0) and (current^.Data.HoursPerDay <= 24);
              waschange := true;
            end;
          4:
            begin
              Write('Новый код руководителя: ');
              current^.Data.ManagerCode := readInt;
              waschange := true;
            end;
          else
            begin
              writeln('Нажата неверная клавиша. Выход');
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
        Writeln('Данные сотрудника изменены')
      else
        Writeln('Данные сотрудника не были изменены')
    else
      Writeln('Сотрудник не найден');
    Writeln('Нажмите Enter для продолжения...');
    Readln;
  end;
end;

procedure EditProject(var ProjectsHead: PProjectNode);
var
  name: string[50];
  found, wasChange: boolean;
  current: PProjectNode;
  choice: integer;
begin
  Write('Введите название проекта, который необходимо изменить: ');
  readln(name);

  current := ProjectsHead;
  Found := False;
  waschange := false;

  while (not Found) and (current <> nil) do
  begin
    if current^.Data.ProjectName = name then
    begin
      clearScreen;
      writeln('Введите номер параметра, который нужно изменить');
      writeln('1. Название');
      writeln('2. Задача');
      writeln('3. Исполнитель');
      writeln('4. Руководитель');
      writeln('5. Дата выдачи');
      writeln('6. Срок выполнения');
      writeln('0. Выход');
      choice := ReadInt;
      case choice of
        0:
          begin

          end;
        1:
          begin
            Write('Новое название проекта: ');
            current^.Data.ProjectName := shortString(getProjName(ProjectsHead));
            wasChange := true;
          end;
        2:
          begin
            Write('Новая задача: ');
            current^.Data.Task := ShortString(ReadStr());
            wasChange := true;
          end;
        3:
          begin
            Write('Новый код исполнителя: ');
            current^.Data.EmployeeCode := readInt;
            wasChange := true;
          end;
        4:
          begin
            Write('Новый код руководителя: ');
            current^.Data.ManagerCode := readInt;
            wasChange := true;
          end;
        5:
          begin
            current^.Data.IssueDate := ReadDate('Новая дата выдачи: ');
            wasChange := true;
          end;
        6:
          begin
            current^.Data.Deadline := ReadDate('Новый срок выполнения: ');
            wasChange := true;
          end;
        else
          begin
            writeln('Нажата неверная клавиша. Выход');
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
      Writeln('Проект изменён')
    else
      Writeln('Проект не был изменён')
  else
    Writeln('Проект не найден');
  Writeln('Нажмите Enter для продолжения...');
  Readln;
end;

procedure EditData(var EmployeesHead: PEmployeeNode; var ProjectssHead: PProjectNode);
var
  choice: integer;
begin
  Writeln('=== Редактирование данных ===');

  Writeln('1. Редактирование сотрудников');
  Writeln('2. Редактирование проектов');
  Writeln('0. Назад');
  Write('Выберите: ');
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
  Writeln('1. Список задач по проекту');
  Writeln('2. Задачи с ближайшим сроком (месяц)');
  Writeln('0. Назад');
  Write('Выберите функцию: ');
  Choice := readInt;
  if (Choice < 0) or (Choice > 2) then
  begin
    writeln('Нажата неверная клавиша. Совершен выход. Нажмите Enter для продолжения');
    readln;
  end;

  if Choice = 1 then
  begin
    ProjectsEmpty := (ProjectsHead = nil);
    if not ProjectsEmpty then
    begin
      Write('Введите название проекта: ');
      ProjectName := ShortString(ReadStr());
      AssignFile(OutputFile, 'project_tasks.txt');
      Rewrite(OutputFile);

      HasData := False;
      CurrentProj := ProjectsHead;
      while (not HasData) and (CurrentProj <> nil) do
      begin
        if CurrentProj^.Data.ProjectName = ProjectName then
        begin
          write('Задачи: ');
          writeln(CurrentProj^.Data.Task);

          write(OutputFile, 'Задачи: ');
          writeln(OutputFile, CurrentProj^.Data.Task);
          //ViewProject(CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
        Writeln('Проект не найден');

      CloseFile(OutputFile);

    end
    else
      Writeln('Список проектов пуст!');
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
          ViewProjectFile(OutputFile, CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
        Writeln('Нет задач с ближайшим сроком');
      CloseFile(OutputFile);
    end
    else
      Writeln('Список проектов пуст!');
  end;

  if (Choice = 1) or (Choice = 2) then
  begin
    Write('Нажмите Enter...');
    Readln;
  end;
end;


// Exit

procedure exitConfirm(var quit: boolean);
var
  Choice: integer;
begin
  writeln('Дейстыительно хотите выйти без сохранения?');
  Writeln('1. Да');
  Writeln('2. Нет');
  Writeln('0. Назад');
  Write('Выберите: ');
  Choice := readInt;
  if (Choice < 0) or (Choice > 2) then
  begin
    writeln('Нажата неверная клавиша. Действие отменено. Нажмите Enter для продолжения');
    readln;
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
        Writeln('Некорректный формат числа');
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
      Writeln('Сотрудники не найдены');
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
        Writeln('Некорректный формат числа');
        Quit := true;
      end;

    psfIssueDate, psfDeadline:
      if not TryStrToDate(Value, SearchDate) then
      begin
        Writeln('Некорректный формат даты');
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
      Writeln('Проекты не найдены');
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

//          swap Current and NextNode
//          Temp := Current^.Data;
//          Current^.Data := NextNode^.Data;
//          NextNode^.Data := Temp;
//          Swapped := True;
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
  Writeln('=== Сортировка данных ===');

  Writeln('1. Сотрудники');
  Writeln('2. Проекты');
  Writeln('0. Назад');
  Write('Выберите список: ');
  SortField := readInt;

  if SortField <> 0 then
  begin

    ClearScreen;
    Writeln('Направление сортировки:');
    Writeln('1. По возрастанию');
    Writeln('2. По убыванию');
    Write('Выберите направление: ');
    Direction := readInt;

    ClearScreen;
    if SortField = 1 then
    begin
      Writeln('Параметры сортировки сотрудников:');
      Writeln('1. Код сотрудника');
      Writeln('2. ФИО');
      Writeln('3. Должность');
      Writeln('4. Рабочие часы');
      Writeln('5. Код руководителя');
      Write('Выберите параметр: ');
      SortField := readInt;

      SortEmployees(
        EmployeesHead,
        TEmployeeSortField(SortField - 1),
        TSortDirection(Direction - 1)
      );
    end
    else if SortField = 2 then
    begin
      Writeln('Параметры сортировки проектов:');
      Writeln('1. Название проекта');
      Writeln('2. Код исполнителя');
      Writeln('3. Код руководителя');
      Writeln('4. Дата выдачи');
      Writeln('5. Срок выполнения');
      Write('Выберите параметр: ');
      SortField := readInt;

      SortProjects(
        ProjectsHead,
        TProjectSortField(SortField - 1),
        TSortDirection(Direction - 1)
      );
    end;
    clearScreen;
    Writeln('Сортировка завершена');
    Write('Нажмите Enter...');
    Readln;
  end;
end;

procedure SearchMenu(var ProjectsHead: PProjectNode; var EmployeesHead: PEmployeeNode);
var
  Choice, SubChoice: Integer;
  SearchValue: string;
begin
  ClearScreen;
  Writeln('=== Поиск данных ===');

  Writeln('1. Поиск сотрудников');
  Writeln('2. Поиск проектов');
  Writeln('3. Назад');
  Write('Выберите тип поиска: ');
  Choice := readInt;

  if Choice <> 3 then
  begin
    ClearScreen;
    if Choice = 1 then
    begin
      Writeln('Параметры поиска:');
      Writeln('1. По коду сотрудника');
      Writeln('2. По ФИО');
      Writeln('3. По должности');
      Writeln('4. По рабочим часам');
      Writeln('5. По коду руководителя');
      Write('Выберите параметр: ');
      SubChoice := readInt;

      Write('Введите значение для поиска: ');
      SearchValue := ReadStr;

      SearchEmployees(EmployeesHead, TEmployeeSortField(SubChoice - 1), SearchValue);
    end
    else if Choice = 2 then
    begin
      Writeln('Параметры поиска:');
      Writeln('1. По названию проекта');
      Writeln('2. По коду исполнителя');
      Writeln('3. По коду руководителя');
      Writeln('4. По дате выдачи');
      Writeln('5. По сроку выполнения');
      Write('Выберите параметр: ');
      SubChoice := readInt;

      Write('Введите значение для поиска: ');
      SearchValue := ReadStr;

      SearchProjects(ProjectsHead, TProjectSortField(SubChoice - 1), SearchValue);
    end;

    Write('Нажмите Enter для продолжения...');
    Readln;
  end;
end;

procedure SubMenu(const Title: string; var Choice: Integer);
begin
  ClearScreen;
  Writeln(Title);
  Writeln('1. Сотрудники');
  Writeln('2. Проекты');
  Writeln('0. Назад');
  Write('Выберите: ');
  Choice := readInt;
end;

procedure ShowMenu(EmployeesHead: PEmployeeNode;
                    ProjectsHead: PProjectNode; var empCode: integer);
var
  Choice, SubChoice: Integer;
  quit: boolean;
begin
  quit := false;
  repeat
    ClearScreen;
    Writeln('1. Чтение данных');
    Writeln('2. Просмотр данных');
    Writeln('3. Сортировка');
    Writeln('4. Поиск');
    Writeln('5. Добавление');
    Writeln('6. Удаление');
    Writeln('7. Редактирование');
    Writeln('8. Список задач по проекту / задачи с ближайшим сроком (месяц)');
    Writeln('9. Выход без сохранения');
    Writeln('10. Выход с сохранением');
    Write('Выберите пункт: ');
    Choice := readInt;

    case Choice of
      1: LoadData(EmployeesHead, ProjectsHead, empCode);
      2:
        begin
          SubMenu('Просмотр данных', SubChoice);
          clearScreen;
          case SubChoice of
            1:
              begin
                ViewEmployees(EmployeesHead);
                Write('Нажмите Enter...'); Readln;
              end;
            2:
              begin
                ViewProjects(ProjectsHead);
                Write('Нажмите Enter...'); Readln;
              end;
          end;
        end;
      3: SortMenu(ProjectsHead, EmployeesHead);
      4: SearchMenu(ProjectsHead, EmployeesHead);
      5:
        begin
          SubMenu('Добавление данных', SubChoice);
          case SubChoice of
            0:
              begin

              end;
            1:
              begin
                AddEmployee(EmployeesHead, empCode);
                writeln('Данные успешно добавлены! Нажмите Enter...');
                readln;
              end;
            2:
              begin
                AddProject(ProjectsHead, empCode);
                writeln('Данные успешно добавлены! Нажмите Enter...');
                readln;
              end;
            else
              begin
                writeln('Нажата неверная клавиша. Нажмите Enter...');
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
  ShowMenu(EmployeesHead, ProjectsHead, empCode);
end.
