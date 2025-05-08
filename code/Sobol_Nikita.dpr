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
      Writeln('Неверный формат. Повтрите.');
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
      writeln('Строка должна содержать не менее одного символа, отличного от пробела!');
      write('Повторите ввод: ');
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
    Writeln('Данные загружены. Нажмите Enter для продолжения...')
  else
    writeln('Ошибка загрузки. Некоторых файлов не существует. Нажмите Enter для продолжения...');
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
  if employee^.Data.ManagerCode <> -1 then
    Writeln('Код руководителя: ', employee^.Data.ManagerCode)
  else
    Writeln('Код руководителя отсутствует');
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
    Writeln('------------------------------------------------------------------');
    Writeln('Проект: ', project^.Data.ProjectName);
    Writeln('Код: ', project^.Data.Code);
    Writeln('Задача: ', project^.Data.Task);
    Writeln('Исполнитель: ', project^.Data.EmployeeCode);
    Writeln('Руководитель: ', project^.Data.ManagerCode);
    Writeln('Дата выдачи: ', DateToStr(project^.Data.IssueDate));
    Writeln('Срок выполнения: ', DateToStr(project^.Data.Deadline));
    Writeln('------------------------------------------------------------------');
    Writeln;
end;

procedure ViewProjectFile(const curFile: TextFile; const project: PProjectNode);
begin
    Writeln(curFile, AnsiToUtf8('------------------------------------------------------------------'));
    Writeln(curFile, AnsiToUtf8('Проект: '), AnsiToUtf8(string(project^.Data.ProjectName)));
    Writeln(curFile, AnsiToUtf8('Код: '), AnsiToUtf8(intToStr(project^.Data.Code)));
    Writeln(curFile, 'Задача: ', AnsiToUtf8(string(project^.Data.Task)));
    Writeln(curFile, 'Исполнитель: ', AnsiToUtf8(intToStr(project^.Data.EmployeeCode)));
    Writeln(curFile, 'Руководитель: ', AnsiToUtf8(intToStr(project^.Data.ManagerCode)));
    Writeln(curFile, 'Дата выдачи: ', AnsiToUtf8(DateToStr(project^.Data.IssueDate)));
    Writeln(curFile, 'Срок выполнения: ', AnsiToUtf8(DateToStr(project^.Data.Deadline)));
    Writeln(curFile, '------------------------------------------------------------------');
    Writeln(curFile, '');

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
      Writeln('Ошибка. Сотрудник с таким кодом не найден. Повторите ввод');
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
      writeln('Ошибка ввода. Повторите: ');
      isCorrect := false;
    end;
    if isCorrect and (Result = empCode) then
    begin
      isCorrect := false;
      writeln('Ошибка. Сотрудник не может быть начальником самого себя. Повторите ввод: ');
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
          write('Ошибка. сотрудник с таким кодом не найден. Повторите ввод: ');
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
  Writeln('Добавление сотрудника');
  emp.Code := genEmpCode(empCode);//emp.Code := readEmpCode(EmployeesHead);
  writeln('Текущий код сотрудника: ', emp.Code);
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
  emp.ManagerCode := genManagerCode(EmployeesHead, 'Код руководителя: ', emp.Code);

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

  Writeln('Добавление проекта');
  proj.Code := genProjCode(projCode);
  writeln('Текущий код проекта: ', proj.Code);
  Write('Название проекта: ');
  proj.ProjectName := shortString(ReadStr());
  Write('Задача: '); proj.Task := ShortString(ReadStr());
  proj.EmployeeCode := getEmpByCode(EmployeesHead, 'Код исполнителя: ', -1);
  proj.ManagerCode := getEmpByCode(EmployeesHead, 'Код руководителя: ', -1);
  proj.IssueDate := ReadDate('Дата выдачи');
  proj.Deadline := ReadDate('Срок выполнения');
  while proj.Deadline < proj.IssueDate do
  begin
    writeln('Ошибка. Срок выполнения должен быть позже, чем дата выдачи. Повторите ввод');
    proj.Deadline := ReadDate('Срок выполнения');
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
  Write('Введите код сотрудника для удаления: ');
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
      Writeln('Ошибка. Кода нет среди выбраных имен. Повторите ввод');
      Write('Введите код сотрудника для удаления: ');
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
      writeln('Действительно удалить этого сотрудника?');
      writeln('1. Да');
      writeln('2. Нет');
      choose := ReadInt;
      while (choose > 2) or (choose < 1) do
      begin
        write('Неверный ввод. Повторите: ');
        choose := ReadInt;
      end;

      if checkProjUsedCode(ProjectsHead, code) then
      begin
        writeln('Ошибка. Сотрудник задействован в существующем проекте');
        choose := 2;
      end
      else if checkEmpUsedCode(EmployeesHead, code) then
      begin
        writeln('Ошибка. Сотрудник является начальником для других сотрудников');
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
    Writeln('Сотрудник удален')
  else if found and (not confirm) then
    Writeln('Отменено')
  else
    Writeln('Сотрудник не найден');
  Writeln('Нажмите Enter для продолжения...');
  Readln;
