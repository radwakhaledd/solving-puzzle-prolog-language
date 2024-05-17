% Define the board configuration (example)
% board([[red, red, yellow, yellow],
%       [red, blue, red, red],
%       [red, red, red, yellow],
%       [blue, red, blue, yellow]]).

% Check if two cells have the same color
checkColor(Color, [X1,Y1], [X2,Y2]) :-
    board(Board),             % Retrieve the board configuration
    nth0(X1, Board, Row1),    % Access the X1-th row from the board
    nth0(Y1, Row1, Color),    % Access the Y1-th element from the X1-th row, which represents the color of the first cell
    nth0(X2, Board, Row2),    % Access the X2-th row from the board
    nth0(Y2, Row2, Color).    % Access the Y2-th element from the X2-th row, which represents the color of the second cell


% Define movement rules while considering color constraints
move([X1,Y], [X2,Y], 1) :-
    X2 is X1 + 1.            % Move right
move([X1,Y], [X2,Y], 1) :-
    X2 is X1 - 1.            % Move left
move([X,Y1], [X,Y2], 1) :-
    Y2 is Y1 + 1.            % Move down
move([X,Y1], [X,Y2], 1) :-
    Y2 is Y1 - 1.            % Move up

% Define the heuristic calculation (Manhattan distance)
% Calculate the Manhattan distance between two points
% Manhattan distance is the sum of the absolute differences of their coordinates
calculateH([X1,Y1], [X2,Y2], H) :- H is abs(X1 - X2) + abs(Y1 - Y2).

% Print the solution path and goal state
printSolution([State,Parent,G,_,_], Closed) :-
    write("Goal reached!"), nl,
    write("Path: "), nl,
    getPath([State,Parent,G,_,_], Closed, Path),        % Retrieve the path from the start state to the goal state
    reverse(Path, ReversedPath),                        % Reverse the path to print it in the correct order
    printPath(ReversedPath),                            % Print the reversed path
    printGoal(State).                                   % Print the goal state

% Retrieve the path from the start state to the goal state
% Base case: When the parent of the current state is null
% the path consists of only the current state itself
getPath([State,null,_,_,_], _, [State]).
getPath([State,Parent,_,_,_], Closed, Path) :-
    member([Parent,Grandparent,_,_,_], Closed),                % Find a member in the Closed list where the first element is the parent of the current state
    getPath([Parent,Grandparent,_,_,_], Closed, TempPath),     % Recursively retrieve the path from the grandparent to the parent
    append(TempPath, [State], Path).                           % Append the current state to the retrieved path to construct the complete path
 
% Print the path from start to goal
printPath([]).          % Base case: when the path is empty, do nothing      
printPath([X]) :-       % When there is only one element in the path, print it
    write(X).
printPath([X,Y|Xs]) :-
    printPath([Y|Xs]),  % Recursively print the tail of the path
    write(" -> "),
    write(X).

% Print the goal state
printGoal([X,Y]) :-
    write("Goal: "), write([X,Y]), nl.

% Define the A* search algorithm
search([], _, _) :-
    write("No path found!"), nl, !.  % Base case: When the open list is empty, no path is found
search(Open, Closed, Goal) :-
    getBestState(Open, [CurrentState,Parent,G,_,_], _),         % Get the best state from the open list
    CurrentState = Goal,                                        % Check if the current state is the goal state
    printSolution([CurrentState,Parent,G,_,_], Closed), !.      % If the current state is the goal state, print the solution and terminate
search(Open, Closed, Goal) :-
    getBestState(Open, CurrentNode, TmpOpen),                            % Get the best state from the open list
    getAllValidChildren(CurrentNode, TmpOpen, Closed, Goal, Children),   % Generate all valid children of the current state
    addChildren(Children, TmpOpen, NewOpen),                             % Add the children to the open list and recursively continue the search
    append(Closed, [CurrentNode], NewClosed),                            % Add the current state to the closed list
    search(NewOpen, NewClosed, Goal).                                    % Recursive call to continue the search with the updated open and closed lists

% Get all valid children states from a given node
getAllValidChildren(Node, Open, Closed, Goal, Children) :-
    findall(Next, getNextState(Node, Open, Closed, Goal, Next), Children).

% Get the next state based on the current node
getNextState([State,_,G,_,_], Open, Closed, Goal, [Next,State,NewG,NewH,NewF]) :-
    move(State, Next, MoveCost),       % Generate the next possible state by moving from the current state
    calculateH(Next, Goal, NewH),      % Generate the next possible state by moving from the current state
    NewG is G + MoveCost,              % Calculate the new cost 
    NewF is NewG + NewH,               % Calculate the total estimated cost
    \+ member([Next,_,_,_,_], Open),   % Check if the next state is not already in the Open list
    \+ member([Next,_,_,_,_], Closed), % Check if the next state is not already in the Closed list
    checkColor(_, State, Next).        % check if the color is valid between the current state and the next state


% Add children to the open list
addChildren(Children, Open, NewOpen) :-
    append(Open, Children, NewOpen).

% Get the best state from the open list
getBestState(Open, BestChild, Rest) :-
    findMin(Open, BestChild),           % Find the state with the minimum F value
    delete(Open, BestChild, Rest).      % Remove the best state from the Open list to get the rest of the states

% Find the state with the minimum F value in the list
findMin([X], X):- !.          % Base case: When there is only one element in the list, it is the minimum
findMin([Head|T], Min):- 
    findMin(T, TmpMin),       % Recursively find the minimum F value in the tail 
    Head = [_,_,_,_,HeadF],   % get the F value from the head of the list
    TmpMin = [_,_,_,_,TmpF],  % get the F value from the minimum found in the tail
    (TmpF < HeadF -> Min = TmpMin ; Min = Head).    % Extract the F value from the minimum found in the tail

:- dynamic findPath/3.
:- dynamic board/1.
findPath(Start, Goal, Board) :-
    assert(board(Board)),                     % Assert the board configuration
    search([[Start,null,0,0,0]], [], Goal),   % Start the search algorithm
    retract(board(Board)).                    % Retract the asserted board configuration after the search is done
