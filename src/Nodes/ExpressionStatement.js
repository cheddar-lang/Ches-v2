import ASTNode from "./ASTNode";
export default class ExpressionStatement extends ASTNode {
    constructor(position, expression) {
        super(position);
        this.expression = expression;
    }
}