end;

procedure DeleteEmployee(var EmployeesHead: PEmployeeNode; var ProjectsHead: PProjectNode);
var
  choice, siz, i: integer;
  current: PEmployeeNode;
  name: string[50];
  codes: array of integer;
begin
  Writeln('=== Удаление сотрудника ===');

  Writeln('1. Удаление по ФИО');
  Writeln('2. Удаление по коду');
  Writeln('0. Назад');
  Write('Выберите: ');

  choice := ReadInt;
  case choice of
  0:
    begin

    end;
  1:
    begin
      write('Введите ФИО: ');
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
        writeln('Сотрудников с таким именем не сущетсвует. Нажмите Enter');
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
  Write('Введите код задания для удаления: ');
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
      Writeln('Ошибка. Кода нет среди выбраных заданий. Повторите ввод');
      Write('Введите код задания для удаления: ');
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
      writeln('Действительно удалить это задание?');
      writeln('1. Да');
      writeln('2. Нет');
      choose := ReadInt;
      while (choose < 1) or (choose > 2) do
      begin
        write('Неверный ввод. Повторите: ');
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
    Writeln('Задание удалено')
  else if found and (not confirm) then
    Writeln('Отменено')
  else
    Writeln('Задание не найдено');
  Writeln('Нажмите Enter для продолжения...');
  Readln;
end;

procedure DeleteProject(var ProjectsHead: PProjectNode);
var
  choice, i, siz: integer;
  current: PProjectNode;
  name: string[50];
  codes: array of integer;
begin
  Writeln('=== Удаление задания ===');

  Writeln('1. Удаление по названию проекта');
  Writeln('2. Удаление по коду');
  Writeln('0. Назад');
  Write('Выберите: ');
  choice := ReadInt;
  case choice of
  0:
    begin

    end;
  1:
    begin
      write('Введите название проекта: ');
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
        writeln('Заданий с выбранным именем не существует. Нажмите Enter');
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
  Write('Введите код сотрудника, которого необходимо изменить: ');
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
      Writeln('Ошибка. Кода нет среди выбраных сотрудников. Повторите ввод');
      Write('Введите код сотрудника, которого необходимо изменить: ');
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
            current^.Data.ManagerCode := genManagerCode(EmployeesHead, 'Новый код руководителя: ', current^.Data.code);
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
end;

procedure EditEmployee(var EmployeesHead: PEmployeeNode);
var
  i, siz: integer;
  current: PEmployeeNode;
  choice: integer;
  name: string[50];
  codes: array of integer;
