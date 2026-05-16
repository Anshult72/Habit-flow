'use client';

import { useState, useRef, useEffect } from 'react';
import { motion } from 'framer-motion';
import { User, Mail, Calendar, MapPin, Camera, Save, LogOut, CheckCircle2, X } from 'lucide-react';
import useStore from '@/store/useStore';
import { apiFetch } from '@/lib/api';
import { createClient } from '@supabase/supabase-js';
import toast from 'react-hot-toast';
import { useLogout } from '@/hooks/useLogout';

// We initialize a basic supabase client for storage uploads (if frontend env vars are available)
// Otherwise, we fallback to just URL string if the user pastes an image URL, or handle it via backend.
// Actually, it's better to use the shared supabase client from lib.
import { supabase } from '@/lib/supabaseClient';

export default function AccountPage() {
  const { user, syncData } = useStore();
  const logout = useLogout();
  
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  
  const fileInputRef = useRef(null);

  const [formData, setFormData] = useState({
    name: '',
    dob: '',
    city: '',
    state: '',
    avatarUrl: ''
  });

  useEffect(() => {
    if (user) {
      setTimeout(() => setFormData({
        name: user.name || '',
        dob: user.dob ? new Date(user.dob).toISOString().split('T')[0] : '',
        city: user.city || '',
        state: user.state || '',
        avatarUrl: user.avatarUrl || ''
      }), 0);
    }
  }, [user]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const payload = {};
      if (formData.name && formData.name.trim().length >= 2) payload.name = formData.name;
      if (formData.dob) {
        try {
          payload.dob = new Date(formData.dob).toISOString();
        } catch (e) {
          console.error("Invalid date");
        }
      }
      if (formData.city) payload.city = formData.city;
      if (formData.state) payload.state = formData.state;
      if (formData.avatarUrl) payload.avatarUrl = formData.avatarUrl;

      const res = await apiFetch('/users/profile', {
        method: 'PATCH',
        body: JSON.stringify(payload)
      });

      if (res && !res.error) {
        toast.success('Profile updated successfully');
        setIsEditing(false);
        await syncData(); // refresh store
      } else {
        toast.error('Failed to update profile');
      }
    } catch (err) {
      console.error(err);
      toast.error('An error occurred while saving.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleImageUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.size > 2 * 1024 * 1024) {
      toast.error('Image must be less than 2MB');
      return;
    }

    setIsUploading(true);
    try {
      // Create a unique file name
      const fileExt = file.name.split('.').pop();
      const fileName = `${user.supabaseId}-${Date.now()}.${fileExt}`;
      const filePath = `avatars/${fileName}`;

      const bucketName = process.env.NEXT_PUBLIC_SUPABASE_STORAGE_BUCKET || 'Habitflow';
      
      const { data, error: uploadError } = await supabase.storage
        .from(bucketName)
        .upload(filePath, file, { upsert: true });

      if (uploadError) {
        console.error('Supabase upload error:', uploadError);
        throw new Error(`Upload failed: ${uploadError.message}. Make sure the "${bucketName}" bucket exists in Supabase and is set to "Public".`);
      }

      // Get public URL using the same bucket name
      const { data: { publicUrl } } = supabase.storage
        .from(bucketName)
        .getPublicUrl(filePath);

      setFormData(prev => ({ ...prev, avatarUrl: publicUrl }));
      
      // Auto save after upload
      await apiFetch('/users/profile', {
        method: 'PATCH',
        body: JSON.stringify({ avatarUrl: publicUrl })
      });
      await syncData();
      toast.success('Avatar updated successfully');

    } catch (error) {
      console.error('Upload error details:', error);
      toast.error(error.message || 'Failed to upload image. Please check your Supabase Storage settings.');
      
      // Fallback: If storage fails (bucket might not exist), let the user know
      // In a real app, you would create the bucket in Supabase dashboard.
    } finally {
      setIsUploading(false);
    }
  };

  if (!user) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-[#FF6B2C] border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  // Generate fallback avatar
  const displayAvatar = formData.avatarUrl || `https://api.dicebear.com/7.x/initials/svg?seed=${user.email || 'User'}&backgroundColor=FF6B2C`;

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
        <div>
          <h1 className="text-3xl font-display font-bold text-white tracking-tight">Account Settings</h1>
          <p className="text-text-muted mt-1">Manage your identity and personalization.</p>
        </div>
        
        <div className="flex gap-3">
          {isEditing ? (
            <>
              <button
                onClick={() => {
                  setIsEditing(false);
                  // Reset form
                  setFormData({
                    name: user.name || '',
                    dob: user.dob ? new Date(user.dob).toISOString().split('T')[0] : '',
                    city: user.city || '',
                    state: user.state || '',
                    avatarUrl: user.avatarUrl || ''
                  });
                }}
                className="px-4 py-2 rounded-xl bg-white/5 border border-white/10 hover:bg-white/10 text-white font-medium transition-all flex items-center gap-2"
                disabled={isSaving}
              >
                <X size={16} /> Cancel
              </button>
              <button
                onClick={handleSave}
                disabled={isSaving}
                className="px-4 py-2 rounded-xl bg-[#FF6B2C] hover:bg-[#E85D04] text-white font-semibold transition-all shadow-[0_0_15px_rgba(255,107,44,0.3)] flex items-center gap-2"
              >
                {isSaving ? <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> : <Save size={16} />}
                Save Changes
              </button>
            </>
          ) : (
            <button
              onClick={() => setIsEditing(true)}
              className="px-4 py-2 rounded-xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/40 text-white font-medium transition-all shadow-sm flex items-center gap-2"
            >
              Edit Profile
            </button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Profile Identity Card */}
        <div className="col-span-1">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-[#0A0A0A] border border-white/10 rounded-3xl p-8 relative overflow-hidden"
          >
            <div className="absolute top-0 right-0 w-32 h-32 bg-[#FF6B2C]/10 blur-3xl rounded-full pointer-events-none" />
            
            <div className="flex flex-col items-center text-center relative z-10">
              <div className="relative group">
                <div className="w-32 h-32 rounded-full p-1 bg-gradient-to-br from-[#FF6B2C] to-transparent shadow-[0_0_20px_rgba(255,107,44,0.2)]">
                  <img 
                    src={displayAvatar} 
                    alt="Profile" 
                    className="w-full h-full rounded-full object-cover bg-[#1A1A1A]"
                  />
                </div>
                
                <button 
                  onClick={() => fileInputRef.current?.click()}
                  disabled={isUploading}
                  className="absolute bottom-1 right-1 w-10 h-10 bg-[#FF6B2C] rounded-full flex items-center justify-center text-white shadow-lg hover:scale-110 transition-transform disabled:opacity-50"
                  title="Upload Picture"
                >
                  {isUploading ? (
                    <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <Camera size={18} />
                  )}
                </button>
                <input 
                  type="file" 
                  ref={fileInputRef} 
                  onChange={handleImageUpload} 
                  accept="image/*" 
                  className="hidden" 
                />
              </div>

              <h2 className="mt-6 text-2xl font-bold text-white tracking-tight">{user.name || 'HabitFlow User'}</h2>
              <p className="text-text-muted mt-1">{user.email}</p>

              <div className="mt-6 w-full pt-6 border-t border-white/10 flex flex-col gap-3">
                <div 
                  onClick={() => {
                    if (user.userId) {
                      navigator.clipboard.writeText(user.userId);
                      toast.success('ID Copied!');
                    }
                  }}
                  className="flex items-center justify-between px-3 py-2 bg-white/5 rounded-xl border border-white/5 group hover:border-[#FF6B2C]/30 transition-all cursor-pointer hover:bg-white/[0.07]"
                >
                  <span className="text-sm text-text-muted font-medium">User ID</span>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-mono font-black text-[#FF6B2C] tracking-wider italic">#{user.userId || '---'}</span>
                    <div className="w-3.5 h-3.5 flex items-center justify-center text-white/20 group-hover:text-[#FF6B2C]">
                      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>
                    </div>
                  </div>
                </div>
                <div className="flex items-center justify-between px-3 py-2 bg-white/5 rounded-xl">
                  <span className="text-sm text-text-muted font-medium">Joined</span>
                  <span className="text-sm font-medium text-white">{new Date(user.createdAt).toLocaleDateString()}</span>
                </div>
              </div>

              <button
                onClick={logout}
                className="mt-8 w-full py-3 rounded-xl border border-red-500/20 text-red-400 hover:bg-red-500/10 transition-colors flex items-center justify-center gap-2 font-medium"
              >
                <LogOut size={18} /> Sign Out
              </button>
            </div>
          </motion.div>
        </div>

        {/* Details Section */}
        <div className="col-span-1 lg:col-span-2">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-[#0A0A0A] border border-white/10 rounded-3xl p-8"
          >
            <h3 className="text-xl font-bold text-white mb-6 flex items-center gap-2">
              <User size={20} className="text-[#FF6B2C]" /> Personal Details
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-muted">Full Name</label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                    <User size={18} />
                  </div>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    disabled={!isEditing}
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-3 pl-10 pr-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-colors disabled:opacity-60"
                    placeholder="Enter your name"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-text-muted">Email Address</label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                    <Mail size={18} />
                  </div>
                  <input
                    type="email"
                    value={user.email || ''}
                    disabled
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-3 pl-10 pr-4 text-white/60 cursor-not-allowed"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-text-muted">Date of Birth</label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                    <Calendar size={18} />
                  </div>
                  <input
                    type="date"
                    name="dob"
                    value={formData.dob}
                    onChange={handleChange}
                    disabled={!isEditing}
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-3 pl-10 pr-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-colors disabled:opacity-60 [color-scheme:dark]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-text-muted">City</label>
                  <div className="relative">
                    <div className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                      <MapPin size={18} />
                    </div>
                    <input
                      type="text"
                      name="city"
                      value={formData.city}
                      onChange={handleChange}
                      disabled={!isEditing}
                      className="w-full bg-white/5 border border-white/10 rounded-xl py-3 pl-10 pr-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-colors disabled:opacity-60"
                      placeholder="City"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-text-muted">State</label>
                  <input
                    type="text"
                    name="state"
                    value={formData.state}
                    onChange={handleChange}
                    disabled={!isEditing}
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-3 px-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-colors disabled:opacity-60"
                    placeholder="State"
                  />
                </div>
              </div>

            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
