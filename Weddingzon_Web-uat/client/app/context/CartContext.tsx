'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import api from '../services/api';
import { useAuth } from './AuthContext';

export interface CartItem {
    _id: string; // Product ID
    name: string;
    price: number;
    image: string;
    vendorName: string;
    quantity: number;
    vendor?: { // Match backend population structure if needed, but UI uses flattened fields currently
        first_name: string;
        last_name: string;
        vendor_details?: { business_name: string };
    };
}

interface CartContextType {
    cart: CartItem[];
    isCartOpen: boolean;
    addToCart: (item: Omit<CartItem, 'quantity'>) => void;
    removeFromCart: (id: string) => void;
    updateQuantity: (id: string, quantity: number) => void;
    clearCart: () => void;
    toggleCart: () => void;
    cartTotal: number;
    cartCount: number;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export const CartProvider = ({ children }: { children: React.ReactNode }) => {
    const [cart, setCart] = useState<CartItem[]>([]);
    const [isCartOpen, setIsCartOpen] = useState(false);
    const { isAuthenticated } = useAuth();

    // Load cart from backend if authenticated, else local storage
    useEffect(() => {
        if (isAuthenticated) {
            fetchBackendCart();
        } else {
            const savedCart = localStorage.getItem('weddingzon_cart');
            if (savedCart) {
                try {
                    setCart(JSON.parse(savedCart));
                } catch (e) {
                    console.error('Failed to parse cart', e);
                }
            }
        }
    }, [isAuthenticated]);

    const fetchBackendCart = async () => {
        try {
            const res = await api.get('/cart');
            if (res.data.success) {
                // Map backend structure to frontend CartItem
                const mappedCart = res.data.data.items.map((item: any) => ({
                    _id: item.product._id,
                    name: item.product.name,
                    price: item.product.price,
                    image: item.product.images?.[0] || '',
                    vendorName: item.product.vendor?.vendor_details?.business_name || item.product.vendor?.first_name || 'Vendor',
                    quantity: item.quantity
                }));
                setCart(mappedCart);
            }
        } catch (error) {
            console.error('Failed to fetch backend cart', error);
        }
    };

    // Save cart to local storage only if NOT authenticated (as backup/guest)
    useEffect(() => {
        if (!isAuthenticated) {
            localStorage.setItem('weddingzon_cart', JSON.stringify(cart));
        }
    }, [cart, isAuthenticated]);

    const addToCart = async (product: Omit<CartItem, 'quantity'>) => {
        if (isAuthenticated) {
            try {
                await api.post('/cart/add', { productId: product._id, quantity: 1 });
                await fetchBackendCart(); // Refresh cart from server to ensure sync
                setIsCartOpen(true);
            } catch (error) {
                console.error('Add to cart failed', error);
                // Optionally show toast error
            }
        } else {
            setCart(prev => {
                const existing = prev.find(item => item._id === product._id);
                if (existing) {
                    return prev.map(item =>
                        item._id === product._id
                            ? { ...item, quantity: item.quantity + 1 }
                            : item
                    );
                }
                return [...prev, { ...product, quantity: 1 }];
            });
            setIsCartOpen(true);
        }
    };

    const removeFromCart = async (id: string) => {
        if (isAuthenticated) {
            try {
                await api.post(`/cart/remove/${id}`);
                await fetchBackendCart();
            } catch (error) {
                console.error('Remove from cart failed', error);
            }
        } else {
            setCart(prev => prev.filter(item => item._id !== id));
        }
    };

    const updateQuantity = async (id: string, quantity: number) => {
        if (quantity < 1) return;

        if (isAuthenticated) {
            try {
                await api.patch(`/cart/update/${id}`, { quantity });
                await fetchBackendCart();
            } catch (error) {
                console.error('Update quantity failed', error);
            }
        } else {
            setCart(prev => prev.map(item =>
                item._id === id ? { ...item, quantity } : item
            ));
        }
    };

    const clearCart = async () => {
        if (isAuthenticated) {
            try {
                await api.delete('/cart');
                setCart([]);
            } catch (error) {
                console.error('Clear cart failed', error);
            }
        } else {
            setCart([]);
        }
    };

    const toggleCart = () => {
        setIsCartOpen(prev => !prev);
    };

    const cartTotal = cart.reduce((total, item) => total + (item.price * item.quantity), 0);
    const cartCount = cart.reduce((count, item) => count + item.quantity, 0);

    return (
        <CartContext.Provider value={{
            cart,
            isCartOpen,
            addToCart,
            removeFromCart,
            updateQuantity,
            clearCart,
            toggleCart,
            cartTotal,
            cartCount
        }}>
            {children}
        </CartContext.Provider>
    );
};

export const useCart = () => {
    const context = useContext(CartContext);
    if (!context) {
        throw new Error('useCart must be used within a CartProvider');
    }
    return context;
};
