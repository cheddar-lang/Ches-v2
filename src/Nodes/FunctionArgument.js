import ASTNode from './ASTNode';
export default class FunctionArgument extends ASTNode {
    constructor(position, [ name, type ], optional) {
        super(position);

        this.name = name;
        this.type = type;

        this.optional = optional
    }
}
