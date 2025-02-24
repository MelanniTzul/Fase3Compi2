
start
    = line:(directive / section / instruction / comment / mcomment / blank_line)*

// Directivas en ARM64 v8
directive
  = _* name:directive_p _* args:(directive_p / label / string / expression)? _* comment? "\n"?

//
directive_p
    = "." directive_name

// Nombre de las directivas
directive_name
  = "align" / "ascii" / "asciz" / "byte" / "hword" / "word" / "quad" /
    "data" / "text" / "global" / "section" / "space" / "zero" / "incbin" / "set" / "equ" / "bss"

// Secciones
section
  = _* label:label _* ":" _* comment? "\n"?

// Instrucciones en ARM64 v8 
instruction
    = i:add_inst     {return i;}
    / i:sub_inst     {return i;}
    / i:mul_inst     {return i;}
    / i:div_inst     {return i;}
    / i:udiv_inst    {return i;}
    / i:uxtb_inst    {return i;}
    / i:sdiv_inst    {return i;}
    / i:ands_inst    {return i;}
    / i:and_inst     {return i;}
    / i:orr_inst     {return i;}
    / i:eor_inst     {return i;}
    / i:mov_inst     {return i;}
    / i:mvn_inst     {return i;}
    / i:ldr_inst     {return i;}
    / i:ldrb_inst    {return i;}
    / i:ldp_inst     {return i;}
    / i:strb_inst    {return i;}
    / i:str_inst     {return i;}
    / i:stp_inst     {return i;}
    / i:lsl_inst     {return i;}
    / i:lsr_inst     {return i;}
    / i:asr_inst     {return i;}
    / i:ror_inst
    / i:cmp_inst
    / i:csel_inst
    / i:cset_inst
    / i:beq_inst
    / i:bne_inst
    / i:bgt_inst
    / i:blt_inst
    / i:ble_inst
    / i:bl_inst
    / i:b_inst
    / i:ret_inst
    / i:svc_inst


// Instrucciones Suma 64 bits y 32 bits (ADD)
add_inst "Instrucción de Suma"
    = _* "ADD"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "ADD"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instruccions ands
ands_inst 'Instrucción de ands'
  = _* 'ANDS'i _* rd:reg64_or_reg32 ', ' rd1:reg64_or_reg32 ', ' rd2:immediate _* comment? "\n"?

// Instrucciones de Resta 64 bits y 32 bits (SUB)  
sub_inst
    = _* "SUB"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?

    / _* "SUB"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones de Multiplicación 64 bits y 32 bits (MUL)
mul_inst
    = _* "MUL"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "MUL"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones de División 64 bits y 32 bits (DIV)
div_inst
    = _* "DIV"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "DIV"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones de División sin signo 64 bits y 32 bits (UDIV)
udiv_inst
    = _* "UDIV"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "UDIV"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones de División con signo 64 bits y 32 bits (SDIV)
sdiv_inst
    = _* "SDIV"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "SDIV"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones AND 64 bits y 32 bits (AND)        
and_inst
    = _* "AND"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "AND"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones OR 64 bits y 32 bits (ORR)
orr_inst
    = _* "ORR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "ORR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones XOR 64 bits y 32 bits (EOR)
eor_inst
    = _* "EOR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    / _* "EOR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucción MOV 64 bits y 32 bits (MOV)
mov_inst "Instrucción MOV"
  = _* "MOV"i _* rd:reg64_or_reg32 _* "," _* src:mov_source _* comment? "\n"?

reg64_or_reg32 "Registro de 64 o 32 Bits"
  = i:reg64             {return i;}
  / i:reg32             {return i;}

mov_source "Source para MOV"
  = i:reg64_or_reg32    {return i;}
  / i:immediate         {return i;}

//  Instucción Load Register (LDR)
ldr_inst "Instrucción LDR"
    = _* "LDR"i _* rd:reg64 _* "," _* src:ldr_source _* comment? "\n"?
    / _* "LDR"i _* rd:reg32 _* "," _* src:ldr_source _* comment? "\n"?

