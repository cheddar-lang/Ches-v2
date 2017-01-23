import ASTNode from './ASTNode';
export default class PropertyExpression extends ASTNode {
    constructor(position, head, tail) {
        super(position);
        this.head = head;
        this.tail = tail;
    }
}
