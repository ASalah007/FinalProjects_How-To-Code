# FinalProjects_How-To-Code-Courses

# Final-Project(How To Code Simple Data).rkt

this is the final project for How to Code Simple Data course on edx. It is the "space invader" game written in racket. to run the game you need to 
1. Open the file in dr-racket program 
2. run the programm by clicking the arrow button
3. write "(main sc1)" in the interactions window (the bottom window)
4. use arrows to move and space bar to shoot

# Final-Project(How To Code Complex Data).rkt

this is the final project for How to Code Complex Data course on edx.
It is two parts project, the first part is an application on cyclic data; 
the second part is a program that generate a table for the teaching assistance on a particular course

to test part2 write 
"(schedule-tas -list of ta datatype (which represents teaching assistant and his empty table's slots)-  -list of int (which represents the index of the empty slots in the table)- ) 
in the interactions window.
e.g. (schedule-tas (list     (make-ta "A" 1 (list 3)) ; teaching assistant that has one empty slot with index 3
                             (make-ta "B" 1 (list 2))
                             (make-ta "C" 1 (list 1))
                             (make-ta "D" 1 (list 5))
                             (make-ta "E" 1 (list 6))
                             (make-ta "F" 1 (list 4))
                             (make-ta "G" 1 (list 7))) (list 1 2 3 4 5 6 7) ; the empty slots in the table)
the output will be a list of assignments (a list of pairs of the TA and his assigned slot)
e.g. (list
           (make-assignment "C" 1)  ; the Teaching assistance named "C" is assigned to the slot 1
           (make-assignment "B" 2)
           (make-assignment "A" 3)
           (make-assignment "F" 4)
           (make-assignment "D" 5)
           (make-assignment "E" 6)
           (make-assignment "G" 7))

