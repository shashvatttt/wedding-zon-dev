"use client"

import * as React from "react"
import * as SliderPrimitive from "@radix-ui/react-slider"
import { cn } from "@/lib/utils"

const Slider = React.forwardRef<
    React.ElementRef<typeof SliderPrimitive.Root>,
    React.ComponentPropsWithoutRef<typeof SliderPrimitive.Root>
>(({ className, ...props }, ref) => (
    <SliderPrimitive.Root
        ref={ref}
        className={cn(
            "relative flex w-full touch-none select-none items-center",
            className
        )}
        {...props}
    >
        <SliderPrimitive.Track className="relative h-2 w-full grow overflow-hidden rounded-full bg-secondary/30 bg-gray-200">
            <SliderPrimitive.Range className="absolute h-full bg-pink-600" />
        </SliderPrimitive.Track>
        {props.defaultValue?.map((_, index) => (
            <React.Fragment key={index}>
                <SliderPrimitive.Thumb className="block h-5 w-5 rounded-full border-2 border-pink-600 bg-white ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-pink-50" />
            </React.Fragment>
        ))}
        {/* If using value instead of defaultValue (controlled), we need to render thumbs based on value length too */}
        {props.value?.map((_, index) => (
            <React.Fragment key={index}>
                <SliderPrimitive.Thumb className="block h-5 w-5 rounded-full border-2 border-pink-600 bg-white ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-pink-50" />
            </React.Fragment>
        ))}
        {/* Fallback for single thumb if no array passed (standard fallback behavior of radix not strictly needed if we always pass array) */}
        {(!props.defaultValue && !props.value) && (
            <SliderPrimitive.Thumb className="block h-5 w-5 rounded-full border-2 border-pink-600 bg-white ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-pink-50" />
        )}
    </SliderPrimitive.Root>
))
Slider.displayName = SliderPrimitive.Root.displayName

export { Slider }
