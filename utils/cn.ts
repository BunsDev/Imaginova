import { ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
// function to merge classes
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
