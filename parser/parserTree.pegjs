{
    class Cst {
    constructor() {
        this.Nodes = [];
        this.Edges = [];
        this.idCount = 0;
    }

    newNode(){
        let count = this.idCount; 
        this.idCount++;
        return `${count}`
    }

    addNode(id, label){
        this.Nodes.push({
            id: id, 
            label: label,
        });
    }

    addEdge(from, to){
        this.Edges.push({
            from: from, 
            to: to,
        });
    }
}
  // Creando cst 
  let cst = new Cst();
  // Agregar nodos
  function newPath(idRoot, nameRoot, nodes) {
    cst.addNode(idRoot, nameRoot);
    for (let node of nodes) {
      if (typeof node !== "string"){
        cst.addEdge(idRoot, node?.id);
        continue;
      }
      console.log(node);
      let newNode = cst.newNode();
      cst.addNode(newNode, node);
      cst.addEdge(idRoot, newNode);
    }
  }
}
// Iniciamos el análisis sintáctico con la regla inicial "start"

start
    = line:(directive / section / instruction / comment / mcomment / blank_line)* { return cst; }

// Directivas en ARM64 v8
directive
  = _* name:directive_p _* args:(directive_p / label / string / expression)? _* comment? "\n"?

//directivas name
directive_p
    = "." id:directive_name
    {
        let idRoot = cst.newNode();
        newPath(idRoot, 'GlobalSection', [id]);
        return { id: idRoot, name: id};
    }

// Nombre de las directivas
directive_name
  = di:("align" / "ascii" / "asciz" / "byte" / "hword" / "word" / "quad" / "data" / "text" / 
  "global" / "section" / "space"/ "skip" / "zero" / "incbin" / "set" / "equ" / "bss") {return di;}

// Secciones
section
  = _* label:label _* ":" _* comment? "\n"?
    {
        let idRoot = cst.newNode();
        newPath(idRoot, 'GlobalSection', [label]);
        return { id: idRoot, name: label};
    }

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
    / i:msub_inst    {return i;}
    / i:ldr_inst     {return i;}
    / i:ldrb_inst    {return i;}
    / i:ldp_inst     {return i;}
    / i:strb_inst    {return i;}
    / i:str_inst     {return i;}
    / i:stp_inst     {return i;}
    / i:lsl_inst     {return i;}
    / i:lsr_inst     {return i;}
    / i:asr_inst     {return i;}
    / i:ror_inst     {return i;}
    / i:cmp_inst     {return i;}
    / i:csel_inst    {return i;}
    / i:cset_inst    {return i;}
    / i:beq_inst     {return i;}
    / i:bne_inst     {return i;}
    / i:bgt_inst     {return i;}
    / i:blt_inst     {return i;}
    / i:ble_inst     {return i;}
    / i:bl_inst      {return i;}
    / i:b_inst       {return i;}
    / i:ret_inst     {return i;}
    / i:svc_inst     {return i;}


// Instrucciones Suma 64 bits y 32 bits (ADD)
add_inst "Instrucción de Suma"
    = _* "ADD"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['add', rd, 'COMA', src1, 'COMA', src2]);
    }

    / _* "ADD"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['add', rd, 'COMA', src1, 'COMA', src2]);
    }

// Instruccions ands
ands_inst 'Instrucción de ands'
  = _* 'ANDS'i _* rd:reg64_or_reg32 ', ' rd1:reg64_or_reg32 ', ' rd2:immediate _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['ands', rd, 'COMA', rd1, 'COMA', rd2]);
    }

// Instrucciones de Resta 64 bits y 32 bits (SUB)  
sub_inst
    = _* "SUB"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['sub', rd, 'COMA', src1, 'COMA', src2]);
    }

    / _* "SUB"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['sub', rd, 'COMA', src1, 'COMA', src2]);
    }

