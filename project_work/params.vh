`define W 8 //What is this?
`define PC 0
 
`define prog_size 17 // amount of lines in project
`define Nplus 7
`define Nminus 6
`define Nmul 6
`define Nles 1
`define Nequ 6
`define Nop `Nplus + `Nminus + `Nmul + `Nles + `Nequ

`define Nreg 23
`define Nconst 24
`define Nmux 6
`define Imem 1
`define Wmem 1
`define Ymem 1
`define Nmem `Imem + `Wmem + `Ymem

`define first 2*`Nop+`Nreg+3*`Nmux+11*`Imem+11*`Wmem+5*`Ymem
`define second `Nop+`Nreg+`Nconst+`Nmux+6*`Imem+6*`Wmem+2*`Ymem
`define M 256 // memory size

`define CONST_FILE "my_const.mem"
`define PROGRAM_FILE "my_program.mem"
