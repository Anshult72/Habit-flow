import { useState } from 'react';
import { motion, AnimatePresence, LayoutGroup } from 'framer-motion';
import { 
  Plus, AlertCircle, Clock, CheckCircle2, 
  Trash2, MoreVertical, Calendar, Tag,
  ChevronRight, Sparkles, Filter, Info,
  Zap, Shield, Target, Coffee
} from 'lucide-react';
import useStore from '../store/useStore';
import { format } from 'date-fns';

export default function EisenhowerMatrix() {
  const { matrixTasks, addMatrixTask, updateMatrixTask, deleteMatrixTask, toggleMatrixTask } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTask, setEditingTask] = useState(null);
  
  const quadrants = [
    { 
      id: 1, 
      title: 'Do First', 
      subtitle: 'Urgent & Important', 
      color: '#FF4D4D', 
      glow: 'shadow-[0_0_30px_rgba(255,77,77,0.15)]',
      border: 'border-[#FF4D4D]/20',
      icon: Zap,
      bg: 'bg-gradient-to-br from-[#FF4D4D]/10 to-transparent'
    },
    { 
      id: 2, 
      title: 'Schedule', 
      subtitle: 'Not Urgent & Important', 
      color: '#FFD700', 
      glow: 'shadow-[0_0_30px_rgba(255,215,0,0.15)]',
      border: 'border-[#FFD700]/20',
      icon: Calendar,
      bg: 'bg-gradient-to-br from-[#FFD700]/10 to-transparent'
    },
    { 
      id: 3, 
      title: 'Delegate', 
      subtitle: 'Urgent & Unimportant', 
      color: '#3B82F6', 
      glow: 'shadow-[0_0_30px_rgba(59,130,246,0.15)]',
      border: 'border-[#3B82F6]/20',
      icon: Target,
      bg: 'bg-gradient-to-br from-[#3B82F6]/10 to-transparent'
    },
    { 
      id: 4, 
      title: 'Eliminate', 
      subtitle: 'Not Urgent & Unimportant', 
      color: '#10B981', 
      glow: 'shadow-[0_0_30px_rgba(16,185,129,0.15)]',
      border: 'border-[#10B981]/20',
      icon: Coffee,
      bg: 'bg-gradient-to-br from-[#10B981]/10 to-transparent'
    }
  ];

  const handleDragStart = (e, taskId) => {
    e.dataTransfer.setData('taskId', taskId);
  };

  const handleDrop = (e, quadrantId) => {
    const taskId = e.dataTransfer.getData('taskId');
    updateMatrixTask(taskId, { quadrant: quadrantId });
  };

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  return (
    <div className="min-h-screen bg-[#050505] pt-6 pb-20 px-4 md:px-10">
      <div className="max-w-[1600px] mx-auto space-y-8">
        
        {/* Header Section */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
          <div>
            <motion.h1 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="text-4xl font-display font-black text-white flex items-center gap-4"
            >
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.4)]">
                <Target className="text-white" size={28} />
              </div>
              Eisenhower Matrix
            </motion.h1>
            <p className="text-textMuted mt-2 text-lg">Master your focus through strategic priority management.</p>
          </div>

          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => setIsModalOpen(true)}
            className="px-8 py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all flex items-center gap-3 group"
          >
            <Plus size={20} className="group-hover:rotate-90 transition-transform duration-300" />
            Add High Priority Task
          </motion.button>
        </div>

        {/* Matrix Grid */}
        <LayoutGroup>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 h-full min-h-[700px]">
            {quadrants.map((q) => (
              <div
                key={q.id}
                onDrop={(e) => handleDrop(e, q.id)}
                onDragOver={handleDragOver}
                className={`relative glass-card rounded-[2.5rem] border ${q.border} ${q.bg} ${q.glow} flex flex-col overflow-hidden transition-all duration-500`}
              >
                {/* Quadrant Header */}
                <div className="p-8 border-b border-white/5 flex items-center justify-between bg-black/20 backdrop-blur-md">
                  <div className="flex items-center gap-4">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center`} style={{ backgroundColor: `${q.color}20` }}>
                      <q.icon style={{ color: q.color }} size={24} />
                    </div>
                    <div>
                      <h3 className="text-white font-bold text-xl">{q.title}</h3>
                      <p className="text-[10px] uppercase tracking-[0.2em] font-medium opacity-50" style={{ color: q.color }}>{q.subtitle}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-white/40 text-sm font-medium">
                      {matrixTasks.filter(t => t.quadrant === q.id && !t.completed).length} Tasks
                    </span>
                    <div className="w-10 h-10 rounded-full border border-white/10 flex items-center justify-center text-white/20 hover:text-white transition-colors cursor-help">
                      <Info size={16} />
                    </div>
                  </div>
                </div>

                {/* Task List */}
                <div className="flex-1 p-6 overflow-y-auto max-h-[400px] custom-scrollbar space-y-4">
                  <AnimatePresence mode="popLayout">
                    {matrixTasks
                      .filter(t => t.quadrant === q.id)
                      .map((task) => (
                        <TaskItem 
                          key={task.id} 
                          task={task} 
                          qColor={q.color}
                          onToggle={() => toggleMatrixTask(task.id)}
                          onDelete={() => deleteMatrixTask(task.id)}
                          onEdit={() => {
                            setEditingTask(task);
                            setIsModalOpen(true);
                          }}
                          onDragStart={(e) => handleDragStart(e, task.id)}
                        />
                      ))}
                  </AnimatePresence>

                  {matrixTasks.filter(t => t.quadrant === q.id).length === 0 && (
                    <motion.div 
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 0.3 }}
                      className="h-full flex flex-col items-center justify-center py-10 text-center"
                    >
                      <div className="w-16 h-16 rounded-full border-2 border-dashed border-white/20 flex items-center justify-center mb-4">
                        <Plus size={24} />
                      </div>
                      <p className="text-sm font-medium">No tasks in this quadrant</p>
                      <p className="text-[10px] uppercase tracking-widest mt-1">Focus on what matters</p>
                    </motion.div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </LayoutGroup>
      </div>

      <AnimatePresence>
        {isModalOpen && (
          <AddTaskModal 
            onClose={() => {
              setIsModalOpen(false);
              setEditingTask(null);
            }}
            onAdd={addMatrixTask}
            onUpdate={updateMatrixTask}
            editingTask={editingTask}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function TaskItem({ task, qColor, onToggle, onDelete, onEdit, onDragStart }) {
  return (
    <motion.div
      layout
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9 }}
      draggable
      onDragStart={onDragStart}
      className={`group relative glass-card border border-white/5 p-5 rounded-2xl cursor-grab active:cursor-grabbing hover:border-white/20 transition-all duration-300 ${task.completed ? 'opacity-50 grayscale' : ''}`}
    >
      <div className="flex items-start gap-4">
        <button 
          onClick={onToggle}
          className={`w-6 h-6 rounded-lg border-2 flex items-center justify-center transition-all ${
            task.completed 
              ? 'bg-[#FF6B2C] border-[#FF6B2C] shadow-[0_0_15px_rgba(255,107,44,0.4)]' 
              : 'border-white/20 hover:border-[#FF6B2C]/50'
          }`}
        >
          {task.completed && <CheckCircle2 size={14} className="text-white" />}
        </button>
        
        <div className="flex-1 min-w-0">
          <h4 className={`text-white font-bold text-base transition-all ${task.completed ? 'line-through text-white/40' : ''}`}>
            {task.title}
          </h4>
          {task.desc && <p className="text-textMuted text-xs mt-1 line-clamp-1">{task.desc}</p>}
          
          <div className="flex flex-wrap items-center gap-3 mt-4">
            {task.dueDate && (
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-[10px] text-textMuted">
                <Clock size={10} />
                {format(new Date(task.dueDate), 'MMM d')}
              </div>
            )}
            {task.tags && task.tags.map(tag => (
              <div key={tag} className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[10px] text-[#FF8C42] font-bold">
                <Tag size={10} />
                {tag}
              </div>
            ))}
          </div>
        </div>

        <div className="flex flex-col gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <button onClick={onEdit} className="p-2 rounded-lg bg-white/5 hover:bg-white/10 text-white/40 hover:text-white transition-all">
            <MoreVertical size={16} />
          </button>
          <button onClick={onDelete} className="p-2 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400/60 hover:text-red-400 transition-all">
            <Trash2 size={16} />
          </button>
        </div>
      </div>
      
      {/* Accent Glow on Hover */}
      <div 
        className="absolute inset-0 rounded-2xl opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-500"
        style={{ boxShadow: `inset 0 0 20px ${qColor}10` }}
      />
    </motion.div>
  );
}

function AddTaskModal({ onClose, onAdd, onUpdate, editingTask }) {
  const [taskData, setTaskData] = useState(editingTask || {
    title: '',
    desc: '',
    urgency: 'urgent',
    importance: 'important',
    dueDate: '',
    tags: []
  });

  const getQuadrant = (u, i) => {
    if (u === 'urgent' && i === 'important') return 1;
    if (u === 'not-urgent' && i === 'important') return 2;
    if (u === 'urgent' && i === 'not-important') return 3;
    return 4;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const quadrant = getQuadrant(taskData.urgency, taskData.importance);
    if (editingTask) {
      onUpdate(editingTask.id, { ...taskData, quadrant });
    } else {
      onAdd({ ...taskData, quadrant });
    }
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="absolute inset-0 bg-black/80 backdrop-blur-xl"
      />
      
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="relative w-full max-w-2xl glass-card rounded-[2.5rem] border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.1)] overflow-hidden"
      >
        <div className="p-10">
          <div className="flex items-center gap-4 mb-8">
            <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.4)]">
              <Plus className="text-white" size={28} />
            </div>
            <div>
              <h2 className="text-3xl font-display font-black text-white">{editingTask ? 'Refine Strategy' : 'Strategic Initialization'}</h2>
              <p className="text-textMuted uppercase tracking-[0.2em] text-xs font-bold mt-1">Matrix Task Deployment</p>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest font-bold text-[#FF8C42] ml-2">Objective Title</label>
              <input
                required
                type="text"
                placeholder="What is your primary focus?"
                className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white placeholder:text-white/20 focus:outline-none focus:border-[#FF6B2C]/50 transition-all"
                value={taskData.title}
                onChange={(e) => setTaskData({ ...taskData, title: e.target.value })}
              />
            </div>

            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest font-bold text-[#FF8C42] ml-2">Intelligence Brief</label>
              <textarea
                placeholder="Additional tactical details..."
                rows={3}
                className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white placeholder:text-white/20 focus:outline-none focus:border-[#FF6B2C]/50 transition-all resize-none"
                value={taskData.desc}
                onChange={(e) => setTaskData({ ...taskData, desc: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="text-[10px] uppercase tracking-widest font-bold text-[#FF8C42] ml-2">Time Urgency</label>
                <div className="grid grid-cols-2 gap-2">
                  {['urgent', 'not-urgent'].map(opt => (
                    <button
                      key={opt}
                      type="button"
                      onClick={() => setTaskData({ ...taskData, urgency: opt })}
                      className={`py-3 rounded-xl border text-[10px] font-bold uppercase tracking-widest transition-all ${
                        taskData.urgency === opt 
                          ? 'bg-[#FF6B2C]/20 border-[#FF6B2C] text-white' 
                          : 'bg-white/5 border-white/10 text-white/40 hover:bg-white/10'
                      }`}
                    >
                      {opt.replace('-', ' ')}
                    </button>
                  ))}
                </div>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] uppercase tracking-widest font-bold text-[#FF8C42] ml-2">Value Impact</label>
                <div className="grid grid-cols-2 gap-2">
                  {['important', 'not-important'].map(opt => (
                    <button
                      key={opt}
                      type="button"
                      onClick={() => setTaskData({ ...taskData, importance: opt })}
                      className={`py-3 rounded-xl border text-[10px] font-bold uppercase tracking-widest transition-all ${
                        taskData.importance === opt 
                          ? 'bg-[#FF6B2C]/20 border-[#FF6B2C] text-white' 
                          : 'bg-white/5 border-white/10 text-white/40 hover:bg-white/10'
                      }`}
                    >
                      {opt.replace('-', ' ')}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="text-[10px] uppercase tracking-widest font-bold text-[#FF8C42] ml-2">Temporal Deadline</label>
                <input
                  type="date"
                  className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all [color-scheme:dark]"
                  value={taskData.dueDate}
                  onChange={(e) => setTaskData({ ...taskData, dueDate: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <label className="text-[10px] uppercase tracking-widest font-bold text-[#FF8C42] ml-2">Yield Forecast</label>
                <div className="bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 rounded-2xl px-6 py-4 flex items-center justify-between">
                  <div className="flex items-center gap-2 text-[#FF8C42]">
                    <Sparkles size={16} />
                    <span className="text-sm font-bold">50 XP Reward</span>
                  </div>
                  <Shield size={16} className="text-[#FF8C42]/40" />
                </div>
              </div>
            </div>

            <div className="pt-4 flex gap-4">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 py-4 rounded-2xl bg-white/5 border border-white/10 text-white font-bold hover:bg-white/10 transition-all"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="flex-[2] py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all"
              >
                {editingTask ? 'Update Mission' : 'Commit to Matrix'}
              </button>
            </div>
          </form>
        </div>
      </motion.div>
    </div>
  );
}
