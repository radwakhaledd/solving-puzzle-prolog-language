
% Define the board configuration (example)
% board([
%    [yellow, yellow, yellow, red],
%    [blue, yellow, blue, yellow],
%    [blue, blue, blue, yellow],
%    [blue, blue, blue, yellow]
% ]).

% Establish a predicate to determine whether a cell is inside the boards boundaries.
check_boundaries(Board, X, Y) :-
    length(Board, N),        % Get the length of the board.
    X >= 0, X < N,           % Check if X is within the range (0, N).
    nth0(X, Board, Row),     % Get the row at index X from the board.
    length(Row, M),          % Get the length of the row.
    Y >= 0, Y < M.           % Check if Y is within the range (0, M).

% Create a predicate to determine a cells color at given coordinates.
cellColor(Board, X, Y, Color) :-
    nth0(X, Board, Row),      % Get the row at index X from the board.
    nth0(Y, Row, Color).      % Get the color at index Y from the row.

% Define a predicate to get the adjacent cells of the same color
moveSameColor(Board, X, Y, NextX, NextY, Color) :-           % Move right
    NewX is X + 1, NewY is Y,                                % Calculate the coordinates of the cell to the right
    check_boundaries(Board, NewX, NewY),                     % Ensure they are within the bounds of the board
    cellColor(Board, NewX, NewY, Color),                     % Check if the cell to the right has the same color
    NextX = NewX, NextY = NewY.                              % Set the adjacent cell coordinates
    
moveSameColor(Board, X, Y, NextX, NextY, Color) :-           % Move left
    NewX is X - 1, NewY is Y,                                % Calculate the coordinates of the cell to the left
    check_boundaries(Board, NewX, NewY),                     % Ensure they are within the bounds of the board
    cellColor(Board, NewX, NewY, Color),                     % Check if the cell to the left has the same color
    NextX = NewX, NextY = NewY.                              % Set the adjacent cell coordinates

moveSameColor(Board, X, Y, NextX, NextY, Color) :-           % Move up
    NewX is X, NewY is Y - 1,                                % Calculate the coordinates of the cell up
    check_boundaries(Board, NewX, NewY),                     % Ensure they are within the bounds of the board
    cellColor(Board, NewX, NewY, Color),                     % Check if the cell up has the same color
    NextX = NewX, NextY = NewY.                              % Set the adjacent cell coordinates

moveSameColor(Board, X, Y, NextX, NextY, Color) :-           % Move down
    NewX is X, NewY is Y + 1,                                % Calculate the coordinates of the cell down
    check_boundaries(Board, NewX, NewY),                     % Ensure they are within the bounds of the board
    cellColor(Board, NewX, NewY, Color),                     % Check if the cell down has the same color
    NextX = NewX, NextY = NewY.                              % Set the adjacent cell coordinates

% Define a predicate to check if two cells are adjacent to each other
% Two cells are adjacent if they share the same column and have adjacent rows
% or if they share the same row and have adjacent columns.
adjacent([X1, Y1], [X2, Y2]) :-
    (X1 =:= X2, abs(Y1 - Y2) =:= 1) ;          % Same column, adjacent rows
    (Y1 =:= Y2, abs(X1 - X2) =:= 1).           % Same row, adjacent columns

% Predicate to check if all elements in a list are different
% Base case: An empty list always has different elements.
all_different([]).

% Recursive case
all_different([[X,Y]|Tail]) :-
    \+ member([X,Y], Tail),       % Check if the head is not a member of the tail.
    all_different(Tail).          % Recursively check if all elements in the tail are different.

% Predicate to check if all cells in the cycle have the same color
all_same_color([], _, _).                        % Base case
all_same_color([[X,Y]|Tail], Board, Color) :-    % Recursive case
    cellColor(Board, X, Y, Color),               % Check if the current cell has the specified color.
    all_same_color(Tail, Board, Color).          % Recursively check if all other cells in the cycle have the same color.

% Predicate to check if cells in the cycle are adjacent to each other
adjacent_cells([[X1,Y1],[X2,Y2]|Tail]) :-
    % Check if the current pair of cells are adjacent.
    (X1 =:= X2, abs(Y1 - Y2) =:= 1) ;  % Same column, adjacent rows
    (Y1 =:= Y2, abs(X1 - X2) =:= 1) ,  % Same row, adjacent columns
    adjacent_cells([[X2,Y2]|Tail]).    % Recursively check the next pair of cells

% Define a predicate to check if a list of cells forms a cycle
cycle_check(Cycle, Board, Color) :-
    length(Cycle, Length),
    Length >= 4,                             % At least 4 cells in the cycle
    all_different(Cycle),                    % Ensure no duplicates
    all_same_color(Cycle, Board, Color),     % Ensure all cells have the same color
    adjacent_cells(Cycle),                   % Ensure cells are adjacent to each other
    nth0(0, Cycle, First),                   % Ensure the first and last cells in the cycle are adjacent.
    last(Cycle, Last),
    adjacent(First, Last).

% Define a predicate to find a cycle starting from a given cell

% Base case: Check if the starting cell is revisited and forms a cycle.
search(Board, X, Y, Visited, Cycle, Color) :-
    member([X, Y], Visited),                          % Check if we reached the starting cell again
    Cycle = Visited,                                  % Found a cycle
    cycle_check(Cycle, Board, Color).                 % Check if the found cycle meets the conditions

% Recursive case: Explore adjacent cells.
search(Board, X, Y, Visited, Cycle, Color) :-
    cellColor(Board, X, Y, Color),                                        % Ensure the current cell has the specified color.
    moveSameColor(Board, X, Y, NextX, NextY, Color),                      % Find an adjacent cell with the same color.
    \+ member([NextX, NextY], Visited),                                   % Ensure we have not visited this cell before to avoid infinite loops.
    search(Board, NextX, NextY, [[NextX, NextY]|Visited], Cycle, Color).  % Recursively explore the adjacent cell.

% Prints the cycle.
printCycle([]).               % Base case: Prints an empty cycle.
printCycle([X]) :-            % Prints a single cell cycle.
    write(X).
printCycle([X,Y|Tail]) :-     % Prints each cell in the cycle followed by arrows.
    printCycle([Y|Tail]),     % Recursively print the tail of the cycle.
    write(" -> "),
    write(X).

:- dynamic findCycle/1.
% Define a predicate to solve the puzzle
findCycle(Board) :-
    (search(Board, _, _, [], Cycle, Color) ->
        write('Cycle found with color '), write(Color), write(': '), printCycle(Cycle), nl,! % Print the cycle if found
    ;
        % If no cycle is found, print a message
        write('No cycles found.'),!
    ).
