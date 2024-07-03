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
        let new1,new2;
        // Validar tipo de valor 1
        if(this.arg1 instanceof Expression) new1 = this.arg1?.execute(ast, env, gen);
        else new1 = ast.registers?.getRegister(this.arg1);
        
        // Validar tipo de valor 2
        if(this.arg2 instanceof Expression) new2 = this.arg2?.execute(ast, env, gen);
        else new2 = ast.registers?.getRegister(this.arg2);
        
        // Validaciones 1
        if (new1 === null) ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        
        // Validaciones 2
        if (new2 === null) ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        
        let newV;
        try {
            newV = new1/new2; 
        } catch (error) {
            ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        }
        // Set register
        let setReg = ast.registers?.setRegister(this.arg3, newV);
        if (setReg === null) ast.setNewError({ msg: `El registro de destino es incorrecto.`, line: this.line, col: this.col});
    }
}