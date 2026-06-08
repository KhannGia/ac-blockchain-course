export class SmartContract {
    private message: string;

    constructor(initialMessage: string) {
        // Defensive runtime guard: only accept a string, otherwise fall back to "".
        this.message = isString(initialMessage) ? initialMessage : "";
    }

    public updateMessage(newMsg: string): void {
        // Silently reject non-string input; keep the previous message (non-throwing).
        if (isString(newMsg)) {
            this.message = newMsg;
        }
    }

    public getMessage(): string {
        return this.message;
    }
}

function isString(value: unknown): value is string {
    return typeof value === "string";
}
