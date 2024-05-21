import { ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
// function to merge classesss
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// https://8fb7-41-215-165-227.ngrok-free.app/api/webhooks/clerk
