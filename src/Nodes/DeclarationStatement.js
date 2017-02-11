import ASTNode from "./ASTNode";
export default class DeclarationStatement extends ASTNode {
    constructor(position, modifier, [identifier, type], expression) {
        super(position);
        this.modifier = modifier;
        this.identifier = identifier;
        this.type = type;
        this.expression = expression;
    }
}
