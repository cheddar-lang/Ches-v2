import ASTNode from './ASTNode';
export default class EvaluatedIdentifier extends ASTNode {
    constructor(position, expression) {
        super(position);
        this.expression = expression
    }
}
