import { Save, LogOut, Download, Upload } from 'lucide-react';
import useStore from '../store/useStore';

export default function Settings() {
  const { xp, level, habits, completions } = useStore();

  const handleExport = () => {
    const dataStr = JSON.stringify({ habits, completions, xp, level }, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    
    const exportFileDefaultName = 'habitflow-backup.json';
    
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
  };

  return (
    <div className="space-y-8 max-w-3xl pb-10">
      <div>
        <h1 className="text-3xl font-bold">Settings</h1>
        <p className="text-textMuted mt-1">Manage your preferences and data.</p>
      </div>

      <div className="space-y-6">
        <div className="p-6 rounded-2xl bg-surface border border-surface/50 space-y-4">
          <h2 className="text-xl font-bold flex items-center gap-2">
            Account Profile
          </h2>
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-primary to-secondary flex items-center justify-center text-2xl font-bold text-white shadow-lg">
              U
            </div>
            <div>
              <p className="font-bold text-lg">User</p>
              <p className="text-textMuted text-sm">Level {level} • {xp} XP</p>
            </div>
          </div>
          <button className="flex items-center gap-2 text-danger hover:bg-danger/10 px-4 py-2 rounded-xl transition-colors mt-4">
            <LogOut size={18} />
            <span>Sign Out</span>
          </button>
        </div>

        <div className="p-6 rounded-2xl bg-surface border border-surface/50 space-y-6">
          <h2 className="text-xl font-bold">Data Management</h2>
          <p className="text-sm text-textMuted">Backup or restore your local habit data.</p>
          
          <div className="flex gap-4">
            <button 
              onClick={handleExport}
              className="flex items-center gap-2 bg-background hover:bg-surface/80 border border-surface px-4 py-2 rounded-xl transition-colors shadow-sm"
            >
              <Download size={18} className="text-primary" />
              <span>Export Backup</span>
            </button>
            <button className="flex items-center gap-2 bg-background hover:bg-surface/80 border border-surface px-4 py-2 rounded-xl transition-colors shadow-sm cursor-not-allowed opacity-50">
              <Upload size={18} className="text-secondary" />
              <span>Import Backup (Soon)</span>
            </button>
          </div>
        </div>

        <div className="p-6 rounded-2xl bg-surface border border-surface/50 space-y-6">
          <h2 className="text-xl font-bold">App Preferences</h2>
          
          <div className="flex items-center justify-between py-2 border-b border-background">
            <div>
              <p className="font-medium">Dark Mode</p>
              <p className="text-xs text-textMuted">Enabled by default in this premium theme.</p>
            </div>
            <div className="w-12 h-6 bg-primary rounded-full relative cursor-pointer shadow-[0_0_10px_rgba(99,102,241,0.5)]">
              <div className="w-4 h-4 bg-white rounded-full absolute right-1 top-1" />
            </div>
          </div>

          <div className="flex items-center justify-between py-2 border-b border-background">
            <div>
              <p className="font-medium">Sound Effects</p>
              <p className="text-xs text-textMuted">Play sounds on habit completion.</p>
            </div>
            <div className="w-12 h-6 bg-surface border border-surface rounded-full relative cursor-pointer">
              <div className="w-4 h-4 bg-textMuted rounded-full absolute left-1 top-1" />
            </div>
          </div>
        </div>

        <div className="flex justify-end">
          <button className="flex items-center gap-2 bg-primary hover:bg-primary/90 text-white px-6 py-2 rounded-xl transition-colors shadow-[0_0_15px_rgba(99,102,241,0.3)]">
            <Save size={18} />
            <span>Save Changes</span>
          </button>
        </div>
      </div>
    </div>
  );
}