ldr_source 
    = "=" l:label

    / "[" _* r:reg64_or_reg32 _* "," _* r2:reg64_or_reg32 _* "," _* s:shift_op _* i2:immediate _* "]"

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* s:shift_op _* i2:immediate _* "]"

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* e:extend_op _* "]" 

    / "[" _* r:reg64 _* "," _* i:immediate _* "]"
 
    / "[" _* r:reg64 _* "]"


// Instrucción Load Register (LDRB)
ldrb_inst "Instrucción LDRB"
    = _* "LDRB"i _* rd:reg64 _* "," _* src:ldr_source _* comment? "\n"?

    / _* "LDRB"i _* rd:reg32 _* "," _* src:ldr_source _* comment? "\n"?


// Instrucción Load Pair Register (LDP)
ldp_inst "Instrucción LDP"
    = _* "LDP"i _* rd:reg64 _* "," _* rd2:reg64 _* "," _* src:ldr_source _* comment? "\n"?

    / _* "LDP"i _* rd:reg32 _* "," _* rd2:reg32 _* "," _* src:ldr_source _* comment? "\n"?


// Instrucción Store Register (STR)
str_inst "Instrucción STR"
    = _* "STR"i _* rd:reg64 _* "," _* src:str_source _* comment? "\n"?

    / _* "STR"i _* rd:reg32 _* "," _* src:str_source _* comment? "\n"?

str_source 
    = "[" _* r:reg64_or_reg32 _* "," _* r2:reg64_or_reg32 _* "," _* s:shift_op _* i2:immediate _* "]"

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* s:shift_op _* i2:immediate _* "]"

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* e:extend_op _* "]" 

    / "[" _* r:reg64 _* "," _* i:immediate _* "]"
        {
            return [r, i];
        }
    / "[" _* r:reg64 _* "]"
        {
            return [r];
        }

// Instrucción Store Register Byte (STRB)
strb_inst "Instrucción STRB"
    = _* "STRB"i _* rd:reg64 _* "," _* src:str_source _* comment? "\n"?

    / _* "STRB"i _* rd:reg32 _* "," _* src:str_source _* comment? "\n"?

// Instrucción Store Pair Register (STP)
stp_inst "Instrucción STP"
    = _* "STP"i _* rd:reg64 _* "," _* rd2:reg64 _* "," _* src:str_source _* comment? "\n"?

    / _* "STP"i _* rd:reg32 _* "," _* rd2:reg32 _* "," _* src:str_source _* comment? "\n"?

// Instrucción Move Not (MVN)
mvn_inst "Instrucción MVN"
    = _* "MVN"i _* rd:reg64 _* "," _* src:mov_source _* comment? "\n"?

    / _* "MVN"i _* rd:reg32 _* "," _* src:mov_source _* comment? "\n"?

// Instrucción Logial Shift Left (LSL)
lsl_inst "Instrucción LSL"
    = _* "LSL"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?

    / _* "LSL"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucción Logial Shift Right (LSR)
lsr_inst "Instrucción LSR"
    = _* "LSR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?

    / _* "LSR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucción Arithmetical Shift Right (ASR)
asr_inst "Instrucción ASR"
    = _* "ASR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?

    / _* "ASR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucción Rotate Right (ROR)
ror_inst "Instrucción ROR"
    = _* "ROR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?

    / _* "ROR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucción Compare (CMP)
cmp_inst "Instrucción CMP"
    = _* "CMP"i _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?

    / _* "CMP"i _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucción registro  (CSEL)
csel_inst 'Instruccion CSEL'
  = _* 'csel'i _* rn0:reg64_or_reg32 ', '  _* rn1:reg64_or_reg32 ', '  _* rn3:reg64_or_reg32 ', '  cond _* comment? "\n"?

// Instucción de select (CST)
cset_inst 
  = _* 'cset' _* rn0:reg32 ', ' cond _* comment? "\n"?

// Instrucción Branch (B)
b_inst "Instrucción B"
    = _* "B"i _* l:label _* comment? "\n"?

// Instrucción Branch with Link (BL)
bl_inst "Instrucción BL"
    = _* "BL"i _* l:label _* comment? "\n"?

ble_inst
  = _* 'BLE'i _* label _* comment? "\n"?

// Instrucción Retornar de Subrutina (RET)
ret_inst "Instrucción RET"
    = _* "RET"i _* comment? "\n"?

