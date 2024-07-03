
const RootExecuter = (root, ast, env, gen) => {
    const instructions = root?.textSection?.instructions ?? [];
    instructions.forEach(inst => {
        inst.execute(ast, env, gen);       
    });
}
const DataSectionExecuter = async (root, ast, env, gen) => {
    const instructions = root?.dataSection ?? [];
    await instructions.forEach(async inst => {
        inst.execute(ast, env, gen);
    });
}