//Instruccion Multiply and Subtract (MSUB) x5 = (x4 * x3) - x0
msub_inst "Instruccion MSUB"
		=_* "MSUB"i _* rd:reg64 _* "," _* src1:mov_source "," _* src2:mov_source"," _* src3:mov_source _* comment? "\n"?
        {
	        const loc = location()?.start;
    	    const idRoot = cst.newNode();
        	newPath(idRoot, 'Arithmetic', ['msub', rd, 'COMA', src1, 'COMA', src2, 'COMA', src3]);
        }
        /_* "MSUB"i _* rd:reg32 _* "," _* src1:mov_source "," _* src2:mov_source"," _* src3:mov_source _* comment? "\n"?
        {
	        const loc = location()?.start;
    	    const idRoot = cst.newNode();
        	newPath(idRoot, 'Arithmetic', ['msub', rd, 'COMA', src1, 'COMA', src2, 'COMA', src3]);
        }

// Instrucciones de Multiplicación 64 bits y 32 bits (MUL)
mul_inst
    = _* "MUL"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['mul', rd, 'COMA', src1, 'COMA', src2]);
    }

    / _* "MUL"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['mul', rd, 'COMA', src1, 'COMA', src2]);
    }

// Instrucciones de División 64 bits y 32 bits (DIV)
div_inst
    = _* "DIV"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['div', rd, 'COMA', src1, 'COMA', src2]);
    }
    / _* "DIV"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['div', rd, 'COMA', src1, 'COMA', src2]);
    }

// Instrucciones de División sin signo 64 bits y 32 bits (UDIV)
udiv_inst
    = _* "UDIV"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['udiv', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "UDIV"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['udiv', rd, 'COMA', src1, 'COMA', src2]);    
    }

// Instrucciones de División con signo 64 bits y 32 bits (SDIV)
sdiv_inst
    = _* "SDIV"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['sdiv', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "SDIV"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Arithmetic', ['sdiv', rd, 'COMA', src1, 'COMA', src2]);    
    }

// Instrucciones AND 64 bits y 32 bits (AND)        
and_inst
    = _* "AND"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Logic', ['and', rd, 'COMA', src1, 'COMA', src2]);    
    }

    / _* "AND"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Logic', ['and', rd, 'COMA', src1, 'COMA', src2]);    
    }

// Instrucciones OR 64 bits y 32 bits (ORR)
orr_inst
    = _* "ORR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Logic', ['orr', rd, 'COMA', src1, 'COMA', src2]);    
    }

    / _* "ORR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?

// Instrucciones XOR 64 bits y 32 bits (EOR)
eor_inst
    = _* "EOR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Logic', ['eor', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "EOR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Logic', ['eor', rd, 'COMA', src1, 'COMA', src2]);    
    }

// Instrucción MOV 64 bits y 32 bits (MOV)
mov_inst "Instrucción MOV"
  = _* "MOV"i _* rd:reg64_or_reg32 _* "," _* src:mov_source _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'Control', ['mov', rd, 'COMA', src]);
    }

reg64_or_reg32 "Registro de 64 o 32 Bits"
  = i:reg64             {return i;}
  / i:reg32             {return i;}

mov_source "Source para MOV"
  = i:reg64_or_reg32    {return i;}
  / i:immediate         {return i;}

//  Instucción Load Register (LDR)
ldr_inst "Instrucción LDR"
    = _* "LDR"i _* rd:reg64 _* "," _* src:ldr_source _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['ldr', rd, 'COMA', src]);    
    }
    / _* "LDR"i _* rd:reg32 _* "," _* src:ldr_source _* comment? "\n"?
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['ldr', rd, 'COMA', src]);    
    }
