
let quadTable, dataTable, symbolTable, Arm64Editor, consoleResult, modalInstance, errorTable;

$(document).ready(function () {

    quadTable = newDataTable('#quadTable',
        [{data: "Op"}, {data: "Arg1"}, {data: "Arg2"}, {data: "Arg3"}, {data: "Result"}],
        []);
    
    dataTable = newDataTable('#dataTable',
        [{data: "Register"}, {data: "Data"}],
        []);

    // Inicializar la tabla de errores
    errorTable = newDataTable('#errorTable',
    [{data: "No"}, {data: "Descripción"}, {data: "Línea"}, {data: "Columna"}, {data: "Tipo"}],
     []);



    $('.tabs').tabs();
    $("select").formSelect();
    $('.tooltipped').tooltip();

    Arm64Editor = editor('julia__editor', 'text/x-rustsrc');
    consoleResult = editor('console__result', '', false, true, false);
    
    // Inicializar los modales
    let elems = document.querySelectorAll('.modal');
    M.Modal.init(elems);
    
    // Obtener la instancia del modal
    modalInstance = M.Modal.getInstance(document.getElementById('modal1'));
    dataTable.order([0, 'asc']).draw();
    
});

function handleSubmit() {
    return new Promise((resolve, reject) => {
        document.getElementById('modalForm').addEventListener('submit', function(event) {
            event.preventDefault();
            const inputValue = document.getElementById('modal_input_value').value;
            document.getElementById('modal_input_value').value = '';
            M.updateTextFields();
            modalInstance.close();
            resolve(inputValue);
        }, { once: true });
    });
}

window.openModal = function() {
    modalInstance.open();
    return handleSubmit();
};

window.closeModal = function() {
    modalInstance.close();
};

function editor(id, language, lineNumbers = true, readOnly = false, styleActiveLine = true) {
    return CodeMirror.fromTextArea(document.getElementById(id), {
        lineNumbers: true,
        styleActivateLine: true,
        matchBrackets: true,
        theme: "moxer",
        mode: "text/x-rustsrc"
    });
}

const openFile = async (editor) => {
    const {value: file} = await Swal.fire({
        title: 'Select File',
        input: 'file',

    })
    if (!file) return

    let reader = new FileReader();

    reader.onload = (e) => {
        const file = e.target.result;
        editor.setValue(file);
    }
    reader.onerror = (e) => {
        // console.log("Error to read file", e.target.error)
    }
    reader.readAsText(file)
}

const saveFile = async (fileName, extension, editor) => {
    if (!fileName) {
        const {value: name} = await Swal.fire({
            title: 'Enter File name',
            input: 'text',
            inputLabel: 'File name',
            showCancelButton: true,
            inputValidator: (value) => {
                if (!value) {
                    return 'You need to write something!'
                }
            }
        })
        fileName = name;
    }
    if (fileName) {
        download(`${fileName}.${extension}`, editor.getValue())
    }
}

const download = (name, content) => {
    let blob = new Blob([content], {type: 'text/plain;charset=utf-8'})
    let link = document.getElementById('download');
    link.href = URL.createObjectURL(blob);
    link.setAttribute("download", name)
    link.click()
}

const cleanEditor = (editor,consola) => {
    editor.setValue("");
    consola.setValue("");
    clearQuadTable();
    clearDataTable();
    clearCST();
}

const clearCST = () => {
    if (network) {
        network.destroy();
        network = undefined;
    }
    const container = document.getElementById('mynetwork');
    if (container) {
        container.innerHTML = ''; // Limpia el contenido del contenedor
    }
};



