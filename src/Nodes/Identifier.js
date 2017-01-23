import ASTNode from './ASTNode';
export default class Identifier extends ASTNode {
    constructor(position, value) {
        super(position);
        this.value = value;
    }
}