ldr_source 
    = "=" l:label

    / "[" _* r:reg64_or_reg32 _* "," _* r2:reg64_or_reg32 _* "," _* s:shift_op _* i2:immediate _* "]"
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'array', [r, r2, s, i2]);    
    }

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* s:shift_op _* i2:immediate _* "]"
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'array', [r, i, s, i2]);    
    }
    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* e:extend_op _* "]"
   {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'array', [r, i, s, i2]);    
    }
    / "[" _* r:mov_source _* "," _* i:mov_source _* "]"
    {
        const loc = location()?.start;
        let idRoot = cst.newNode(); 
        newPath(idRoot, 'array', [r,i]);
        //return { id: idRoot, name: int }
    }    
    / "[" _* r:reg64 _* "," _* i:immediate _* "]"
    {
        const loc = location()?.start;
        let idRoot = cst.newNode(); 
        newPath(idRoot, 'array', [r,i]);
        return { id: idRoot, name: [r,i] }
    }
 
    / "[" _* r:reg64 _* "]"
    {
        const loc = location()?.start;
        let idRoot = cst.newNode(); 
        newPath(idRoot, 'array', [r]);
        return { id: idRoot, name: [r]}
    }
// Instrucción Load Register (LDRB)
ldrb_inst "Instrucción LDRB"
    = _* "LDRB"i _* rd:reg64 _* "," _* src:ldr_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['ldrb', rd, 'COMA', src]);    
    }
    / _* "LDRB"i _* rd:reg32 _* "," _* src:ldr_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['ldrb', rd, 'COMA', src]);    
    }

// Instrucción Load Pair Register (LDP)
ldp_inst "Instrucción LDP"
    = _* "LDP"i _* rd:reg64 _* "," _* rd2:reg64 _* "," _* src:ldr_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['ldp', rd, 'COMA', rd2, 'COMA', src]);    
    }
    
    / _* "LDP"i _* rd:reg32 _* "," _* rd2:reg32 _* "," _* src:ldr_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['ldp', rd, 'COMA', rd2, 'COMA', src]);    
    }
    
// Instrucción Store Register (STR)
str_inst "Instrucción STR"
    = _* "STR"i _* rd:reg64 _* "," _* src:str_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['str', rd, 'COMA', src]);    
    }
    / _* "STR"i _* rd:reg32 _* "," _* src:str_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LoadR', ['str', rd, 'COMA', src]);    
    }
str_source 
    = "[" _* r:reg64_or_reg32 _* "," _* r2:reg64_or_reg32 _* "," _* s:shift_op _* i2:immediate _* "]"

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* s:shift_op _* i2:immediate _* "]"

    / "[" _* r:reg64 _* "," _* i:immediate _* "," _* e:extend_op _* "]" 

    / "[" _* r:mov_source _* "," _* i:mov_source _* "]"

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
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'storeR', ['strb', rd, 'COMA', src]);    
    }
    / _* "STRB"i _* rd:reg32 _* "," _* src:str_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'storeR', ['strb', rd, 'COMA', src]);    
    }
// Instrucción Store Pair Register (STP)
stp_inst "Instrucción STP"
    = _* "STP"i _* rd:reg64 _* "," _* rd2:reg64 _* "," _* src:str_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'PairR', ['stp', rd2, 'COMA', rd2,'COMA', src]);    
    }
    / _* "STP"i _* rd:reg32 _* "," _* rd2:reg32 _* "," _* src:str_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'PairR', ['stp', rd2, 'COMA', rd2,'COMA', src]);   
    }
// Instrucción Move Not (MVN)
mvn_inst "Instrucción MVN"
    = _* "MVN"i _* rd:reg64 _* "," _* src:mov_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'movN', ['mvn', rd,'COMA', src]);   
    }
    / _* "MVN"i _* rd:reg32 _* "," _* src:mov_source _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'movN', ['mvn', rd2, 'COMA', src]);   
    }
// Instrucción Logial Shift Left (LSL)
lsl_inst "Instrucción LSL"
    = _* "LSL"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LogicalShiftLeft', ['lsl', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "LSL"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LogicalShiftLeft', ['lsl', rd, 'COMA', src1, 'COMA', src2]);    
    }
// Instrucción Logial Shift Right (LSR)
lsr_inst "Instrucción LSR"
    = _* "LSR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LogicalShiftRight', ['lsr', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "LSR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'LogicalShiftRight', ['lsr', rd, 'COMA', src1, 'COMA', src2]);    
    }
