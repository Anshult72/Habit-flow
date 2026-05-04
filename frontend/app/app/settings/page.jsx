'use client';

import { useState, useRef } from 'react';
import { Save, LogOut, Download, Upload, FileText, FileSpreadsheet } from 'lucide-react';
import useStore from '@/store/useStore';
import toast from 'react-hot-toast';
import { jsPDF } from 'jspdf';
import 'jspdf-autotable';

export default function Settings() {
  const { xp, level, habits, completions, setHabits, setCompletions } = useStore();
  const fileInputRef = useRef(null);
  const csvInputRef = useRef(null);

  const handleExportJSON = () => {
    const dataStr = JSON.stringify({ habits, completions, xp, level }, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', 'habitflow-backup.json');
    linkElement.click();
    toast.success('Backup exported successfully');
  };

  const handleExportCSV = () => {
    let csvContent = "data:text/csv;charset=utf-8,";
    csvContent += "ID,Name,Category,Goal (Days/Mo)\n";
    habits.forEach(h => {
      csvContent += `${h.id},${h.name},${h.category},${h.goal}\n`;
    });
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "habitflow-habits.csv");
    document.body.appendChild(link);
    link.click();
    toast.success('CSV exported successfully');
  };

  const handleExportPDF = () => {
    const doc = new jsPDF();
    doc.text("HabitFlow Productivity Report", 14, 20);
    const tableData = habits.map(h => [h.name, h.category, h.goal?.toString() || '30']);
    doc.autoTable({
      startY: 30,
      head: [['Protocol', 'Classification', 'Monthly Target']],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [255, 107, 44] }
    });
    doc.save('habitflow-report.pdf');
    toast.success('PDF report generated');
  };

  const handleImportJSON = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = JSON.parse(e.target.result);
        if (data.habits) {
          setHabits(data.habits);
          if (data.completions) setCompletions(data.completions);
          toast.success('Data imported successfully');
        }
      } catch (err) { toast.error('Error parsing file'); }
    };
    reader.readAsText(file);
  };

  const handleImportCSV = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const text = e.target.result;
        const lines = text.split('\n');
        const newHabits = [];
        for (let i = 1; i < lines.length; i++) {
          const cols = lines[i].split(',');
          if (cols.length >= 4) {
            newHabits.push({
              id: cols[0].trim(),
              name: cols[1].trim(),
              category: cols[2].trim(),
              goal: parseInt(cols[3].trim()) || 30,
              color: '#FF6B2C'
            });
          }
        }
        if (newHabits.length > 0) {
          setHabits(newHabits);
          toast.success(`Imported ${newHabits.length} habits`);
        }
      } catch (err) { toast.error('Error parsing CSV'); }
    };
    reader.readAsText(file);
  };

  return (
    <div className="space-y-8 max-w-4xl pb-10 relative z-10">
      <div>
        <h1 className="text-4xl font-display font-bold text-white tracking-tight">System Settings</h1>
        <p className="text-text-muted mt-2 text-lg">Manage your operational data and configuration.</p>
      </div>

      <div className="space-y-6">
        <div className="glass-card p-8 rounded-3xl border border-white/5 space-y-6">
          <h2 className="text-2xl font-display font-bold text-white flex items-center gap-2">Account Profile</h2>
          <div className="flex items-center gap-6">
            <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-[#FF6B2C] to-[#FFB347] flex items-center justify-center text-3xl font-display font-bold text-white shadow-[0_0_30px_rgba(255,107,44,0.4)]">U</div>
            <div>
              <p className="font-display font-bold text-2xl text-white">User</p>
              <p className="text-text-muted font-medium uppercase tracking-wider text-sm mt-1">Tier {level} • {xp} XP</p>
            </div>
          </div>
          <button className="flex items-center gap-2 text-red-400 hover:text-red-300 hover:bg-red-400/10 px-4 py-2 rounded-xl transition-colors mt-4 font-bold border border-transparent hover:border-red-400/20">
            <LogOut size={18} /><span>Terminate Session</span>
          </button>
        </div>

        <div className="glass-card p-8 rounded-3xl border border-white/5 space-y-8">
          <div><h2 className="text-2xl font-display font-bold text-white">Data Portability</h2><p className="text-text-muted mt-1">Extract or inject operational intelligence.</p></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <button onClick={handleExportJSON} className="flex items-center gap-3 bg-white/5 hover:bg-white/10 border border-white/10 p-5 rounded-2xl transition-all hover:border-[#FF6B2C]/50 group">
              <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform"><Download size={20} className="text-white" /></div>
              <div className="text-left"><p className="text-white font-bold">Export JSON</p><p className="text-xs text-text-muted">Backup payload</p></div>
            </button>
            <button onClick={() => fileInputRef.current?.click()} className="flex items-center gap-3 bg-white/5 hover:bg-white/10 border border-white/10 p-5 rounded-2xl transition-all hover:border-[#FF6B2C]/50 group">
              <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform"><Upload size={20} className="text-[#FF8C42]" /></div>
              <div className="text-left"><p className="text-white font-bold">Import JSON</p><p className="text-xs text-text-muted">Restore payload</p></div>
              <input type="file" accept=".json" ref={fileInputRef} onChange={handleImportJSON} className="hidden" />
            </button>
            <button onClick={handleExportCSV} className="flex items-center gap-3 bg-white/5 hover:bg-white/10 border border-white/10 p-5 rounded-2xl transition-all hover:border-[#FF6B2C]/50 group">
              <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform"><FileSpreadsheet size={20} className="text-white" /></div>
              <div className="text-left"><p className="text-white font-bold">Export CSV</p><p className="text-xs text-text-muted">Spreadsheet format</p></div>
            </button>
            <button onClick={() => csvInputRef.current?.click()} className="flex items-center gap-3 bg-white/5 hover:bg-white/10 border border-white/10 p-5 rounded-2xl transition-all hover:border-[#FF6B2C]/50 group">
              <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform"><FileSpreadsheet size={20} className="text-[#FF8C42]" /></div>
              <div className="text-left"><p className="text-white font-bold">Import CSV</p><p className="text-xs text-text-muted">Load spreadsheets</p></div>
              <input type="file" accept=".csv" ref={csvInputRef} onChange={handleImportCSV} className="hidden" />
            </button>
            <button onClick={handleExportPDF} className="flex items-center gap-3 bg-white/5 hover:bg-white/10 border border-white/10 p-5 rounded-2xl transition-all hover:border-[#FF6B2C]/50 group">
              <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform"><FileText size={20} className="text-[#FF8C42]" /></div>
              <div className="text-left"><p className="text-white font-bold">Export PDF</p><p className="text-xs text-text-muted">Printable report</p></div>
            </button>
          </div>
        </div>

        <div className="glass-card p-8 rounded-3xl border border-white/5 space-y-6">
          <h2 className="text-2xl font-display font-bold text-white">App Preferences</h2>
          <div className="flex items-center justify-between py-4 border-b border-white/5">
            <div><p className="font-bold text-white text-lg">Cinematic Mode</p><p className="text-sm text-text-muted">Permanent dark mode active.</p></div>
            <div className="w-14 h-7 bg-[#FF6B2C] rounded-full relative cursor-not-allowed shadow-[0_0_15px_rgba(255,107,44,0.4)] opacity-80"><div className="w-5 h-5 bg-white rounded-full absolute right-1 top-1" /></div>
          </div>
          <div className="flex items-center justify-between py-4 border-b border-white/5">
            <div><p className="font-bold text-white text-lg">Haptic Feedback</p><p className="text-sm text-text-muted">Vibrate on completion (mobile).</p></div>
            <div className="w-14 h-7 bg-white/10 rounded-full relative cursor-pointer border border-white/20"><div className="w-5 h-5 bg-text-muted rounded-full absolute left-1 top-1" /></div>
          </div>
        </div>

        <div className="flex justify-end">
          <button className="px-8 py-3 rounded-full bg-white text-black font-bold hover:bg-gray-200 transition-colors shadow-[0_0_20px_rgba(255,255,255,0.2)] flex items-center gap-2">
            <Save size={20} />Commit Changes
          </button>
        </div>
      </div>
    </div>
  );
}