begin

  Writeln('1. Редактирование по ФИО');
  Writeln('2. Редактирование по коду');
  Writeln('0. Назад');
  Write('Выберите: ');
  choice := ReadInt;

  while (choice < 0) or (choice > 2) do
  begin
    write('Неверный ввод, повторите: ');
    choice := ReadInt;
  end;

  if choice <> 0 then
  begin
    if choice = 1 then
    begin
      write('Введите ФИО: ');
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
    Writeln('Нажмите Enter для продолжения...');
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
  Write('Введите код задания, которое необходимо изменить: ');
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
      Writeln('Ошибка. Кода нет среди выбраных заданий. Повторите ввод');
      Write('Введите код задания, которого необходимо изменить: ');
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

            current^.Data.ProjectName := shortString(ReadStr());
            //current^.Data.ProjectName := shortString(getProjName(ProjectsHead));
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
            current^.Data.EmployeeCode := getEmpByCode(EmployeesHead, 'Новый код исполнителя: ', -1);
            wasChange := true;
          end;
        4:
          begin
            current^.Data.EmployeeCode := getEmpByCode(EmployeesHead, 'Новый код руководителя: ', -1);
            wasChange := true;
          end;
        5:
          begin
            current^.Data.IssueDate := ReadDate('Новая дата выдачи: ');
            while current^.Data.IssueDate > current^.Data.Deadline do
            begin
              writeln('Ошибка. Дата выдачи должна быть раньше, чем срок выполнения');
              current^.Data.IssueDate := ReadDate('Новая дата выдачи: ');
            end;

            wasChange := true;
          end;
        6:
          begin
            current^.Data.Deadline := ReadDate('Новый срок выполнения: ');

            while current^.Data.IssueDate > current^.Data.Deadline do
            begin
              writeln('Ошибка. Дата выдачи должна быть раньше, чем срок выполнения');
              current^.Data.Deadline := ReadDate('Новый срок выполнения: ');
            end;
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

procedure EditProject(var ProjectsHead: PProjectNode);
var
  name: string[50];
  current: PProjectNode;
  choice, siz, i: integer;
  codes: array of integer;
