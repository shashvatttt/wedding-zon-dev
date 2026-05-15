'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import api from '../../../services/api';
import { ChevronLeft, Save, Upload, X, BookOpen, AlertCircle, Layout } from 'lucide-react';
import { useToast } from '../../../contexts/ToastContext';
import Image from 'next/image';

const CATEGORIES = ['Wedding Tips', 'Trends', 'Real Weddings', 'Planning', 'Fashion', 'Other'];

export default function BlogEditorPage() {
    const { addToast } = useToast();
    const router = useRouter();
    const params = useParams();
    const isEdit = params.id && params.id !== 'new';

    const [form, setForm] = useState({
        title: '',
        content: '',
        category: 'Planning',
        coverImage: '',
        status: 'draft',
        tags: [] as string[]
    });
    
    const [tagInput, setTagInput] = useState('');
    const [loading, setLoading] = useState(isEdit);
    const [saving, setSaving] = useState(false);
    const [uploading, setUploading] = useState(false);

    useEffect(() => {
        if (isEdit) {
            const fetchBlog = async () => {
                try {
                    const res = await api.get(`/blogs/admin/list`);
                    const blog = res.data.data.find((b: any) => b._id === params.id);
                    if (blog) {
                        setForm({
                            title: blog.title,
                            content: blog.content,
                            category: blog.category,
                            coverImage: blog.coverImage || '',
                            status: blog.status,
                            tags: blog.tags || []
                        });
                    }
                } catch (error) {
                    addToast('Failed to load blog', 'error');
                } finally {
                    setLoading(false);
                }
            };
            fetchBlog();
        }
    }, [isEdit, params.id]);

    const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setUploading(true);
        const formData = new FormData();
        formData.append('file', file);

        try {
            const res = await api.post('/uploads', formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            setForm(prev => ({ ...prev, coverImage: res.data.url }));
            addToast('Image uploaded successfully', 'success');
        } catch (error) {
            addToast('Upload failed', 'error');
        } finally {
            setUploading(false);
        }
    };

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!form.title || !form.content) {
            addToast('Please fill in all required fields', 'error');
            return;
        }

        setSaving(true);
        try {
            if (isEdit) {
                await api.put(`/blogs/${params.id}`, form);
                addToast('Blog updated successfully', 'success');
            } else {
                await api.post('/blogs', form);
                addToast('Blog created successfully', 'success');
            }
            router.push('/admin/blogs');
        } catch (error) {
            addToast('Failed to save blog', 'error');
        } finally {
            setSaving(false);
        }
    };

    const addTag = () => {
        if (tagInput && !form.tags.includes(tagInput)) {
            setForm(prev => ({ ...prev, tags: [...prev.tags, tagInput] }));
            setTagInput('');
        }
    };

    const removeTag = (tagToRemove: string) => {
        setForm(prev => ({ ...prev, tags: prev.tags.filter(t => t !== tagToRemove) }));
    };

    if (loading) return <div className="p-8">Loading...</div>;

    return (
        <div className="p-6 max-w-5xl mx-auto pb-20">
            <button
                onClick={() => router.push('/admin/blogs')}
                className="flex items-center gap-1 text-gray-500 hover:text-gray-900 mb-6 transition-colors font-medium"
            >
                <ChevronLeft className="h-4 w-4" />
                Back to Blogs
            </button>

            <form onSubmit={handleSave} className="space-y-8">
                <div className="flex justify-between items-center bg-white p-6 rounded-[32px] shadow-sm border border-gray-100">
                    <div className="flex items-center gap-4">
                        <div className="bg-[#EF2F55] p-3 rounded-2xl">
                            <BookOpen className="h-6 w-6 text-white" />
                        </div>
                        <div>
                            <h1 className="text-2xl font-serif font-black text-gray-900">
                                {isEdit ? 'Edit Post' : 'Create New Post'}
                            </h1>
                            <p className="text-xs text-gray-400 font-bold uppercase tracking-wider mt-0.5">Editor Mode</p>
                        </div>
                    </div>
                    <div className="flex gap-3">
                        <select
                            value={form.status}
                            onChange={(e) => setForm(prev => ({ ...prev, status: e.target.value as 'draft' | 'published' }))}
                            className={`px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-widest outline-none border transition-all ${
                                form.status === 'published' ? 'bg-green-50 border-green-200 text-green-600' : 'bg-orange-50 border-orange-200 text-orange-600'
                            }`}
                        >
                            <option value="draft">Draft</option>
                            <option value="published">Published</option>
                        </select>
                        <button
                            type="submit"
                            disabled={saving}
                            className="bg-[#EF2F55] hover:bg-rose-700 disabled:bg-gray-400 text-white px-8 py-2.5 rounded-xl font-bold flex items-center gap-2 transition-all shadow-md active:scale-95"
                        >
                            <Save className="h-4 w-4" />
                            {saving ? 'Saving...' : 'Save Post'}
                        </button>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Main Content */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-100 space-y-6">
                            <div>
                                <label className="block text-xs font-black text-gray-400 uppercase tracking-widest mb-2">Blog Title</label>
                                <input
                                    type="text"
                                    value={form.title}
                                    onChange={(e) => setForm(prev => ({ ...prev, title: e.target.value }))}
                                    placeholder="Enter a catchy title..."
                                    className="w-full px-0 py-2 border-b-2 border-gray-100 focus:border-[#EF2F55] outline-none text-2xl font-bold text-gray-900 transition-colors placeholder:opacity-30"
                                    required
                                />
                            </div>

                            <div>
                                <label className="block text-xs font-black text-gray-400 uppercase tracking-widest mb-2">Content</label>
                                <textarea
                                    value={form.content}
                                    onChange={(e) => setForm(prev => ({ ...prev, content: e.target.value }))}
                                    placeholder="Start writing your story..."
                                    className="w-full min-h-[500px] p-6 bg-gray-50 rounded-2xl outline-none focus:ring-2 focus:ring-pink-100 border border-gray-100 text-gray-700 leading-relaxed transition-all resize-none"
                                    required
                                />
                                <div className="mt-2 text-[10px] text-gray-400 font-bold uppercase flex items-center gap-1.5">
                                    <AlertCircle className="w-3 h-3" />
                                    Supports plain text and basic HTML tags
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Sidebar / Options */}
                    <div className="space-y-6 font-sans">
                        {/* Cover Image */}
                        <div className="bg-white p-6 rounded-[32px] shadow-sm border border-gray-100">
                            <label className="block text-xs font-black text-gray-400 uppercase tracking-widest mb-4">Cover Image</label>
                            
                            {form.coverImage ? (
                                <div className="relative aspect-video rounded-2xl overflow-hidden mb-4 group">
                                    <Image src={form.coverImage} alt="Cover preview" fill className="object-cover" />
                                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                        <button 
                                            type="button"
                                            onClick={() => setForm(prev => ({ ...prev, coverImage: '' }))}
                                            className="bg-white/20 backdrop-blur-md p-2 rounded-full text-white hover:bg-white/40 transition-all"
                                        >
                                            <X className="w-5 h-5" />
                                        </button>
                                    </div>
                                </div>
                            ) : (
                                <label className="relative aspect-video rounded-2xl border-2 border-dashed border-gray-200 flex flex-col items-center justify-center cursor-pointer hover:border-pink-300 hover:bg-pink-50 transition-all mb-4 group">
                                    <input type="file" className="hidden" accept="image/*" onChange={handleImageUpload} />
                                    <Upload className={`w-8 h-8 text-gray-300 group-hover:text-pink-300 transition-colors ${uploading ? 'animate-bounce' : ''}`} />
                                    <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest mt-2">{uploading ? 'Uploading...' : 'Upload Cover'}</span>
                                </label>
                            )}
                        </div>

                        {/* Settings */}
                        <div className="bg-white p-6 rounded-[32px] shadow-sm border border-gray-100 space-y-6">
                            <div>
                                <label className="block text-xs font-black text-gray-400 uppercase tracking-widest mb-3 flex items-center gap-2">
                                    <Layout className="w-3 h-3" />
                                    Category
                                </label>
                                <div className="grid grid-cols-2 gap-2">
                                    {CATEGORIES.map(cat => (
                                        <button
                                            key={cat}
                                            type="button"
                                            onClick={() => setForm(prev => ({ ...prev, category: cat }))}
                                            className={`px-3 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider border transition-all ${
                                                form.category === cat ? 'bg-[#EF2F55] border-[#EF2F55] text-white shadow-md' : 'bg-gray-50 border-gray-100 text-gray-500 hover:bg-gray-100'
                                            }`}
                                        >
                                            {cat}
                                        </button>
                                    ))}
                                </div>
                            </div>

                            <div>
                                <label className="block text-xs font-black text-gray-400 uppercase tracking-widest mb-3">Tags</label>
                                <div className="flex flex-wrap gap-2 mb-3">
                                    {form.tags.map(tag => (
                                        <span key={tag} className="bg-gray-100 text-gray-600 px-2 py-1 rounded-lg text-xs font-medium flex items-center gap-1">
                                            {tag}
                                            <button type="button" onClick={() => removeTag(tag)} className="hover:text-red-500">
                                                <X className="w-3 h-3" />
                                            </button>
                                        </span>
                                    ))}
                                </div>
                                <div className="flex gap-2">
                                    <input
                                        type="text"
                                        value={tagInput}
                                        onChange={(e) => setTagInput(e.target.value)}
                                        onKeyPress={(e) => e.key === 'Enter' && (e.preventDefault(), addTag())}
                                        placeholder="Add tag..."
                                        className="flex-1 bg-gray-50 border border-gray-100 rounded-xl px-4 py-2 text-xs outline-none focus:ring-2 focus:ring-pink-100"
                                    />
                                    <button 
                                        type="button"
                                        onClick={addTag}
                                        className="bg-gray-900 text-white px-4 py-2 rounded-xl text-xs font-bold"
                                    >
                                        Add
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    );
}
