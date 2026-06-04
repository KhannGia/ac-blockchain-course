import crypto from "crypto";

export type Block = {
  index: number;
  timestamp: string;
  transactions: any[];
  previous_hash: string;
  current_hash: string;
};

export function isValidBlock(block: Block): boolean {
  if (typeof block !== "object" || block === null) {
    return false;
  }

  const candidate = block as Record<string, unknown>;

  if (typeof candidate.index !== "number" || !Number.isFinite(candidate.index)) {
    return false;
  }

  if (typeof candidate.timestamp !== "string") {
    return false;
  }

  if (!Array.isArray(candidate.transactions)) {
    return false;
  }

  if (typeof candidate.previous_hash !== "string") {
    return false;
  }

  if (typeof candidate.current_hash !== "string") {
    return false;
  }

  try {
    const value =
      candidate.index +
      candidate.timestamp +
      JSON.stringify(candidate.transactions) +
      candidate.previous_hash;

    const computedHash = crypto
      .createHash("sha256")
      .update(value)
      .digest("hex");

    return computedHash === candidate.current_hash;
  } catch {
    return false;
  }
}
