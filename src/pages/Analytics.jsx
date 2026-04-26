import { useMemo } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, getDaysInMonth } from 'date-fns';
import { Line, Doughnut, Radar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  RadialLinearScale,
  ArcElement,
  PointElement,
  LineElement,
  Filler,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale
} from 'chart.js';
import useStore from '../store/useStore';
import { Activity } from 'lucide-react';

ChartJS.register(
  RadialLinearScale,
  ArcElement,
  PointElement,
  LineElement,
  Filler,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale
);

export default function Analytics() {
  const { habits, completions, selectedMonth, selectedYear } = useStore();

  const daysInMonth = getDaysInMonth(new Date(selectedYear, selectedMonth));
  const monthStart = startOfMonth(new Date(selectedYear, selectedMonth));
  const monthEnd = endOfMonth(new Date(selectedYear, selectedMonth));
  
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd }).map(d => format(d, 'yyyy-MM-dd'));

  // Line Chart Data
  const dailyCompletions = days.map(dayStr => {
    return habits.filter(h => completions[`${h.id}-${dayStr}`]).length;
  });

  const lineData = {
    labels: days.map(d => d.split('-')[2]),
    datasets: [
      {
        label: 'Volume',
        data: dailyCompletions,
        fill: true,
        backgroundColor: (context) => {
          const ctx = context.chart.ctx;
          const gradient = ctx.createLinearGradient(0, 0, 0, 300);
          gradient.addColorStop(0, 'rgba(255, 107, 44, 0.4)');
          gradient.addColorStop(1, 'rgba(255, 107, 44, 0.0)');
          return gradient;
        },
        borderColor: '#FF6B2C',
        borderWidth: 2,
        tension: 0.4,
        pointBackgroundColor: '#FF6B2C',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: '#FF6B2C',
      },
    ],
  };

  // Category Doughnut Data
  const categories = useMemo(() => {
    const counts = {};
    habits.forEach(h => {
      counts[h.category] = (counts[h.category] || 0) + 1;
    });
    return counts;
  }, [habits]);

  const doughnutData = {
    labels: Object.keys(categories),
    datasets: [
      {
        data: Object.values(categories),
        backgroundColor: [
          '#FF6B2C', '#E85D04', '#FF6B2C', '#E85D04', '#FF8C42', '#FF6B2C'
        ],
        borderWidth: 0,
        hoverOffset: 10,
      },
    ],
  };

  // Radar Chart Data
  const radarData = {
    labels: Object.keys(categories).length > 0 ? Object.keys(categories) : ['None'],
    datasets: [
      {
        label: 'Consistency Rating',
        data: Object.keys(categories).map(cat => {
          const catHabits = habits.filter(h => h.category === cat);
          let completed = 0;
          catHabits.forEach(h => {
            days.forEach(day => {
              if (completions[`${h.id}-${day}`]) completed++;
            });
          });
          const total = catHabits.length * daysInMonth;
          return total > 0 ? (completed / total) * 100 : 0;
        }),
        backgroundColor: 'rgba(232, 93, 4, 0.2)',
        borderColor: '#E85D04',
        pointBackgroundColor: '#E85D04',
        borderWidth: 2,
      },
    ],
  };

  const chartOptionsCommon = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      tooltip: {
        backgroundColor: 'rgba(20, 20, 25, 0.9)',
        titleColor: '#F8FAFC',
        bodyColor: '#94A3B8',
        borderColor: 'rgba(255,255,255,0.1)',
        borderWidth: 1,
        padding: 12,
        cornerRadius: 8,
        displayColors: true,
      }
    }
  };

  const radarOptions = {
    ...chartOptionsCommon,
    scales: {
      r: {
        angleLines: { color: 'rgba(255,255,255,0.05)' },
        grid: { color: 'rgba(255,255,255,0.05)' },
        pointLabels: { color: '#94A3B8', font: { family: 'Inter', size: 12 } },
        ticks: { display: false }
      }
    },
    plugins: { legend: { display: false }, ...chartOptionsCommon.plugins }
  };

  return (
    <div className="space-y-8 pb-10">
      <div className="relative z-10">
        <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
          Telemetry <Activity className="text-[#E85D04]" />
        </h1>
        <p className="text-textMuted mt-2 text-lg">Deep analytical review of operational performance.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="glass-card p-8 rounded-3xl col-span-1 lg:col-span-2 shadow-2xl relative overflow-hidden group">
          <div className="absolute top-0 right-0 w-96 h-96 bg-[#FF6B2C]/10 rounded-full blur-[120px] pointer-events-none group-hover:bg-[#FF6B2C]/20 transition-colors" />
          <h2 className="text-2xl font-display font-bold text-white mb-8 relative z-10">Volume Trajectory</h2>
          <div className="h-80 relative z-10">
            <Line 
              data={lineData} 
              options={{ 
                ...chartOptionsCommon,
                scales: {
                  y: { grid: { color: 'rgba(255,255,255,0.02)' }, ticks: { color: '#94A3B8' } },
                  x: { grid: { display: false }, ticks: { color: '#94A3B8' } }
                },
                plugins: { legend: { display: false }, ...chartOptionsCommon.plugins }
              }} 
            />
          </div>
        </div>

        <div className="glass-card p-8 rounded-3xl shadow-2xl relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-[#E85D04]/10 rounded-full blur-[100px] pointer-events-none" />
          <h2 className="text-xl font-display font-bold text-white mb-8 text-center relative z-10">Protocol Distribution</h2>
          <div className="h-72 flex justify-center relative z-10">
            {Object.keys(categories).length > 0 ? (
              <Doughnut 
                data={doughnutData} 
                options={{ 
                  ...chartOptionsCommon,
                  plugins: {
                    ...chartOptionsCommon.plugins,
                    legend: { position: 'right', labels: { color: '#F8FAFC', padding: 20, usePointStyle: true, pointStyle: 'circle' } }
                  },
                  cutout: '70%'
                }} 
              />
            ) : (
              <div className="flex items-center text-textMuted">Awaiting protocol data.</div>
            )}
          </div>
        </div>

        <div className="glass-card p-8 rounded-3xl shadow-2xl relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-[#FF8C42]/10 rounded-full blur-[100px] pointer-events-none" />
          <h2 className="text-xl font-display font-bold text-white mb-8 text-center relative z-10">Consistency Web</h2>
          <div className="h-72 flex justify-center relative z-10">
            {Object.keys(categories).length > 0 ? (
              <Radar data={radarData} options={radarOptions} />
            ) : (
              <div className="flex items-center text-textMuted">Insufficient telemetry.</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
