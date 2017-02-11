import ASTNode from './ASTNode';
export default class Lambda extends ASTNode {
    constructor(position, args, body) {
        super(position);

        this.args = args;
        this.body = body;
    }
}
