#Project Overview
This project processes a formatted input string to manage a doubly linked list data structure. The system mandates strict uppercase syntax and discards malformed operations automatically. 

##Supported Operations
The system executes the following primary functions based on the input string:  
  ADD: Inserts a new character node into the linked list.  
  DEL: Performs a logical deletion of a target node by reassigning adjacent pointers.  
  PRINT: Outputs the current sequence of list characters to the console.  
  SORT: Orders the list elements utilizing a Bubble Sort algorithmic approach.  
  REV: Reverses the positional order of all nodes within the list.  
  
##Memory Architecture
The structural design of the linked list utilizes a specific memory allocation strategy:
  Node Dimension: Every individual node requires exactly 9 bytes of memory.  
  Pointers: The structure reserves 4 bytes for the previous node pointer (PBACK) and 4 bytes for         the next node pointer (PAHEAD).  
  Data Payload: The system stores the ASCII character data within a single byte.  
  Null Terminations: The architecture utilizes the hexadecimal value 0xFFFFFFFF to designate a NULL pointer.  
  Address Generation: The program employs a Linear Feedback Shift Register (LFSR). This mathematical polynomial mechanism calculates pseudo-random memory addresses for subsequent node allocations.  

##Sorting Hierarchy
The SORT command implements a specific transitive ordering convention rather than strict ASCII numerical sorting:  
  Uppercase characters possess the highest sorting priority.   
  Lowercase characters possess priority over numerical digits.  
  Numerical digits possess priority over acceptable extra characters.  
  Standard ASCII numerical ordering remains applicable strictly within these defined subsets.  
  The algorithm categorizes characters with an ASCII value below 32 as unacceptable. 
