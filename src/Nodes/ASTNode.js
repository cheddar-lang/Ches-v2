class Position {
    constructor({ first_line, last_line, first_column, last_column }) {
        this.firstLine = first_line;
        this.lastLine  = last_line;
        this.firstColumn = first_column;
        this.lastColumn = last_column;
    }

    getWidth() {
        return this.lastColumn - this.firstColumn;
    }
}

export default class ASTNode {
    constructor(position) {
        // this.position = new Position(position);
    }
}
