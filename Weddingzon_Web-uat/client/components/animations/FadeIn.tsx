'use client';

import { motion, HTMLMotionProps } from 'framer-motion';
import { ReactNode } from 'react';

interface FadeInProps extends HTMLMotionProps<'div'> {
    children: ReactNode;
    duration?: number;
    delay?: number;
    viewPortOnce?: boolean;
}

export const FadeIn = ({
    children,
    duration = 0.5,
    delay = 0,
    viewPortOnce = true,
    ...props
}: FadeInProps) => {
    return (
        <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: viewPortOnce }}
            transition={{
                duration,
                delay,
                ease: [0.21, 0.47, 0.32, 0.98], // Custom cubic-bezier for a "premium" feel
            }}
            {...props}
        >
            {children}
        </motion.div>
    );
};

export default FadeIn;
