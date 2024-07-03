class Sdiv extends Instruction {

    constructor(line, col, id, arg3,arg1,arg2) {
        super();
        this.line = line;
        this.col = col;
        this.id = id;
        this.arg1 = arg1;
        this.arg2 = arg2;
        this.arg3 = arg3;
    }

    execute(ast, env, gen) {
        let resultado, divisor, dividendo;
        // Validar tipo de valor 1
        if(this.arg1 instanceof Expression) divisor = this.arg1?.execute(ast, env, gen);
        else divisor = ast.registers?.getRegister(this.arg1);
        
        // Validar tipo de valor 2
        if(this.arg2 instanceof Expression) dividendo = this.arg2?.execute(ast, env, gen);
        else dividendo = ast.registers?.getRegister(this.arg2);
        
        console.log(new1)
        // Validaciones 1
        if (divisor === null) ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        
        // Validaciones 2
        if (dividendo === null) ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        
        try {
            resultado = divisor.value/dividendo.value; 
        } catch (error) {
            ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        }
        // Set register con un nuevo simbolo para asignarla a obj si es un nuevo registro o si cambia
        let symbolVariable = new Symbol(this.line, this.col, 'integer', 'space', resultado);
        // Set register
        let setReg = ast.registers?.setRegister(this.arg3, symbolVariable);
        console.log(setReg)
        if (setReg === null) ast.setNewError({ msg: `El registro de destino es incorrecto.`, line: this.line, col: this.col});
    }
}