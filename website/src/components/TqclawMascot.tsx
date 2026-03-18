/**
 * TQ-Claw mascot (same as logo symbol). Used in Hero and Nav.
 */
import { CatPawIcon } from "./CatPawIcon";

interface TqclawMascotProps {
  size?: number;
  className?: string;
}

export function TqclawMascot({ size = 80, className = "" }: TqclawMascotProps) {
  return <CatPawIcon size={size} className={className} />;
}
