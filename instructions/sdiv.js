class Sdiv extends Instruction {

    constructor(line, col, id, obj, value1, value2) {
        super();
        this.line = line;
        this.col = col;
        this.id = id;
        this.obj = obj;
        this.value1 = value1;
        this.value2= value2;
    }

    execute(ast, env, gen) {
        let resultado, dividendo, divisor;
        // Validar tipo de valor
        if(this.value1 instanceof Expression) dividendo = this.value1?.execute(ast, env, gen);
        else dividendo = ast.registers?.getRegister(this.value1);
        //valida valor
        if(this.value2 instanceof Expression) divisor = this.value2?.execute(ast, env, gen);
        else divisor = ast.registers?.getRegister(this.value2);
        if (divisor.value === 0) {
            ast.setNewError({ msg: `División por cero.`, line: this.line, col: this.col });
            return;
        }
        // resultado de la division
        resultado = dividendo.value/divisor.value;
        if (resultado === null) ast.setNewError({ msg: `El valor de asignación es incorrecto.`, line: this.line, col: this.col});
        // Set register con un nuevo simbolo para asignarla a obj si es un nuevo registro o si cambia
        let symbolVariable = new Symbol(this.line, this.col, 'integer', 'space', resultado);
        let setReg = ast.registers?.setRegister(this.obj, symbolVariable);
        if (setReg === null) ast.setNewError({ msg: `El registro de destino es incorrecto.`, line: this.line, col: this.col});
    }
}