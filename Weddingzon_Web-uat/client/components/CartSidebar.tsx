'use client';

import React from 'react';
import { useCart } from '@/app/context/CartContext';
import { X, Minus, Plus, ShoppingBag, Trash2, ArrowRight } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function CartSidebar() {
    const { cart, isCartOpen, toggleCart, updateQuantity, removeFromCart, cartTotal, clearCart } = useCart();
    const router = useRouter();

    if (!isCartOpen) return null;

    return (
        <div className="fixed inset-0 z-50 overflow-hidden">
            {/* Overlay */}
            <div
                className="absolute inset-0 bg-black bg-opacity-50 transition-opacity backdrop-blur-sm"
                onClick={toggleCart}
            ></div>

            {/* Sidebar */}
            <div className="absolute inset-y-0 right-0 max-w-full flex">
                <div className="w-screen max-w-md bg-white shadow-xl flex flex-col h-full animate-slide-in-right">
                    {/* Header */}
                    <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100 bg-white z-10">
                        <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                            <ShoppingBag className="w-5 h-5 text-pink-600" />
                            Your Cart ({cart.length})
                        </h2>
                        <button
                            onClick={toggleCart}
                            className="p-2 rounded-full hover:bg-gray-100 transition-colors"
                        >
                            <X className="w-5 h-5 text-gray-500" />
                        </button>
                    </div>

                    {/* Cart Items */}
                    <div className="flex-1 overflow-y-auto px-6 py-4 space-y-6 custom-scrollbar">
                        {cart.length === 0 ? (
                            <div className="h-full flex flex-col items-center justify-center text-center space-y-4">
                                <div className="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center">
                                    <ShoppingBag className="w-10 h-10 text-gray-300" />
                                </div>
                                <div>
                                    <h3 className="text-lg font-semibold text-gray-900">Your cart is empty</h3>
                                    <p className="text-gray-500 mt-1">Looks like you haven't added anything yet.</p>
                                </div>
                                <button
                                    onClick={toggleCart}
                                    className="px-6 py-2 bg-pink-600 text-white rounded-full font-medium hover:bg-pink-700 transition-colors"
                                >
                                    Start Shopping
                                </button>
                            </div>
                        ) : (
                            cart.map((item) => (
                                <div key={item._id} className="flex gap-4 group">
                                    {/* Image */}
                                    <div className="w-24 h-24 flex-shrink-0 bg-gray-100 rounded-xl overflow-hidden border border-gray-100">
                                        <img
                                            src={item.image}
                                            alt={item.name}
                                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                                        />
                                    </div>

                                    {/* Details */}
                                    <div className="flex-1 flex flex-col justify-between">
                                        <div>
                                            <div className="flex justify-between items-start">
                                                <h3 className="font-semibold text-gray-900 line-clamp-2 text-sm leading-snug">
                                                    {item.name}
                                                </h3>
                                                <button
                                                    onClick={() => removeFromCart(item._id)}
                                                    className="p-1 text-gray-300 hover:text-red-500 transition-colors"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                            <p className="text-xs text-gray-500 mt-1">Sold by {item.vendorName}</p>
                                        </div>

                                        <div className="flex items-center justify-between mt-2">
                                            <div className="flex items-center gap-3 bg-gray-50 rounded-lg p-1">
                                                <button
                                                    onClick={() => updateQuantity(item._id, item.quantity - 1)}
                                                    className="p-1 hover:bg-white rounded-md transition-shadow hover:shadow-sm disabled:opacity-50"
                                                    disabled={item.quantity <= 1}
                                                >
                                                    <Minus className="w-3 h-3 text-gray-600" />
                                                </button>
                                                <span className="text-sm font-medium w-4 text-center">{item.quantity}</span>
                                                <button
                                                    onClick={() => updateQuantity(item._id, item.quantity + 1)}
                                                    className="p-1 hover:bg-white rounded-md transition-shadow hover:shadow-sm"
                                                >
                                                    <Plus className="w-3 h-3 text-gray-600" />
                                                </button>
                                            </div>
                                            <div className="font-bold text-gray-900">
                                                ₹{(item.price * item.quantity).toLocaleString()}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>

                    {/* Footer */}
                    {cart.length > 0 && (
                        <div className="border-t border-gray-100 bg-white p-6 space-y-4 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)]">
                            <div className="space-y-2">
                                <div className="flex justify-between text-gray-500 text-sm">
                                    <span>Subtotal</span>
                                    <span>₹{cartTotal.toLocaleString()}</span>
                                </div>
                                <div className="flex justify-between text-lg font-bold text-gray-900">
                                    <span>Total</span>
                                    <span>₹{cartTotal.toLocaleString()}</span>
                                </div>
                                <p className="text-xs text-gray-400 text-center">Shipping & taxes calculated at checkout</p>
                            </div>

                            <button className="w-full bg-pink-600 text-white py-3.5 rounded-xl font-bold flex items-center justify-center gap-2 hover:bg-pink-700 active:scale-[0.98] transition-all shadow-lg shadow-pink-600/20">
                                Proceed to Checkout <ArrowRight className="w-5 h-5" />
                            </button>

                            <button
                                onClick={toggleCart}
                                className="w-full py-2.5 text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors"
                            >
                                Continue Shopping
                            </button>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
