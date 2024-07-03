
let quadTable, symbolTable, Arm64Editor, consoleResult, generalTime;
let errorTable;

$(document).ready(function () {

    quadTable = newDataTable('#quadTable',
        [{data: "Op"}, {data: "Arg1"}, {data: "Arg2"}, {data: "Arg3"}, {data: "Result"}],
        []);
    
        // Inicializar la tabla de errores
    errorTable = newDataTable('#errorTable',
        [{data: "No"}, {data: "Descripción"}, {data: "Línea"}, {data: "Columna"}, {data: "Tipo"}],
        []);
        // Llenar la tabla de errores con datos estáticos
    fillErrorTable();

    $('.tabs').tabs();
    $("select").formSelect();
    $('.tooltipped').tooltip();

    Arm64Editor = editor('julia__editor', 'text/x-rustsrc');
    consoleResult = editor('console__result', '', false, true, false);
});

function editor(id, language, lineNumbers = true, readOnly = false, styleActiveLine = true) {
    return CodeMirror.fromTextArea(document.getElementById(id), {
        lineNumbers: true,
        styleActivateLine: true,
        matchBrackets: true,
        theme: "moxer",
        mode: "text/x-rustsrc"
    });
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
}

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
    try {
        // Creando ast auxiliar
        //let ast = new Ast();
        // Creando entorno global
        //let env = new Environment(null, 'Global');
        // Creando generador
        let gen = new Generator();
        // Obteniendo árbol
        let result = PEGGY.parse(text);
        // Ejecutando instrucciones
        //RootExecuter(result, ast, env, gen);
        // Generando gráfica
        console.log(result)
        generateCst(result);
        // Generando cuádruplos
        //addDataToQuadTable(gen.getQuadruples());
        // Agregando salida válida en consola
        consoleResult.setValue("VALIDO");
    } catch (e) {
        if (e instanceof PEGGY.SyntaxError) {
            if (isLexicalError(e)) {
                consoleResult.setValue('Error Léxico: ' + e.message);
            } else {
                consoleResult.setValue('Error Sintáctico: ' + e.message);
            }
        } else {
            console.error('Error desconocido:', e);
            consoleResult.setValue("No VALIDO");
        }
    }
    // ****************** Tiempo final
    const end = performance.now();
    generalTime = (end - start).toFixed(2);
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

const clearQuadTable = () => {
    quadTable.clear().draw();
}

// Función para mostrar un toast
function mostrarToast(mensaje, duracion, type) {
    M.toast({html: mensaje, displayLength: duracion, classes: type});
}


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
    let network = new vis.Network(container, data, options);
}

function newDataTable(id, columns, data) {
    let result = $(id).DataTable({
        responsive: true,
        lengthMenu: [[15, 25, 50, -1], [15, 25, 50, "Todos"]],
        lengthChange: true,
        data,
        columns,
        searching: true,  // Habilitar búsqueda
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
        }
    });
    $('select').formSelect();
    return result;
}

// Función para agregar datos a la tabla de errores
// const addDataToErrorTable = (data) => {
//     for (let error of data) {
//         errorTable.row.add(error).draw();
//     }
// }

function fillErrorTable() {
    const staticErrors = [
        { No: 1, Descripción: 'Caracter no reconocido', Línea: 1, Columna: 5, Tipo: 'Léxico' },
        { No: 2, Descripción: 'Paréntesis no balanceados', Línea: 2, Columna: 10, Tipo: 'Sintáctico' },
        { No: 3, Descripción: 'Variable no definida', Línea: 3, Columna: 15, Tipo: 'Semántico' },
        { No: 4, Descripción: 'Número no válido', Línea: 4, Columna: 20, Tipo: 'Léxico' },
        { No: 5, Descripción: 'Falta punto y coma', Línea: 5, Columna: 25, Tipo: 'Sintáctico' },
        { No: 6, Descripción: 'Falta punto y coma', Línea: 6, Columna: 26, Tipo: 'Sintáctico' }
    ];

    for (let error of staticErrors) {
        errorTable.row.add(error).draw();
    }
}

const clearErrorTable = () => {
    errorTable.clear().draw();
}

    btnOpen = document.getElementById('btn__open'),
    btnSave = document.getElementById('btn__save'),
    btnClean = document.getElementById('btn__clean'),
    btnShowCst = document.getElementById('btn__showCST'),
    btnAnalysis = document.getElementById('btn__analysis');

//btnOpen.addEventListener('click', () => openFile(Arm64Editor));
btnSave.addEventListener('click', () => saveFile("file", "s", Arm64Editor));
btnClean.addEventListener('click', () => cleanEditor(Arm64Editor,consoleResult));
btnAnalysis.addEventListener('click', () => analysis());

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