begin

  Writeln('1. Редактирование по названию проекта');
  Writeln('2. Редактирование по коду');
  Writeln('0. Назад');
  Write('Выберите: ');

  choice := ReadInt;
  while (choice < 0) or (choice > 2) do
  begin
    write('Неверный ввод. Повторите: ');
    choice := ReadInt;
  end;
  if choice <> 0 then
  begin
    if choice = 1 then
    begin
      write('Введите название проекта: ');
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
  while (Choice < 0) or (Choice > 2) do
  begin
    write('Неверный ввод. Повторите: ');
    Choice := readInt;
  end;

  if Choice = 1 then
  begin
    ProjectsEmpty := (ProjectsHead = nil);
    AssignFile(OutputFile, 'project_tasks.txt');
    Rewrite(OutputFile);

    if not ProjectsEmpty then
    begin
      Write('Введите название проекта: ');
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
            writeln('Задачи по проекту ', ProjectName, ':');
            writeln(OutputFile, AnsiToUtf8('Задачи по проекту '),
                     AnsiToUtf8(string(ProjectName)), AnsiToUtf8(':'));
          end;

          Writeln('Задача: ', CurrentProj^.Data.Task, ', код исполнителя: ',
          CurrentProj^.Data.EmployeeCode, ', код руководителя: ',
          CurrentProj^.Data.ManagerCode);

          Writeln(OutputFile, AnsiToUtf8('Задача: '), AnsiToUtf8(string(CurrentProj^.Data.Task)),
          AnsiToUtf8(', код исполнителя: '), AnsiToUtf8(string(intToStr(CurrentProj^.Data.EmployeeCode))),
          AnsiToUtf8(', код руководителя: '), AnsiToUtf8(string(intToStr(CurrentProj^.Data.ManagerCode))));

          //ViewProject(CurrentProj);
          HasData := True;
        end;
        CurrentProj := CurrentProj^.Next;
      end;

      if not HasData then
      begin
        writeln(OutputFile, AnsiToUtf8('Проект не найден'));
        Writeln('Проект не найден');
      end
      else
      begin
        writeln('-------------------------------------------------------');
        writeln(OutputFile, AnsiToUtf8('-------------------------------------------------------'));
      end;
    end
    else
    begin
      Writeln('Список проектов пуст!');
      Writeln(OutputFile, AnsiToUtf8('Список проектов пуст!'));
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
        Writeln('Нет задач с ближайшим сроком');
        Writeln(OutputFile, AnsiToUtf8('Нет задач с ближайшим сроком'));
      end;

    end
    else
    begin
      Writeln('Список проектов пуст!');
      Writeln(OutputFile, AnsiToUtf8('Список проектов пуст!'));
    end;

    CloseFile(OutputFile);
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
  while (Choice < 0) or (Choice > 2) do
  begin
    writeln('Ошибка ввода. Повторите: ');
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
        Writeln('Некорректный формат числа. Нажмите Enter');
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
        Writeln('Некорректный формат числа. Нажмите Enter');
        readln;
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
  while (SortField < 0) or (SortField > 2) do
  begin
    write('Неверный формат. Повторите: ');
    SortField := readInt;
  end;
  ClearScreen;
  Writeln('Направление сортировки:');
  Writeln('1. По возрастанию');
  Writeln('2. По убыванию');
  Write('Выберите направление: ');
  Direction := readInt;
  while (Direction < 1) or (Direction > 2) do
  begin
    write('Неверный формат. Повторите: ');
    Direction := readInt;
  end;

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
    while (SortField < 1) or (SortField > 5) do
    begin
      write('Неверный формат. Повторите: ');
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
    Writeln('Параметры сортировки проектов:');
    Writeln('1. Название проекта');
    Writeln('2. Код исполнителя');
    Writeln('3. Код руководителя');
    Writeln('4. Дата выдачи');
    Writeln('5. Срок выполнения');
    Write('Выберите параметр: ');
    SortField := readInt;
    while (SortField < 1) or (SortField > 5) do
    begin
      write('Неверный формат. Повторите: ');
      SortField := readInt;
    end;
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
  Write('Выберите: ');
  Choice := readInt;
  while (Choice < 1) or (Choice > 3) do
  begin
    write('Неверный формат. Повторите: ');
    Choice := readInt;
  end;
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
      while (SubChoice < 1) or (SubChoice > 5) do
      begin
        write('Неверный формат. Повторите: ');
        SubChoice := readInt;
      end;

      Write('Введите значение для поиска: ');
      if (SubChoice = 1) or (SubChoice = 4) or (SubChoice = 5) then
      begin
        SearchValue := intToStr(ReadInt);
        if SubChoice = 4 then
          while (strToInt(SearchValue) > 24)  or (strToInt(SearchValue) < 0) do
          begin
            write('Ошибка. значение должно быть от 0 до 24');
            SearchValue := intToStr(ReadInt);
          end;

      end

      else
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
      while (SubChoice < 1) or (SubChoice > 5) do
      begin
        write('Неверный формат. Повторите: ');
        SubChoice := readInt;
      end;
      Write('Введите значение для поиска: ');

      if (SubChoice = 2) or (SubChoice = 3) then
        SearchValue := intToStr(ReadInt)
      else if SubChoice = 1 then
        SearchValue := ReadStr
      else
        SearchValue := DateToStr(ReadDate);

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
  while (Choice < 0) or (Choice > 2) do
  begin
    write('Неверный формат. Повторите: ');
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
      1:
      begin
        if wasLoad then
        begin
          clearScreen;
          writeln('Ошибка. Данные уже были загружены!');
          writeln('Нажмите Enter для продолжения');
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
            else
              begin
                writeln('Неверная клавиша. Нажмите Enter для выхода');
                readln;
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
                AddProject(EmployeesHead, ProjectsHead, empCode);
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
  projCode := 1;
  ShowMenu(EmployeesHead, ProjectsHead, empCode);
  ClearEmployees(EmployeesHead);
  ClearProjects(ProjectsHead);
end.
