'use client';

import { motion, HTMLMotionProps } from 'framer-motion';
import { ReactNode } from 'react';

interface StaggerContainerProps extends HTMLMotionProps<'div'> {
    children: ReactNode;
    staggerDelay?: number;
    delayChildren?: number;
    viewPortOnce?: boolean;
}

export const StaggerContainer = ({
    children,
    staggerDelay = 0.1,
    delayChildren = 0,
    viewPortOnce = true,
    ...props
}: StaggerContainerProps) => {
    return (
        <motion.div
            initial="hidden"
            whileInView="show"
            viewport={{ once: viewPortOnce }}
            variants={{
                hidden: { opacity: 0 },
                show: {
                    opacity: 1,
                    transition: {
                        staggerChildren: staggerDelay,
                        delayChildren: delayChildren,
                    },
                },
            }}
            {...props}
        >
            {children}
        </motion.div>
    );
};

export const StaggerItem = ({ children, ...props }: HTMLMotionProps<'div'>) => {
    return (
        <motion.div
            variants={{
                hidden: { opacity: 0, y: 20 },
                show: { opacity: 1, y: 0 },
            }}
            transition={{
                duration: 0.5,
                ease: [0.21, 0.47, 0.32, 0.98],
            }}
            {...props}
        >
            {children}
        </motion.div>
    );
};

export default StaggerContainer;