// Instrucción Arithmetical Shift Right (ASR)
asr_inst "Instrucción ASR"
    = _* "ASR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'ArithmShiftRight', ['asr', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "ASR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'ArithmShiftRight', ['asr', rd, 'COMA', src1, 'COMA', src2]);    
    }
// Instrucción Rotate Right (ROR)
ror_inst "Instrucción ROR"
    = _* "ROR"i _* rd:reg64 _* "," _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'rotateRight', ['ror', rd, 'COMA', src1, 'COMA', src2]);    
    }
    / _* "ROR"i _* rd:reg32 _* "," _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'rotateRight', ['ror', rd, 'COMA', src1, 'COMA', src2]);    
    }
// Instrucción Compare (CMP)
cmp_inst "Instrucción CMP"
    = _* "CMP"i _* src1:reg64 _* "," _* src2:operand64 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'compare', ['cmp', src1, 'COMA', src2]);    
    }
    / _* "CMP"i _* src1:reg32 _* "," _* src2:operand32 _* comment? "\n"?
	{
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'compare', ['cmp', src1, 'COMA', src2]);    
    }
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
    {
        const loc = location()?.start;
        const idRoot = cst.newNode();
        newPath(idRoot, 'supervisor', ['SVC', i]);
    }

// Instruccion de (UTXB)
uxtb_inst 'instruccion uxtb' 
    = _* 'UXTB'i _* i64:reg64 ',' _* i32:reg32

// Registros de propósito general 64 bits (limitado a los registros válidos de ARM64)
reg64 "Registro_64_Bits"
    = "x"i ("30" / [12][0-9] / [0-9])
    {
        let idRoot = cst.newNode(); 
        newPath(idRoot, 'register64', [text()]);
        return { id: idRoot, name: text() }
    }
    / "SP"i // Stack Pointer
        
    / "LR"i  // Link Register

    / "ZR"i  // Zero Register

// Registros de propósito general 32 bits (limitado a los registros válidos de ARM64)
reg32 "Registro_32_Bits"
    = "w"i ("30" / [12][0-9] / [0-9])
    {
        let idRoot = cst.newNode(); 
        newPath(idRoot, 'register32', [text()]);
        return { id: idRoot, name: text() }
    }
// Operando puede ser un registro o un número inmediato
operand64 "Operandor 64 Bits"
    = r:reg64 _* "," _* ep:extend_op                 // Registro con extensión de tamaño

    / r:reg64 lp:(_* "," _* shift_op _* immediate)?  {return r;}// Registro con desplazamiento lógico opcional
  
    / i:immediate   {return i;}                                 // Valor inmediato                          

// Operando puede ser un registro o un número inmediato
operand32 "Operandor 32 Bits"
    = r:reg32 lp:(_* "," _* shift_op _* immediate)?  // Registro con desplazamiento lógico

    / i:immediate {return i;}                             // Valor inmediato

// Definición de desplazamientos
shift_op "Operador de Desplazamiento"
    =  ("LSL"i / "LSR"i / "ASR"i )

// Definición de extensiones
extend_op "Operador de Extensión"
    = str:( "UXTB"i / "UXTH"i / "UXTW"i  / "UXTX"i / "SXTB"i / "SXTH"i / "SXTW"i  / "SXTX"i ) {return str; }

// condicional 
cond 'condicional_csel'
  = 'eq'i / 'ne'i / 'gt'i / 'ge'i / 'lt'i / 'le'i / 'hi'i / 'ls'i 

// Definición de valores inmediatos
immediate "Inmediato"
    =  "#"? "0b" int:binary_literal {return int+""; }

    / "#"? "0x" int:hex_literal     {return int; }

    / "#"? int:integer              
    {
        let idRoot = cst.newNode(); 
        newPath(idRoot, 'inmediate', [int]);
        return { id: idRoot, name: int }
    }

    / "#"? "'" le:letter "'" 
    {
    	return le; 
    }

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
    = '-'? [0-9]+  {return text();}

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