// Instrucción Salto Condicional (BEQ)
beq_inst "Instrucción BEQ"
    = _* "BEQ"i _* l:label _* comment? "\n"?

// Instrucción Salto Condicional (BNE)
bne_inst "Instrucción BNE"
    = _* "BNE"i _* l:label _* comment? "\n"?

// Instrucción Salto Condicional (BGT)
bgt_inst "Instrucción BGT"
    = _* "BGT"i _* l:label _* comment? "\n"?

// Instrucción Salto Condicional (BLT)
blt_inst "Instrucción BLT"
    = _* "BLT"i _* l:label _* comment? "\n"?

// Instrucción Supervisor Call (SVC)
svc_inst "Instrucción SVC"
    = _* "SVC"i _* i:immediate _* comment? "\n"?

// Instruccion de (UTXB)
uxtb_inst 'instruccion uxtb' 
    = _* 'UXTB'i _* i64:reg64 ',' _* i32:reg32

// Registros de propósito general 64 bits (limitado a los registros válidos de ARM64)
reg64 "Registro_64_Bits"
    = "x"i ("30" / [12][0-9] / [0-9])
    / "SP"i // Stack Pointer
        
    / "LR"i  // Link Register

    / "ZR"i  // Zero Register

// Registros de propósito general 32 bits (limitado a los registros válidos de ARM64)
reg32 "Registro_32_Bits"
    = "w"i ("30" / [12][0-9] / [0-9])
// Operando puede ser un registro o un número inmediato
operand64 "Operandor 64 Bits"
    = r:reg64 _* "," _* ep:extend_op                 // Registro con extensión de tamaño

    / r:reg64 lp:(_* "," _* shift_op _* immediate)?  // Registro con desplazamiento lógico opcional
  
    / i:immediate                                     // Valor inmediato                          

// Operando puede ser un registro o un número inmediato
operand32 "Operandor 32 Bits"
    = r:reg32 lp:(_* "," _* shift_op _* immediate)?  // Registro con desplazamiento lógico

    / i:immediate                             // Valor inmediato


// Definición de desplazamientos
shift_op "Operador de Desplazamiento"
    = "LSL"i

    / "LSR"i

    / "ASR"i

// Definición de extensiones
extend_op "Operador de Extensión"
    = "UXTB"i

    / "UXTH"i 

    / "UXTW"i 

    / "UXTX"i
 
    / "SXTB"i

    / "SXTH"i

    / "SXTW"i 

    / "SXTX"i
// condicional 
cond 'condicional_csel'
  = 'eq'i / 'ne'i / 'gt'i / 'ge'i / 'lt'i / 'le'i / 'hi'i / 'ls'i 

// Definición de valores inmediatos
immediate "Inmediato"
    =  "#"? "0b" int:binary_literal {return int;}

    / "#"? "0x" hex_literal

    / "#"? int:integer {return int; }

    / "#"? "'" le:letter "'" {return le;}

binary_literal 
  = [01]+ {return parseInt(text(), 2);} // Representa uno o más dígitos binarios
hex_literal
    = [0-9a-fA-F]+ // Representa uno o más dígitos hexadecimales
letter
    = [a-zA-Z] {return text();}

// Expresiones
expression "Espresión"
    = i:label {return i;}
    / i:integer {return i;}

// Etiqueta
label "Etiqueta"
    = id:[a-zA-Z_][a-zA-Z0-9_]*
    {
      let completeId = id[0]+id[1]?.join('');
      return completeId; 
    }

// Número entero
integer "Numero Entero"
    = '-'? [0-9]+  {return parseInt(text(), 10);}

// Cadena ASCII
string "Cadena de Texto"
    = '"' ([^"]*) '"' {return text();}

// Línea en blanco
blank_line "Linea En Blanco"
    = _* comment? "\n"{}


// Comentarios
comment "Comentario"
    = ("//" [^\n]*) {}
	/ (";" [^\n]*)  {}


mcomment "Comentario Multilinea"
    = "/*" ([^*] / [*]+ [^*/])* "*/" {}

// Espacios en blanco
_ "Ignorado"
    = [ \t]+ {}
