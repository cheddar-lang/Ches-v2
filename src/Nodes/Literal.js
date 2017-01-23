import ASTNode from './ASTNode';
export default class Literal extends ASTNode {
    constructor(position, value) {
        super(position);
        this.value = value;
    }
}
