'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import api from '../../services/api';
import { Plus, Edit, Trash2, Eye, EyeOff, BookOpen, Clock, Tag } from 'lucide-react';
import { useToast } from '../../contexts/ToastContext';
import Image from 'next/image';

interface Blog {
    _id: string;
    title: string;
    slug: string;
    category: string;
    status: 'draft' | 'published';
    createdAt: string;
    coverImage: string | null;
    views: number;
    author: {
        displayName: string;
    };
}

export default function AdminBlogsPage() {
    const { addToast } = useToast();
    const router = useRouter();
    const [blogs, setBlogs] = useState<Blog[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchBlogs = async () => {
        try {
            const res = await api.get('/blogs/admin/list');
            setBlogs(res.data.data);
        } catch (error) {
            console.error('Failed to fetch blogs', error);
            addToast('Failed to load blogs', 'error');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchBlogs();
    }, []);

    const handleDelete = async (id: string) => {
        if (!confirm('Are you sure you want to delete this blog?')) return;
        try {
            await api.delete(`/blogs/${id}`);
            addToast('Blog deleted successfully', 'success');
            fetchBlogs();
        } catch (error) {
            addToast('Failed to delete blog', 'error');
        }
    };

    const toggleStatus = async (blog: Blog) => {
        try {
            const newStatus = blog.status === 'published' ? 'draft' : 'published';
            await api.put(`/blogs/${blog._id}`, { status: newStatus });
            addToast(`Blog ${newStatus === 'published' ? 'published' : 'moved to drafts'}`, 'success');
            fetchBlogs();
        } catch (error) {
            addToast('Failed to update status', 'error');
        }
    };

    if (loading) return <div className="p-8">Loading...</div>;

    return (
        <div className="p-6 max-w-7xl mx-auto">
            <div className="flex justify-between items-center mb-10">
                <div>
                    <h1 className="text-3xl font-serif font-black flex items-center gap-3 text-gray-900">
                        <BookOpen className="h-8 w-8 text-[#EF2F55]" />
                        Manage Blogs
                    </h1>
                    <p className="text-gray-500 mt-1">Create, edit and publish your wedding stories</p>
                </div>
                <button
                    onClick={() => router.push('/admin/blogs/new')}
                    className="bg-[#EF2F55] hover:bg-rose-700 text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 transition-all shadow-lg active:scale-95"
                >
                    <Plus className="h-5 w-5" />
                    New Post
                </button>
            </div>

            {blogs.length === 0 ? (
                <div className="bg-white border-2 border-dashed border-gray-200 rounded-[32px] p-20 text-center">
                    <div className="bg-pink-50 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
                        <BookOpen className="h-10 w-10 text-[#EF2F55] opacity-50" />
                    </div>
                    <h3 className="text-xl font-bold text-gray-900 mb-2">No blogs found</h3>
                    <p className="text-gray-500 mb-8 max-w-sm mx-auto">You haven't created any blog posts yet. Start by creating your first wedding story!</p>
                    <button
                        onClick={() => router.push('/admin/blogs/new')}
                        className="text-[#EF2F55] font-bold underline hover:text-rose-700 transition-colors"
                    >
                        Create your first post
                    </button>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {blogs.map((blog) => (
                        <div key={blog._id} className="bg-white rounded-[32px] overflow-hidden shadow-sm border border-gray-100 hover:shadow-xl transition-all group flex flex-col h-full">
                            <div className="relative h-48 overflow-hidden">
                                {blog.coverImage ? (
                                    <Image src={blog.coverImage} alt={blog.title} fill className="object-cover group-hover:scale-105 transition-transform duration-500" />
                                ) : (
                                    <div className="w-full h-full bg-gray-100 flex items-center justify-center text-gray-300">
                                        <BookOpen className="h-12 w-12" />
                                    </div>
                                )}
                                <div className="absolute top-4 left-4 flex gap-2">
                                    <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest ${
                                        blog.status === 'published' ? 'bg-green-100 text-green-600' : 'bg-orange-100 text-orange-600'
                                    }`}>
                                        {blog.status}
                                    </span>
                                    <span className="bg-white/80 backdrop-blur-sm px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest text-gray-600 flex items-center gap-1">
                                        <Tag className="w-3 h-3" />
                                        {blog.category}
                                    </span>
                                </div>
                            </div>

                            <div className="p-6 flex-1 flex flex-col">
                                <h3 className="text-xl font-bold text-gray-900 mb-3 line-clamp-2 leading-snug group-hover:text-[#EF2F55] transition-colors">{blog.title}</h3>
                                
                                <div className="flex items-center gap-4 text-xs text-gray-400 mb-6 mt-auto">
                                    <div className="flex items-center gap-1">
                                        <Clock className="w-3.5 h-3.5" />
                                        {new Date(blog.createdAt).toLocaleDateString()}
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <Eye className="w-3.5 h-3.5" />
                                        {blog.views} views
                                    </div>
                                </div>

                                <div className="flex gap-2 pt-4 border-t border-gray-50 mt-auto">
                                    <button
                                        onClick={() => toggleStatus(blog)}
                                        className={`flex-1 flex items-center justify-center gap-1 py-2.5 rounded-xl border text-xs font-bold transition-all ${
                                            blog.status === 'published' 
                                            ? 'border-orange-100 text-orange-600 hover:bg-orange-50' 
                                            : 'border-green-100 text-green-600 hover:bg-green-50'
                                        }`}
                                        title={blog.status === 'published' ? 'Move to drafts' : 'Publish'}
                                    >
                                        {blog.status === 'published' ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                                        {blog.status === 'published' ? 'Unpublish' : 'Publish'}
                                    </button>
                                    <button
                                        onClick={() => router.push(`/admin/blogs/${blog._id}`)}
                                        className="flex-1 flex items-center justify-center gap-1 py-2.5 rounded-xl border border-gray-100 text-gray-600 hover:bg-gray-50 text-xs font-bold transition-all"
                                    >
                                        <Edit className="w-3.5 h-3.5" />
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(blog._id)}
                                        className="w-10 flex items-center justify-center rounded-xl border border-red-50 text-red-500 hover:bg-red-50 transition-all"
                                    >
                                        <Trash2 className="w-4 h-4" />
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
