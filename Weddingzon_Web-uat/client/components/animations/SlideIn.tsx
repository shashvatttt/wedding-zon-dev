'use client';

import { motion, HTMLMotionProps } from 'framer-motion';
import { ReactNode } from 'react';

interface SlideInProps extends HTMLMotionProps<'div'> {
    children: ReactNode;
    direction?: 'up' | 'down' | 'left' | 'right';
    duration?: number;
    delay?: number;
    distance?: number;
    viewPortOnce?: boolean;
}

export const SlideIn = ({
    children,
    direction = 'up',
    duration = 0.6,
    delay = 0,
    distance = 30,
    viewPortOnce = true,
    ...props
}: SlideInProps) => {
    const directionMap = {
        up: { y: distance },
        down: { y: -distance },
        left: { x: distance },
        right: { x: -distance },
    };

    return (
        <motion.div
            initial={{
                opacity: 0,
                ...directionMap[direction]
            }}
            whileInView={{
                opacity: 1,
                x: 0,
                y: 0
            }}
            viewport={{ once: viewPortOnce }}
            transition={{
                duration,
                delay,
                ease: [0.21, 0.47, 0.32, 0.98],
            }}
            {...props}
        >
            {children}
        </motion.div>
    );
};

export default SlideIn;
