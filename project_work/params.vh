`define W 4
`define PC 0

`define prog_size 8
`define Nplus 7
`define Nminus 6
`define Nmul 4
`define Nles 1
`define Nequ 6
`define Nop `Nplus + `Nminus + `Nmul + `Nles + `Nequ

`define Nreg 23
`define Nconst 24
`define Nmux 6
`define Imem 6
`define Wmem 6
`define Ymem 2
`define Nmem `Imem + `Wmem + `Ymem


`define M 256 // memory size

`define CONST_FILE "my_const.mem"
`define PROGRAM_FILE "my_program.mem"