function isLexicalError(e) {
    const validIdentifier = /^[a-zA-Z_$][a-zA-Z0-9_$]*$/;
    const validInteger = /^[0-9]+$/;
    const validRegister = /^[a-zA-Z][0-9]+$/;
    const validCharacter = /^[a-zA-Z0-9_$,\[\]#"]$/;
    if (e.found) {
      if (!validIdentifier.test(e.found) && 
          !validInteger.test(e.found) &&
          !validRegister.test(e.found) &&
          !validCharacter.test(e.found)) {
        return true; // Error léxico
      }
    }
    return false; // Error sintáctico
}

const analysis = async () => {
    // ****************** Tiempo inicial
    const start = performance.now();
    const text = Arm64Editor.getValue();
    clearQuadTable();
    clearDataTable();
    try {
        // Creando ast auxiliar
        let ast = new Ast();
        // Creando entorno global
        let env = new Environment(null, 'Global');
        // Creando generador
        let gen = new Generator();
        // Obteniendo raiz del árbol
        let result = PEGGY.parse(text);
        // Guardando data (variables)
        await DataSectionExecuter(result, ast, env, gen);
        // Ejecutando instrucciones
        await RootExecuter(result, ast, env, gen);
        // Generando gráfica
        generateCst(result.CstTree);
        // Generando cuádruplos
        addDataToQuadTable(gen.getQuadruples());
        // Generando data
        addDataTable(ast.registers?.getRegisterHexa());
        // Ordenando la tabla después de agregar los datos
        dataTable.order([0, 'asc']).draw();
        // Agregando salida válida en consola
        if (ast.getErrors()?.length === 0) consoleResult.setValue(ast.getConsole());
        else consoleResult.setValue('Se encontraron algunos errores en la ejecución.');
    } catch (e) {
        if (e instanceof PEGGY.SyntaxError) {
            if (isLexicalError(e)) {
                consoleResult.setValue('Error Léxico: ' + e.message);
                // console.log("quiero ver que me devuelve", consoleResult.setValue('Error Léxico: ' + e.message));
            } else {
                consoleResult.setValue('Error Sintáctico: ' + e.message);
                // console.log("quiero ver que me devuelve", consoleResult.setValue('Error Sintáctico: ' + e.message));

            }
        } else {
            console.error('Error desconocido:', e);
        }
        fillErrorTable([e]);
    }
    // ****************** Tiempo final
    const end = performance.now();
    let generalTime = (end - start).toFixed(2);
    // Mostrar mensaje en pantalla
    mostrarToast(`
        <span><i class="material-icons left">access_time</i>
            Tiempo de ejecución: ${generalTime} ms.
        </span>`, 5000, 'rounded red');
}

// Función para agregar datos a la tabla de cuadruplos
const addDataToQuadTable = (data) => {
    for (let quad of data) {
        quadTable.row.add(quad?.getQuadruple()).draw();
    }
}

// Función para agregar dataos
const addDataTable = (data) => {
    for (let da of data) {
        dataTable.row.add(da).draw(); // Agrega cada dato y llama a draw() para actualizar la tabla
    }
    // Ordena la tabla después de agregar los datos
    dataTable.order([0, 'asc']).draw(); // Ordena por la primera columna de forma ascendente
}



const clearDataTable = () => {
    dataTable.clear().draw();
    errorTable.clear().draw();
}

const clearQuadTable = () => {
    quadTable.clear().draw();
}

// Función para mostrar un toast
function mostrarToast(mensaje, duracion, type) {
    M.toast({html: mensaje, displayLength: duracion, classes: type});
}

let network;
const generateCst = (CstObj) => {
    // Creando el arreglo de nodos
    let nodes = new vis.DataSet(CstObj.Nodes);
    // Creando el arreglo de conexiones
    let edges = new vis.DataSet(CstObj.Edges);
    // Obteniendo el elemento a imprimir
    let container = document.getElementById('mynetwork');
    // Agregando data y opciones
    let data = {
        nodes: nodes,
        edges: edges
    };

    let options = {
        layout: {
            hierarchical: {
                direction: "UD",
                sortMethod: "directed",
            },
        },
        nodes: {
            shape: "box"
        },
        edges: { 
            arrows: "to",
        },
    };

    // Generando grafico red
    network = new vis.Network(container, data, options);
}

const newDataTable = (id, columns, data) => {
    let result = $(id).DataTable({
        responsive: true,
        lengthMenu: [[15, 25, 50, -1], [15, 25, 50, "All"]],
        "lengthChange": true,
        data,
        columns,
        searching: true,
         columnDefs: [
            { type: 'num', targets: 0 }
        ],
        language: {
            "sProcessing":     "Procesando...",
            "sLengthMenu":     "Mostrar _MENU_ registros",
            "sZeroRecords":    "No se encontraron resultados",
            "sEmptyTable":     "Ningún dato disponible en esta tabla",
            "sInfo":           "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoEmpty":      "Mostrando registros del 0 al 0 de un total de 0 registros",
            "sInfoFiltered":   "(filtrado de un total de _MAX_ registros)",
            "sInfoPostFix":    "",
            "sSearch":         "Buscar:",
            "sUrl":            "",
            "sInfoThousands":  ",",
            "sLoadingRecords": "Cargando...",
            "oPaginate": {
                "sFirst":    "Primero",
                "sLast":     "Último",
                "sNext":     "Siguiente",
                "sPrevious": "Anterior"
            },
            "oAria": {
                "sSortAscending":  ": Activar para ordenar la columna de manera ascendente",
                "sSortDescending": ": Activar para ordenar la columna de manera descendente"
            }
        },
        order: [[0, 'asc']]
    });
    $('select').formSelect();
    return result;
}

const btnOpen = document.getElementById('btn__open'),
    btnSave = document.getElementById('btn__save'),
    btnClean = document.getElementById('btn__clean'),
    btnShowCst = document.getElementById('btn__showCST'),
    btnAnalysis = document.getElementById('btn__analysis');

// btnOpen.addEventListener('click', () => openFile(Arm64Editor));
btnSave.addEventListener('click', () => saveFile("file", "s", Arm64Editor));
btnClean.addEventListener('click', () => cleanEditor(Arm64Editor,consoleResult));
btnAnalysis.addEventListener('click', async () => await analysis());



function CargarArchivo() {
    const fileInput = document.getElementById('fileInput');
    const file = fileInput.files[0];

    if (file) {
        const reader = new FileReader();

        reader.onload = function(e) {
            const content = e.target.result;
            
            // Establecer el contenido en el editor CodeMirror
            Arm64Editor.setValue(content);

            // Opcional: Actualizar el número de líneas si es necesario
            Arm64Editor.refresh();

            console.log(content);
            fileInput.value = '';
        };

        reader.readAsText(file);
    }

}

function fillErrorTable(errors) {
    // Limpiar la tabla antes de agregar nuevos datos
    errorTable.clear().draw();

    // Recorrer cada error y agregarlo a la tabla
    errors.forEach((error, index) => {
        let tipoError = isLexicalError(error) ? 'Léxico' : 'Sintáctico';
        errorTable.row.add({
            No: index + 1,
            Descripción: error.message,
            Línea: error.location.start.line,
            Columna: error.location.start.column,
            Tipo: tipoError
        }).draw();
    });
}
