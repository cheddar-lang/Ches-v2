import ASTNode from './ASTNode';
export default class ArgumentList extends ASTNode {
    constructor(position, args) {
        super(position);
        this.args = args;
    }
}
